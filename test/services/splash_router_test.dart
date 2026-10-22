import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/services/splash_router.dart';

/// Builds a router with configurable dependencies. Uses [MockFirebaseAuth]
/// so there's zero real Firebase involvement.
SplashRouter _build({
  bool hasAccount = true,
  bool rememberMe = true,
  String? cachedUid,
  bool loggedIn = false,
  bool mockUserPresent = false,
  Future<Object?> Function(String uid)? verifyUid,
}) {
  final mockAuth = MockFirebaseAuth(
    signedIn: mockUserPresent,
    mockUser: mockUserPresent
        ? MockUser(uid: 'real-uid', email: 'real@example.com')
        : null,
  );

  return SplashRouter(
    hasAccount: () async => hasAccount,
    rememberMe: () async => rememberMe,
    currentUid: () async => cachedUid,
    isLoggedIn: () async => loggedIn,
    clearSession: () async {},
    saveSession: ({
      required String uid,
      required String email,
      String? username,
      bool rememberMe = true,
    }) async {},
    auth: mockAuth,
    verifyUid: verifyUid ?? (_) async => null,
    authRestoreTimeout: const Duration(milliseconds: 100),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashRouter.resolve', () {
    test('no account on device → showAuthButtons', () async {
      expect(
        await _build(hasAccount: false).resolve(),
        SplashOutcome.showAuthButtons,
      );
    });

    test('account but rememberMe=false → goToLogin', () async {
      expect(
        await _build(rememberMe: false).resolve(),
        SplashOutcome.goToLogin,
      );
    });

    test('firebase user present → goToHome', () async {
      expect(
        await _build(mockUserPresent: true).resolve(),
        SplashOutcome.goToHome,
      );
    });

    test('no firebase user, no cached uid → goToLogin', () async {
      expect(await _build().resolve(), SplashOutcome.goToLogin);
    });

    test(
      'no firebase user, cached uid set but not logged in → goToLogin',
      () async {
        expect(
          await _build(cachedUid: 'abc', loggedIn: false).resolve(),
          SplashOutcome.goToLogin,
        );
      },
    );

    test('cached uid verifies → goToHome', () async {
      expect(
        await _build(
          cachedUid: 'abc',
          loggedIn: true,
          verifyUid: (_) async => null,
        ).resolve(),
        SplashOutcome.goToHome,
      );
    });

    test('cached uid fails verification → goToLogin', () async {
      expect(
        await _build(
          cachedUid: 'abc',
          loggedIn: true,
          verifyUid: (_) async => throw Exception('permission denied'),
        ).resolve(),
        SplashOutcome.goToLogin,
      );
    });

    test('resolve() never throws even if hasAccount throws', () async {
      final router = SplashRouter(
        hasAccount: () async => throw Exception('boom'),
        rememberMe: () async => true,
        currentUid: () async => null,
        isLoggedIn: () async => false,
        clearSession: () async {},
        saveSession: ({
          required String uid,
          required String email,
          String? username,
          bool rememberMe = true,
        }) async {},
        auth: MockFirebaseAuth(),
        verifyUid: (_) async => null,
      );

      expect(await router.resolve(), SplashOutcome.goToLogin);
    });
  });
}
