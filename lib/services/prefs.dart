import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/xp_constants.dart';
import '../models/quest.dart';

class Prefs {
  Prefs._();

  // ---------------------------------------------------------------------------
  // Global keys (device-level, not tied to any user)
  // ---------------------------------------------------------------------------
  static const String _kHasAccount = 'pq_has_account';
  static const String _kIsLoggedIn = 'pq_is_logged_in';
  static const String _kRememberMe = 'pq_remember_me';
  static const String _kUserId = 'pq_user_id';
  static const String _kEmail = 'pq_email';
  static const String _kUsername = 'pq_username';

  static Future<SharedPreferences> get _sp => SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------
  // Per-user key builders
  // ---------------------------------------------------------------------------
  static String _questsKey(String uid) => 'pq_quests_$uid';
  static String _levelKey(String uid) => 'pq_level_$uid';
  static String _currentXpKey(String uid) => 'pq_current_xp_$uid';
  static String _xpToNextKey(String uid) => 'pq_xp_to_next_$uid';
  static String _totalXpKey(String uid) => 'pq_total_xp_$uid';
  static String _streakKey(String uid) => 'pq_streak_$uid';
  static String _xpSpentKey(String uid) => 'pq_xp_spent_$uid';
  static String _streakFreezesKey(String uid) => 'pq_streak_freezes_$uid';
  static String _lastActiveKey(String uid) => 'pq_last_active_$uid';
  static String _streakHistoryKey(String uid) => 'pq_streak_history_$uid';
  static String _suggestionsKey(String uid) => 'pq_suggestions_dismissed_$uid';

  // ---------------------------------------------------------------------------
  // Session (device-level)
  // ---------------------------------------------------------------------------
  static Future<bool> rememberMe() async =>
      (await _sp).getBool(_kRememberMe) ?? true;

  static Future<bool> hasAccount() async =>
      (await _sp).getBool(_kHasAccount) ?? false;

  static Future<bool> isLoggedIn() async =>
      (await _sp).getBool(_kIsLoggedIn) ?? false;

  static Future<String?> get currentUid async =>
      (await _sp).getString(_kUserId);

  static Future<String?> get userId async => (await _sp).getString(_kUserId);
  static Future<String?> get email async => (await _sp).getString(_kEmail);
  static Future<String?> get username async =>
      (await _sp).getString(_kUsername);

  /// Persist a full session after a successful Firebase login/register.
  static Future<void> saveSession({
    required String uid,
    required String email,
    String? username,
    bool rememberMe = true,
  }) async {
    final sp = await _sp;
    await sp.setBool(_kHasAccount, true);
    await sp.setBool(_kIsLoggedIn, true);
    await sp.setBool(_kRememberMe, rememberMe);
    await sp.setString(_kUserId, uid);
    await sp.setString(_kEmail, email);
    if (username != null) await sp.setString(_kUsername, username);
  }

  /// Clear ONLY the session — keeps `hasAccount`, `rememberMe`, and
  /// every user's quests/progress.
  static Future<void> clearSession() async {
    final sp = await _sp;
    await sp.setBool(_kIsLoggedIn, false);
    await sp.remove(_kUserId);
    await sp.remove(_kEmail);
    await sp.remove(_kUsername);
  }

  // ---------------------------------------------------------------------------
  // Quests (per-user)
  // ---------------------------------------------------------------------------
  static Future<void> saveQuests(String uid, List<Quest> quests) async {
    final sp = await _sp;
    final payload = quests.map((q) => q.toMap()).toList();
    await sp.setString(_questsKey(uid), jsonEncode(payload));
  }

  /// Returns [] if the user has no saved quests or the payload is corrupt.
  static Future<List<Quest>> loadQuests(String uid) async {
    final sp = await _sp;
    final raw = sp.getString(_questsKey(uid));
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => Quest.fromMap('', m))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Progress (per-user)
  // ---------------------------------------------------------------------------
  static Future<
    ({
      int level,
      int currentXp,
      int xpToNext,
      int totalXp,
      int streak,
      int xpSpent,
      int streakFreezes,
    })
  >
  loadProgress(String uid) async {
    final sp = await _sp;
    return (
      level: sp.getInt(_levelKey(uid)) ?? 0,
      currentXp: sp.getInt(_currentXpKey(uid)) ?? 0,
      xpToNext: sp.getInt(_xpToNextKey(uid)) ?? XpConstants.startingXpToNext,
      totalXp: sp.getInt(_totalXpKey(uid)) ?? 0,
      streak: sp.getInt(_streakKey(uid)) ?? 0,
      xpSpent: sp.getInt(_xpSpentKey(uid)) ?? 0,
      streakFreezes: sp.getInt(_streakFreezesKey(uid)) ?? 0,
    );
  }

  static Future<void> saveProgress(
    String uid, {
    required int level,
    required int currentXp,
    required int xpToNext,
    required int totalXp,
    required int streak,
    required int xpSpent,
    required int streakFreezes,
  }) async {
    final sp = await _sp;
    await sp.setInt(_levelKey(uid), level);
    await sp.setInt(_currentXpKey(uid), currentXp);
    await sp.setInt(_xpToNextKey(uid), xpToNext);
    await sp.setInt(_totalXpKey(uid), totalXp);
    await sp.setInt(_streakKey(uid), streak);
    await sp.setInt(_xpSpentKey(uid), xpSpent);
    await sp.setInt(_streakFreezesKey(uid), streakFreezes);
  }

  // ---------------------------------------------------------------------------
  // Streak storage (per-user)
  // ---------------------------------------------------------------------------
  static Future<String?> lastActiveDate(String uid) async =>
      (await _sp).getString(_lastActiveKey(uid));

  static Future<void> setLastActiveDate(String uid, String isoDate) async =>
      (await _sp).setString(_lastActiveKey(uid), isoDate);

  static Future<List<String>> streakHistory(String uid) async {
    final sp = await _sp;
    final raw = sp.getString(_streakHistoryKey(uid));
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<String>().toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setStreakHistory(String uid, List<String> dates) async {
    final sp = await _sp;
    await sp.setString(_streakHistoryKey(uid), jsonEncode(dates));
  }

  // ---------------------------------------------------------------------------
  // Suggestion dismissals (per-user, JSON map of questId → ISO date)
  // ---------------------------------------------------------------------------
  static Future<Map<String, String>> loadDismissedSuggestions(
    String uid,
  ) async {
    final sp = await _sp;
    final raw = sp.getString(_suggestionsKey(uid));
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveDismissedSuggestions(
    String uid,
    Map<String, String> data,
  ) async {
    final sp = await _sp;
    await sp.setString(_suggestionsKey(uid), jsonEncode(data));
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------
  static Future<void> clearProgress(String uid) async {
    final sp = await _sp;
    await sp.remove(_questsKey(uid));
    await sp.remove(_levelKey(uid));
    await sp.remove(_currentXpKey(uid));
    await sp.remove(_xpToNextKey(uid));
    await sp.remove(_totalXpKey(uid));
    await sp.remove(_streakKey(uid));
    await sp.remove(_xpSpentKey(uid));
    await sp.remove(_streakFreezesKey(uid));
    await sp.remove(_lastActiveKey(uid));
    await sp.remove(_streakHistoryKey(uid));
    await sp.remove(_suggestionsKey(uid));
  }
}
