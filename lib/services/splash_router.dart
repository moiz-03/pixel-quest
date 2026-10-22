import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_service.dart';
import 'prefs.dart';

/// The high-level decision the splash screen needs to make on cold start.
enum SplashOutcome { showAuthButtons, goToLogin, goToHome }

/// Decides where the splash screen routes on cold start.
///
/// All side effects (Prefs writes, FirebaseAuth sign-out) happen here.
/// The caller — [SplashScreen] — maps the returned [SplashOutcome] to a
/// widget/navigation.
///
/// Dependencies are injected so tests can supply fakes.
class SplashRouter {
  SplashRouter({
    required this.hasAccount,
    required this.rememberMe,
    required this.currentUid,
    required this.isLoggedIn,
    required this.clearSession,
    required this.saveSession,
    required this.auth,
    required this.verifyUid,
    this.authRestoreTimeout = const Duration(seconds: 3),
    this.verifyTimeout = const Duration(seconds: 5),
  });

  /// Wires up the real singletons.
  factory SplashRouter.production() => SplashRouter(
    hasAccount: Prefs.hasAccount,
    rememberMe: Prefs.rememberMe,
    currentUid: () => Prefs.currentUid,
    isLoggedIn: Prefs.isLoggedIn,
    clearSession: Prefs.clearSession,
    saveSession: Prefs.saveSession,
    auth: FirebaseAuth.instance,
    verifyUid: (uid) =>
        FirestoreService.instance.loadAll(uid, source: Source.server),
  );

  final Future<bool> Function() hasAccount;
  final Future<bool> Function() rememberMe;
  final Future<String?> Function() currentUid;
  final Future<bool> Function() isLoggedIn;
  final Future<void> Function() clearSession;
  final Future<void> Function({
    required String uid,
    required String email,
    String? username,
    bool rememberMe,
  })
  saveSession;
  final FirebaseAuth auth;

  /// Verifies a cached uid against the server. In production this reads
  /// from Firestore with `Source.server`; the security rules reject the
  /// request if the current session isn't actually authenticated as that
  /// uid. Tests can pass anything.
  final Future<Object?> Function(String uid) verifyUid;

  final Duration authRestoreTimeout;
  final Duration verifyTimeout;

  /// Never throws — any internal failure falls back to [SplashOutcome.goToLogin].
  Future<SplashOutcome> resolve() async {
    try {
      return await _resolve();
    } catch (e, st) {
      debugPrint('Splash routing failed: $e\n$st');
      return SplashOutcome.goToLogin;
    }
  }

  Future<SplashOutcome> _resolve() async {
    if (!await hasAccount()) return SplashOutcome.showAuthButtons;

    if (!await rememberMe()) {
      await clearSession();
      await auth.signOut();
      return SplashOutcome.goToLogin;
    }

    User? fbUser = auth.currentUser;
    if (fbUser == null) {
      try {
        await auth.authStateChanges().first.timeout(authRestoreTimeout);
      } catch (_) {
        // Timeout or error — check currentUser once more below.
      }
      fbUser = auth.currentUser;
    }

    if (fbUser != null) {
      await saveSession(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        username: fbUser.displayName ?? fbUser.email?.split('@').first,
        rememberMe: true,
      );
      return SplashOutcome.goToHome;
    }

    final cachedUid = await currentUid();
    final cachedLoggedIn = await isLoggedIn();

    if (cachedUid != null && cachedLoggedIn) {
      try {
        await verifyUid(cachedUid).timeout(verifyTimeout);
        debugPrint('✅ Cached uid verified against Firestore');
        return SplashOutcome.goToHome;
      } catch (e) {
        debugPrint('⚠️ Cached uid verification failed: $e');
      }
    }

    await clearSession();
    return SplashOutcome.goToLogin;
  }
}
