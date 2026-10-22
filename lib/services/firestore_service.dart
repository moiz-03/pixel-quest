import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/quest.dart';

class FirestoreService {
  FirestoreService._({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Protected constructor for test subclasses. Production code must use
  /// [FirestoreService.instance]. Tests may extend this class to simulate
  /// network failures on specific methods.
  @protected
  FirestoreService.protected({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Production singleton. Tests use [FirestoreService.forTesting].
  static final FirestoreService instance = FirestoreService._();

  /// Constructor for tests — pass a [FakeFirebaseFirestore].
  @visibleForTesting
  factory FirestoreService.forTesting(FirebaseFirestore db) =>
      FirestoreService._(db: db);

  final FirebaseFirestore _db;

  // ── References ───────────────────────────────────────────────────────────
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _questsCol(String uid) =>
      _userDoc(uid).collection('quests');

  CollectionReference<Map<String, dynamic>> get _usernamesCol =>
      _db.collection('usernames');

  // ── Username uniqueness ──────────────────────────────────────────────────
  static String usernameKey(String username) => username.trim().toLowerCase();

  Future<bool> isUsernameAvailable(String username) async {
    final snap = await _usernamesCol.doc(usernameKey(username)).get();
    return !snap.exists;
  }

  Future<void> claimUsername(String username, String uid) async {
    final key = usernameKey(username);
    final ref = _usernamesCol.doc(key);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        throw UsernameTakenException(username);
      }
      tx.set(ref, {'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
    });
  }

  // ── Load everything at once ──────────────────────────────────────────────
  Future<({List<Quest> quests, Map<String, dynamic>? progress})> loadAll(
    String uid, {
    Source source = Source.serverAndCache,
  }) async {
    final results = await Future.wait([
      _questsCol(uid).get(GetOptions(source: source)),
      _userDoc(uid).get(GetOptions(source: source)),
    ]);

    final questsSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final userSnap = results[1] as DocumentSnapshot<Map<String, dynamic>>;

    final quests = questsSnap.docs
        .map((d) => Quest.fromMap(d.id, d.data()))
        .toList();

    quests.sort((a, b) => a.id.compareTo(b.id));

    return (quests: quests, progress: userSnap.data());
  }

  // ── Write progress (merged into user doc) ────────────────────────────────
  Future<void> saveProgress(
    String uid, {
    required int level,
    required int currentXp,
    required int xpToNext,
    required int totalXp,
    required int streak,
    int xpSpent = 0,
    int streakFreezes = 0,
    String? lastActive,
    List<String>? streakHistory,
  }) {
    return _userDoc(uid).set({
      'level': level,
      'currentXp': currentXp,
      'xpToNext': xpToNext,
      'totalXp': totalXp,
      'streak': streak,
      'xpSpent': xpSpent,
      'streakFreezes': streakFreezes,
      'lastActive': lastActive ?? '',
      'streakHistory': streakHistory ?? <String>[],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Quest writes ─────────────────────────────────────────────────────────
  Future<void> upsertQuest(String uid, Quest quest) {
    return _questsCol(uid).doc(quest.id).set({
      ...quest.toMap()..remove('id'),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteQuest(String uid, String questId) {
    return _questsCol(uid).doc(questId).delete();
  }

  /// Replace the whole quest list AND progress doc.
  ///
  /// If the operation fits inside a single batch (≤500 writes), it runs
  /// atomically. Larger accounts are chunked.
  Future<void> replaceAllQuestsAndProgress(
    String uid,
    List<Quest> quests, {
    required int level,
    required int currentXp,
    required int xpToNext,
    required int totalXp,
    required int streak,
    int xpSpent = 0,
    int streakFreezes = 0,
    String? lastActive,
    List<String>? streakHistory,
  }) async {
    final col = _questsCol(uid);
    final existing = await col.get();

    Map<String, dynamic> progressDoc() => {
      'level': level,
      'currentXp': currentXp,
      'xpToNext': xpToNext,
      'totalXp': totalXp,
      'streak': streak,
      'xpSpent': xpSpent,
      'streakFreezes': streakFreezes,
      'lastActive': lastActive ?? '',
      'streakHistory': streakHistory ?? <String>[],
      'updatedAt': FieldValue.serverTimestamp(),
    };

    Map<String, dynamic> questDoc(Quest q) => {
      ...q.toMap()..remove('id'),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final totalOps = existing.docs.length + quests.length + 1;
    if (totalOps <= 500) {
      final batch = _db.batch();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }
      for (final q in quests) {
        batch.set(col.doc(q.id), questDoc(q));
      }
      batch.set(_userDoc(uid), progressDoc(), SetOptions(merge: true));
      await batch.commit();
      return;
    }

    debugPrint('replaceAllQuestsAndProgress: $totalOps ops > 500, chunking');
    const chunkSize = 400;

    for (var i = 0; i < existing.docs.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, existing.docs.length);
      final batch = _db.batch();
      for (var j = i; j < end; j++) {
        batch.delete(existing.docs[j].reference);
      }
      await batch.commit();
    }

    for (var i = 0; i < quests.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, quests.length);
      final batch = _db.batch();
      for (var j = i; j < end; j++) {
        final q = quests[j];
        batch.set(col.doc(q.id), questDoc(q));
      }
      await batch.commit();
    }

    await _userDoc(uid).set(progressDoc(), SetOptions(merge: true));
  }

  /// Live stream of the user's quests.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchQuests(String uid) =>
      _questsCol(uid).snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProgress(String uid) =>
      _userDoc(uid).snapshots();

  // ── Account deletion ─────────────────────────────────────────────────────
  /// Deletes all Firestore data for the user.
  ///
  /// Returns `true` if every step succeeded, `false` if any step failed.
  /// Never throws — callers use the boolean to decide whether to proceed
  /// with deleting the auth user.
  ///
  /// Chunking is required because Firestore rejects batches with >500
  /// writes, and quest counts can exceed that for long-running accounts.
  Future<bool> deleteAllUserData(String uid) async {
    var allSucceeded = true;

    try {
      final questsSnap = await _questsCol(uid).get();
      if (questsSnap.docs.isNotEmpty) {
        await _deleteInChunks(questsSnap.docs);
      }
    } catch (e) {
      debugPrint('⚠️ Could not delete quests: $e');
      allSucceeded = false;
    }

    try {
      await _userDoc(uid).delete();
    } catch (e) {
      debugPrint('⚠️ Could not delete user doc: $e');
      allSucceeded = false;
    }

    try {
      final usernameSnap = await _usernamesCol
          .where('uid', isEqualTo: uid)
          .get();
      if (usernameSnap.docs.isNotEmpty) {
        await _deleteInChunks(usernameSnap.docs);
      }
    } catch (e) {
      debugPrint('⚠️ Could not release username: $e');
      allSucceeded = false;
    }

    return allSucceeded;
  }

  /// Deletes [docs] in chunks of ≤400. Required because Firestore rejects
  /// batches with >500 writes.
  Future<void> _deleteInChunks(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    const chunkSize = 400;
    for (var i = 0; i < docs.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, docs.length);
      final batch = _db.batch();
      for (var j = i; j < end; j++) {
        batch.delete(docs[j].reference);
      }
      await batch.commit();
    }
  }

  /// Flushes any queued writes. Used on logout to give pending
  /// Firestore operations a chance to complete.
  ///
  /// Silently no-ops on in-memory fakes that don't implement this.
  Future<void> waitForPendingWrites() async {
    try {
      await _db.waitForPendingWrites();
    } catch (_) {
      // FakeFirebaseFirestore doesn't implement this. Nothing to flush
      // there anyway, so it's safe to ignore.
    }
  }
}

class UsernameTakenException implements Exception {
  final String username;
  const UsernameTakenException(this.username);

  @override
  String toString() => 'Username "$username" is already taken.';
}
