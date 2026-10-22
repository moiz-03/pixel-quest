import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;

import 'firestore_service.dart';
import 'prefs.dart';

class AuthService {
  AuthService._({FirebaseAuth? auth, FirestoreService? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirestoreService.instance;

  static final AuthService instance = AuthService._();

  @visibleForTesting
  factory AuthService.forTesting({
    required FirebaseAuth auth,
    required FirestoreService firestore,
  }) => AuthService._(auth: auth, firestore: firestore);

  final FirebaseAuth _auth;
  final FirestoreService _firestore;

  User? get currentUser => _auth.currentUser;

  // ---------- Sign in ----------
  Future<UserCredential> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user!;
    await Prefs.saveSession(
      uid: user.uid,
      email: user.email ?? email,
      username: user.displayName ?? user.email?.split('@').first,
      rememberMe: rememberMe,
    );
    return cred;
  }

  // ---------- Register ----------
  Future<UserCredential> register({
    required String email,
    required String password,
    String? username,
    bool rememberMe = true,
  }) async {
    final hasUsername = username != null && username.trim().isNotEmpty;

    if (hasUsername) {
      final available = await _firestore.isUsernameAvailable(username);
      if (!available) {
        throw UsernameTakenException(username);
      }
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user!;

    if (hasUsername) {
      try {
        await _firestore.claimUsername(username, user.uid);
      } catch (e) {
        // Any failure (network, permission, race) must roll back the auth
        // user — otherwise the email is permanently burned and the user
        // can never re-register with it. UsernameTakenException still
        // propagates unchanged via rethrow.
        try {
          await user.delete();
        } catch (rollbackError) {
          debugPrint('⚠️ Could not roll back auth user: $rollbackError');
        }
        rethrow;
      }
    }

    if (hasUsername) {
      try {
        await user.updateDisplayName(username.trim());
      } catch (e) {
        debugPrint('⚠️ Could not set display name: $e');
      }
    }

    await Prefs.saveSession(
      uid: user.uid,
      email: user.email ?? email,
      username: username ?? user.email?.split('@').first,
      rememberMe: rememberMe,
    );
    return cred;
  }

  // ---------- Password reset ----------
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ---------- Sign out ----------
  Future<void> signOut() async {
    await _auth.signOut();
    await Prefs.clearSession();
  }

  // ---------- Human-readable errors ----------
  String messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak. Use 8+ chars with upper, lower, number, symbol.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        debugPrint('Unhandled auth error: ${e.code} / ${e.message}');
        return 'Something went wrong. Please try again.';
    }
  }

  /// Human-readable message for Firestore (not Auth) errors.
  String messageForFirestore(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
        return 'Cannot connect right now. Check your connection and try again.';
      case 'permission-denied':
        return 'You do not have permission to do that.';
      case 'not-found':
        return 'That item no longer exists.';
      case 'deadline-exceeded':
        return 'The request timed out. Try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // ---------- Delete account ----------
  /// Permanently deletes the current user's account and all associated data.
  ///
  /// Order of operations:
  ///   1. Reauthenticate (required by Firebase for account deletion)
  ///   2. Delete Firestore data — if this fails, abort so we don't orphan data
  ///   3. Delete the Firebase Auth account
  ///   4. Clear local storage
  ///
  /// If Firestore deletion fails, the auth user is left intact so the user
  /// can retry. If auth deletion fails, local Prefs are left intact so the
  /// user isn't silently signed out of a still-existing account.
  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No user is currently signed in.');
    }

    final email = user.email;
    final uid = user.uid;
    if (email == null) {
      throw StateError('Signed-in user has no email address.');
    }

    // 1. Reauthenticate.
    final cred = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(cred);

    // 2. Delete Firestore data FIRST. If this fails, abort — don't leave
    //    orphaned data behind while deleting the auth user.
    final firestoreCleared = await _firestore.deleteAllUserData(uid);
    if (!firestoreCleared) {
      throw StateError(
        'Could not delete your data. Please check your connection and try again.',
      );
    }

    // 3. Delete the auth account.
    await user.delete();

    // 4. Clear local storage — safe now that auth is gone.
    await Prefs.clearProgress(uid);
    await Prefs.clearSession();
  }
}
