import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/prefs.dart';

class AuthViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _errorMessage;

  bool get busy => _busy;
  String? get errorMessage => _errorMessage;

  // ── Session info (for splash) ────────────────────────────────────────────
  Future<bool> hasAccount() => Prefs.hasAccount();
  Future<bool> rememberMe() => Prefs.rememberMe();
  Future<String?> currentUid() => Prefs.currentUid;
  Future<bool> isLoggedIn() => Prefs.isLoggedIn();

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  Future<void> signOutLocal() async {
    await Prefs.clearSession();
    await FirebaseAuth.instance.signOut();
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.instance.signIn(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.instance.messageFor(e);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────
  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.instance.register(
        email: email,
        password: password,
        username: username,
      );
      return true;
    } on UsernameTakenException catch (e) {
      _errorMessage = 'Username "${e.username}" is already taken. Try another.';
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.instance.messageFor(e);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // ── Password reset ───────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.instance.sendPasswordReset(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.instance.messageFor(e);
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // ── Sign out (full) ──────────────────────────────────────────────────────
  Future<void> signOut() async {
    await AuthService.instance.signOut();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
