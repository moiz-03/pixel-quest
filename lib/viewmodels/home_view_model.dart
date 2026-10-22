import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_durations.dart';
import '../constants/xp_constants.dart';
import '../models/quest.dart';
import '../models/tier.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_service.dart';
import '../services/prefs.dart';
import '../utils/date_helper.dart';
import '../utils/quest_streak.dart';
import '../utils/streak_freeze.dart';
import '../utils/suggested_quest_selector.dart';
import '../utils/xp_calculator.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    FirebaseAuth? auth,
    AuthService? authService,
    FirestoreService? firestore,
    NotificationScheduler? notifications,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _authService = authService ?? AuthService.instance,
       _firestore = firestore ?? FirestoreService.instance,
       _notifications = notifications ?? NotificationService.instance;

  // ── Shop constants ───────────────────────────────────────────────────────
  static const int freezePrice = 500;
  static const int maxFreezes = 2;

  final FirebaseAuth _auth;
  final AuthService _authService;
  final FirestoreService _firestore;
  final NotificationScheduler _notifications;

  // ── State ────────────────────────────────────────────────────────────────
  int _tabIndex = 0;
  int _level = 0;
  int _currentXp = 0;
  int _xpToNext = XpConstants.startingXpToNext;
  int _availableXp = 0;
  int _xpSpent = 0;
  int _streakFreezes = 0;
  int _streak = 0;

  String _username = 'Player';
  bool _loggingOut = false;
  bool _buyingFreeze = false;
  bool? _freezeConsumedThisSession;
  String? _uid;
  bool _loaded = false;
  bool _deletingAccount = false;
  bool get deletingAccount => _deletingAccount;

  final Map<String, String> _dismissedSuggestions = {};

  String? _lastActive;
  final Set<String> _streakHistory = {};

  final List<Quest> _quests = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _questsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _progressSub;

  // ── Sync error state ─────────────────────────────────────────────────────
  String? _questsSyncError;
  String? _progressSyncError;

  // Guards retrySync against re-entrancy. If two taps (or two triggers)
  // arrive before the first finishes cancelling + resubscribing, the second
  // returns immediately. Without this, a rapid double-tap on the RETRY
  // banner can leave `syncError` set to a stale error from a half-cancelled
  // stream while the newer stream is working fine.
  bool _retrying = false;

  /// Non-null if either realtime stream is currently in an error state.
  /// UI should show a persistent banner ("Offline — tap to retry") when
  /// this is set, and call [retrySync] from its action button.
  String? get syncError => _questsSyncError ?? _progressSyncError;

  // ── Getters ──────────────────────────────────────────────────────────────
  int get tabIndex => _tabIndex;
  int get level => _level;
  int get currentXp => _currentXp;
  int get xpToNext => _xpToNext;
  int get totalXp => _availableXp;
  int get availableXp => _availableXp;
  int get xpSpent => _xpSpent;
  int get streakFreezes => _streakFreezes;
  int get streak => _streak;
  String get username => _username;
  bool get loggingOut => _loggingOut;
  bool get buyingFreeze => _buyingFreeze;
  bool get loaded => _loaded;
  Set<String> get streakHistory => _streakHistory;
  List<Quest> get quests => _quests;

  bool get canBuyFreeze =>
      _availableXp >= freezePrice && _streakFreezes < maxFreezes;

  bool get freezesFull => _streakFreezes >= maxFreezes;

  bool get freezeConsumedThisSession => _freezeConsumedThisSession == true;

  Quest? get suggestedQuest =>
      selectSuggestedQuest(_quests, _dismissedSuggestions);

  int get suggestedQuestStreak {
    final q = suggestedQuest;
    if (q == null) return 0;
    return questStreak(q);
  }

  // ── Safe readers for Firestore data ──────────────────────────────────────
  // Firestore field types are not enforced by security rules, so a corrupt
  // document (or an old migration writing strings for ints) must not crash
  // the stream listeners or bootstrap. These readers coerce defensively and
  // return null on incompatible types so callers can fall back.
  int? _readInt(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  String? _readString(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is String) return v;
    if (v == null) return null;
    return v.toString();
  }

  List<String>? _readStringList(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is List) return v.whereType<String>().toList();
    return null;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _questsSub?.cancel();
    _progressSub?.cancel();
    super.dispose();
  }

  // ── Batched notification ─────────────────────────────────────────────────
  bool _notifyScheduled = false;

  void _notifySoon() {
    if (_notifyScheduled || _disposed) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      if (!_disposed) notifyListeners();
    });
  }

  // ── Tab ──────────────────────────────────────────────────────────────────
  void setTabIndex(int i) {
    if (_tabIndex == i) return;
    _tabIndex = i;
    notifyListeners();
  }

  // ── Realtime sync ────────────────────────────────────────────────────────
  void _startRealtimeSync(String uid) {
    _questsSub?.cancel();
    _questsSub = _firestore
        .watchQuests(uid)
        .listen(
          (snap) {
            _quests
              ..clear()
              ..addAll(snap.docs.map((d) => Quest.fromMap(d.id, d.data())));
            _syncProgress();
            _questsSyncError = null; // recovered
            _notifySoon();
          },
          onError: (e) {
            debugPrint('Quest stream error: $e');
            _questsSyncError = e.toString();
            _notifySoon();
          },
        );
  }

  void _startProgressSync(String uid) {
    _progressSub?.cancel();
    _progressSub = _firestore
        .watchProgress(uid)
        .listen(
          (snap) {
            final p = snap.data();
            if (p == null) return;

            _streak = _readInt(p, 'streak') ?? _streak;
            _xpSpent = _readInt(p, 'xpSpent') ?? _xpSpent;
            _streakFreezes = _readInt(p, 'streakFreezes') ?? _streakFreezes;

            final la = _readString(p, 'lastActive');
            if (la != null && la.isNotEmpty) _lastActive = la;

            final hist = _readStringList(p, 'streakHistory');
            if (hist != null) {
              _streakHistory
                ..clear()
                ..addAll(hist);
            }

            _syncProgress();
            _progressSyncError = null; // recovered
            _notifySoon();
          },
          onError: (e) {
            debugPrint('Progress stream error: $e');
            _progressSyncError = e.toString();
            _notifySoon();
          },
        );
  }

  // ── Streak ───────────────────────────────────────────────────────────────
  void _bumpStreakLocally() {
    final today = DateHelper.todayIso();
    if (_lastActive == today) return;
    _streak = (_lastActive == DateHelper.yesterdayIso()) ? _streak + 1 : 1;
    _lastActive = today;
    _streakHistory.add(today);
  }

  bool _runFreezeCheck() {
    final decision = StreakFreeze.decide(
      lastActive: _lastActive,
      freezesOwned: _streakFreezes,
    );

    switch (decision) {
      case FreezeDecision.noAction:
        return false;

      case FreezeDecision.noHistory:
        if (_lastActive == null) {
          _streak = 0;
          return true;
        }
        return false;

      case FreezeDecision.consume:
        final yesterday = DateHelper.yesterdayIso();
        _streakFreezes -= 1;
        _lastActive = yesterday;
        _streakHistory.add(yesterday);
        _freezeConsumedThisSession = true;
        debugPrint('🧊 Streak freeze consumed for $yesterday');
        return true;

      case FreezeDecision.breakNoFreeze:
      case FreezeDecision.breakTooLong:
        _streak = 0;
        return true;
    }
  }

  // ── Bootstrap ────────────────────────────────────────────────────────────
  Future<bool> bootstrap() async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      debugPrint('⚠️ Bootstrap: no FirebaseAuth user; clearing session');
      await Prefs.clearSession();
      return false;
    }

    final cachedUid = await Prefs.currentUid;
    debugPrint('🔍 Bootstrap uids: auth=${authUser.uid}, cached=$cachedUid');

    if (cachedUid != authUser.uid) {
      debugPrint('⚠️ Bootstrap: uid mismatch — syncing Prefs to auth uid');
      await Prefs.clearSession();
      await Prefs.saveSession(
        uid: authUser.uid,
        email: authUser.email ?? '',
        username: authUser.displayName ?? authUser.email?.split('@').first,
      );
    }

    final uid = authUser.uid;

    final name = await Prefs.username;
    final cachedQuests = await Prefs.loadQuests(uid);
    final cachedProgress = await Prefs.loadProgress(uid);
    final cachedLastActive = await Prefs.lastActiveDate(uid);
    final cachedHistory = await Prefs.streakHistory(uid);
    final cachedDismissals = await Prefs.loadDismissedSuggestions(uid);

    _uid = uid;
    if (name != null && name.isNotEmpty) _username = name;
    _quests
      ..clear()
      ..addAll(cachedQuests);
    _level = cachedProgress.level;
    _currentXp = cachedProgress.currentXp;
    _xpToNext = cachedProgress.xpToNext;
    _availableXp = cachedProgress.totalXp;
    _streak = cachedProgress.streak;
    _xpSpent = cachedProgress.xpSpent;
    _streakFreezes = cachedProgress.streakFreezes;
    _lastActive = cachedLastActive;
    _streakHistory
      ..clear()
      ..addAll(cachedHistory);
    _dismissedSuggestions
      ..clear()
      ..addAll(cachedDismissals);
    _loaded = true;
    _notifySoon();

    try {
      final remote = await _firestore.loadAll(uid);

      final hasRemoteData =
          remote.quests.isNotEmpty || (remote.progress?.isNotEmpty ?? false);
      final hasLocalData =
          cachedQuests.isNotEmpty ||
          cachedProgress.totalXp > 0 ||
          cachedProgress.streak > 0;

      if (!hasRemoteData && hasLocalData) {
        debugPrint('Firestore: migrating local data to cloud (atomic)');
        await _firestore.replaceAllQuestsAndProgress(
          uid,
          cachedQuests,
          level: cachedProgress.level,
          currentXp: cachedProgress.currentXp,
          xpToNext: cachedProgress.xpToNext,
          totalXp: cachedProgress.totalXp,
          streak: cachedProgress.streak,
          xpSpent: cachedProgress.xpSpent,
          streakFreezes: cachedProgress.streakFreezes,
          lastActive: cachedLastActive,
          streakHistory: cachedHistory,
        );
      } else if (!hasRemoteData && !hasLocalData) {
        debugPrint('Firestore: seeding new user doc');
        await _firestore.saveProgress(
          uid,
          level: 0,
          currentXp: 0,
          xpToNext: XpConstants.startingXpToNext,
          totalXp: 0,
          streak: 0,
          xpSpent: 0,
          streakFreezes: 0,
          lastActive: null,
          streakHistory: const [],
        );
      } else {
        _quests
          ..clear()
          ..addAll(remote.quests);

        final p = remote.progress;

        if (p != null) {
          _streak = _readInt(p, 'streak') ?? 0;
          _xpSpent = _readInt(p, 'xpSpent') ?? 0;
          _streakFreezes = _readInt(p, 'streakFreezes') ?? 0;
          final la = _readString(p, 'lastActive');
          _lastActive = (la != null && la.isNotEmpty) ? la : null;
          final hist = _readStringList(p, 'streakHistory');
          if (hist != null) {
            _streakHistory
              ..clear()
              ..addAll(hist);
          }
        } else {
          _streak = 0;
          _lastActive = null;
          _streakHistory.clear();
        }

        _syncProgress();

        final streakChanged = _runFreezeCheck();
        _notifySoon();

        final storedTotalXp =
            _readInt(remote.progress ?? const <String, dynamic>{}, 'totalXp') ??
            0;
        final trustLocal = _availableXp >= storedTotalXp;

        if (!trustLocal) {
          debugPrint(
            '⚠️ Recomputed totalXp ($_availableXp) < stored ($storedTotalXp); '
            'trusting stored progress.',
          );
          final stored = remote.progress!;
          _level = _readInt(stored, 'level') ?? 0;
          _currentXp = _readInt(stored, 'currentXp') ?? 0;
          _xpToNext =
              _readInt(stored, 'xpToNext') ?? XpConstants.startingXpToNext;
          _availableXp = storedTotalXp;
          _notifySoon();
        }

        if (trustLocal || streakChanged) {
          try {
            await _firestore.saveProgress(
              uid,
              level: _level,
              currentXp: _currentXp,
              xpToNext: _xpToNext,
              totalXp: _availableXp,
              streak: _streak,
              xpSpent: _xpSpent,
              streakFreezes: _streakFreezes,
              lastActive: _lastActive,
              streakHistory: _streakHistory.toList(),
            );
          } catch (e) {
            debugPrint('⚠️ Failed to push recomputed progress: $e');
          }
        }

        await Prefs.saveQuests(uid, _quests);
        await Prefs.saveProgress(
          uid,
          level: _level,
          currentXp: _currentXp,
          xpToNext: _xpToNext,
          totalXp: _availableXp,
          streak: _streak,
          xpSpent: _xpSpent,
          streakFreezes: _streakFreezes,
        );
        if (_lastActive != null) {
          await Prefs.setLastActiveDate(uid, _lastActive!);
        }
        await Prefs.setStreakHistory(uid, _streakHistory.toList());
      }
    } catch (e) {
      debugPrint('Firestore load failed, using cache: $e');
    }

    _startRealtimeSync(uid);
    _startProgressSync(uid);

    try {
      await _notifications.rescheduleAllForQuests(_quests);
    } catch (e) {
      debugPrint('⚠️ Could not reschedule reminders: $e');
    }

    return true;
  }

  void acknowledgeFreezeConsumed() {
    if (_freezeConsumedThisSession != true) return;
    _freezeConsumedThisSession = false;
    notifyListeners();
  }

  // ── Persistence ──────────────────────────────────────────────────────────
  //
  // Firestore is authoritative. Prefs is a write-ahead cache for offline
  // bootstrap. We write Firestore first, Prefs second — and each block
  // has its own try/catch so a failure in one layer cannot block the
  // other. This means:
  //   • Prefs fails → Firestore still gets the truth; next bootstrap
  //     reconciles Prefs from Firestore (trustLocal path).
  //   • Firestore fails → Prefs still gets the change; local state is
  //     preserved and will be retried on next online write.
  Future<void> _persist({Quest? changedQuest, bool deleted = false}) async {
    if (!_loaded || _uid == null) return;
    final uid = _uid!;

    // ── Firestore: authoritative.
    try {
      if (deleted && changedQuest != null) {
        await _firestore.deleteQuest(uid, changedQuest.id);
      } else if (changedQuest != null) {
        await _firestore.upsertQuest(uid, changedQuest);
      }
    } catch (e) {
      debugPrint('❌ Firestore quest write failed: $e');
    }

    try {
      await _firestore.saveProgress(
        uid,
        level: _level,
        currentXp: _currentXp,
        xpToNext: _xpToNext,
        totalXp: _availableXp,
        streak: _streak,
        xpSpent: _xpSpent,
        streakFreezes: _streakFreezes,
        lastActive: _lastActive,
        streakHistory: _streakHistory.toList(),
      );
    } catch (e) {
      debugPrint('❌ Firestore progress write failed: $e');
    }

    // ── Prefs: best-effort cache for offline bootstrap.
    try {
      await Prefs.saveQuests(uid, _quests);
      await Prefs.saveProgress(
        uid,
        level: _level,
        currentXp: _currentXp,
        xpToNext: _xpToNext,
        totalXp: _availableXp,
        streak: _streak,
        xpSpent: _xpSpent,
        streakFreezes: _streakFreezes,
      );
      if (_lastActive != null) {
        await Prefs.setLastActiveDate(uid, _lastActive!);
      }
      await Prefs.setStreakHistory(uid, _streakHistory.toList());
    } catch (e) {
      debugPrint('❌ Prefs cache write failed: $e');
    }
  }

  // ── Progress derivation ──────────────────────────────────────────────────
  void _syncProgress() {
    final earned = XpCalculator.computeTotalXp(_quests);
    final net = earned - _xpSpent;
    _availableXp = net < 0 ? 0 : net;
    final xp = XpCalculator.recomputeLevel(_availableXp);
    _level = xp.level;
    _currentXp = xp.currentXp;
    _xpToNext = xp.xpToNext;
  }

  Tier? _applyMutation(VoidCallback mutate) {
    Tier? unlocked;
    final oldLevel = _level;
    mutate();
    _syncProgress();
    if (_level > oldLevel) {
      final oldTier = Tier.forLevel(oldLevel);
      final newTier = Tier.forLevel(_level);
      if (newTier != oldTier) unlocked = newTier;
    }
    notifyListeners();
    return unlocked;
  }

  // ── Public mutators ──────────────────────────────────────────────────────
  Future<Tier?> toggleQuest(Quest quest) async {
    final today = DateHelper.todayIso();

    final tierUp = _applyMutation(() {
      if (quest.completedDates.contains(today)) {
        quest.removeCompletion(today);
      } else {
        quest.addCompletion(today);
        _bumpStreakLocally();
      }
    });

    await _persist(changedQuest: quest);
    return tierUp;
  }

  Future<Tier?> addQuest(Quest quest) async {
    final tierUp = _applyMutation(() => _quests.add(quest));
    await _persist(changedQuest: quest);
    await _notifications.scheduleQuestReminder(quest);
    return tierUp;
  }

  Future<Tier?> editQuest(Quest quest) async {
    // Guard: don't write a ghost to Firestore.
    final exists = _quests.any((q) => q.id == quest.id);
    if (!exists) return null;

    final tierUp = _applyMutation(() {
      final i = _quests.indexWhere((q) => q.id == quest.id);
      if (i != -1) _quests[i] = quest;
    });
    await _persist(changedQuest: quest);
    await _notifications.scheduleQuestReminder(quest);
    return tierUp;
  }

  Future<Tier?> deleteQuest(Quest quest) async {
    // Use id-based removal so a copy (e.g. a `copyWith`'d instance) still
    // matches. Identity-based remove would silently no-op if the caller
    // ever passes a different instance with the same id.
    final tierUp = _applyMutation(
      () => _quests.removeWhere((q) => q.id == quest.id),
    );
    await _persist(changedQuest: quest, deleted: true);
    await _notifications.cancelQuestReminder(quest.id);
    return tierUp;
  }

  // ── Shop ─────────────────────────────────────────────────────────────────
  Future<void> buyStreakFreeze() async {
    if (_streakFreezes >= maxFreezes) {
      throw const FreezePurchaseException('inventory_full');
    }
    if (_availableXp < freezePrice) {
      throw const FreezePurchaseException('insufficient_xp');
    }

    _buyingFreeze = true;
    notifyListeners();

    try {
      _xpSpent += freezePrice;
      _streakFreezes += 1;
      _syncProgress();
      await _persist();
    } catch (e) {
      _xpSpent -= freezePrice;
      _streakFreezes -= 1;
      _syncProgress();
      rethrow;
    } finally {
      _buyingFreeze = false;
      if (!_disposed) notifyListeners();
    }
  }

  // ── Suggestion actions ───────────────────────────────────────────────────
  Future<void> acceptSuggestion() async {
    final q = suggestedQuest;
    if (q == null) return;

    final updated = q.copyWith(reminderTime: '20:00');
    final i = _quests.indexWhere((x) => x.id == q.id);
    if (i == -1) return;
    _quests[i] = updated;

    await _persist(changedQuest: updated);
    await _notifications.scheduleQuestReminder(updated);

    notifyListeners();
  }

  Future<void> dismissSuggestion() async {
    final q = suggestedQuest;
    if (q == null) return;
    final uid = _uid;
    if (uid == null) return;

    final today = DateHelper.todayIso();
    _dismissedSuggestions[q.id] = today;
    await Prefs.saveDismissedSuggestions(uid, _dismissedSuggestions);

    notifyListeners();
  }

  // ── Sync recovery ────────────────────────────────────────────────────────
  /// Cancels both realtime subscriptions and restarts them. Called by the
  /// UI when the user taps "Retry" on the sync-error banner, or on app
  /// resume when a banner is visible. Safe to call at any time; no-op
  /// if not bootstrapped or if the VM was disposed.
  Future<void> retrySync() async {
    if (_retrying) return;

    final uid = _uid;
    if (uid == null || _disposed) return;

    _retrying = true;
    try {
      _questsSyncError = null;
      _progressSyncError = null;
      _notifySoon();

      await _questsSub?.cancel();
      await _progressSub?.cancel();
      _questsSub = null;
      _progressSub = null;

      if (_disposed) return; // dispose() may have run during the awaits

      _startRealtimeSync(uid);
      _startProgressSync(uid);
    } finally {
      _retrying = false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _loggingOut = true;
    notifyListeners();

    try {
      await _firestore.waitForPendingWrites().timeout(
        AppDurations.logoutFlushTimeout,
      );
    } catch (e) {
      debugPrint('⚠️ Pending writes timed out: $e');
    }

    await _questsSub?.cancel();
    await _progressSub?.cancel();
    _questsSub = null;
    _progressSub = null;
    _questsSyncError = null;
    _progressSyncError = null;

    await _notifications.cancelAll();

    await _authService.signOut();
  }

  // ── Delete account ───────────────────────────────────────────────────────
  Future<void> deleteAccount(String password) async {
    _deletingAccount = true;
    notifyListeners();

    try {
      await _authService.deleteAccount(password: password);
    } finally {
      _deletingAccount = false;
      if (!_disposed) notifyListeners();
    }
  }
}

class FreezePurchaseException implements Exception {
  final String reason;
  const FreezePurchaseException(this.reason);

  @override
  String toString() => 'FreezePurchaseException: $reason';
}
