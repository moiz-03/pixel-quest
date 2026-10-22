import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_quest/services/auth_service.dart';
import 'package:pixel_quest/services/firestore_service.dart';

// ── Firestore stubs ──────────────────────────────────────────────────────
class _NetworkFailOnClaim extends FirestoreService {
  _NetworkFailOnClaim(FirebaseFirestore db) : super.protected(db: db);

  @override
  Future<void> claimUsername(String username, String uid) async {
    throw Exception('simulated network failure');
  }
}

class _TakenOnClaim extends FirestoreService {
  _TakenOnClaim(FirebaseFirestore db) : super.protected(db: db);

  @override
  Future<void> claimUsername(String username, String uid) async {
    throw UsernameTakenException(username);
  }
}

class _SuccessOnClaim extends FirestoreService {
  _SuccessOnClaim(FirebaseFirestore db) : super.protected(db: db);

  @override
  Future<bool> isUsernameAvailable(String username) async => true;

  @override
  Future<void> claimUsername(String username, String uid) async {
    // no-op success
  }
}

// ── Minimal FirebaseAuth fakes ───────────────────────────────────────────
//
// AuthService.register only touches these User members:
//   - uid, email, displayName (reads)
//   - delete(), updateDisplayName() (writes)
//
// Everything else falls through to noSuchMethod and throws loudly — so if
// AuthService.register ever adds a new User member, this test tells us.
class _FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;

  bool deleteCalled = false;
  bool updateDisplayNameCalled = false;

  _FakeUser({required this.uid, this.email});

  @override
  String? get displayName => email?.split('@').first;

  @override
  Future<void> delete() async {
    deleteCalled = true;
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {
    updateDisplayNameCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '_FakeUser.${invocation.memberName} not implemented — '
    'if this fires, AuthService.register added a new User member.',
  );
}

class _FakeCredential implements UserCredential {
  @override
  final User user;
  _FakeCredential(this.user);

  @override
  AuthCredential? get credential => null;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '_FakeCredential.${invocation.memberName} not implemented',
  );
}

class _FakeAuth implements FirebaseAuth {
  final _FakeUser user;
  _FakeAuth(this.user);

  @override
  User? get currentUser => user;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async => _FakeCredential(user);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '_FakeAuth.${invocation.memberName} not implemented — '
    'if this fires, AuthService.register added a new auth call.',
  );
}

// ── Tests ────────────────────────────────────────────────────────────────
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('register calls user.delete() when claimUsername fails with a network error', () async {
    final user = _FakeUser(uid: 'orphan-uid', email: 'orphan@test.com');
    final auth = _FakeAuth(user);
    final fs = _NetworkFailOnClaim(FakeFirebaseFirestore());
    final svc = AuthService.forTesting(auth: auth, firestore: fs);

    await expectLater(
      svc.register(
        email: 'orphan@test.com',
        password: 'Test1234!',
        username: 'orphan',
      ),
      throwsA(isA<Exception>()),
    );

    expect(
      user.deleteCalled,
      isTrue,
      reason:
          'Auth user must be deleted on claimUsername failure to free '
          'the email for re-registration',
    );
  });

  test('register still rolls back on UsernameTakenException', () async {
    final user = _FakeUser(uid: 'taken-uid', email: 'taken@test.com');
    final auth = _FakeAuth(user);
    final fs = _TakenOnClaim(FakeFirebaseFirestore());
    final svc = AuthService.forTesting(auth: auth, firestore: fs);

    await expectLater(
      svc.register(
        email: 'taken@test.com',
        password: 'Test1234!',
        username: 'taken',
      ),
      throwsA(isA<UsernameTakenException>()),
    );

    expect(user.deleteCalled, isTrue);
  });

  test('register does NOT call delete on the success path', () async {
    final user = _FakeUser(uid: 'ok-uid', email: 'ok@test.com');
    final auth = _FakeAuth(user);
    final fs = _SuccessOnClaim(FakeFirebaseFirestore());
    final svc = AuthService.forTesting(auth: auth, firestore: fs);

    await svc.register(
      email: 'ok@test.com',
      password: 'Test1234!',
      username: 'ok',
    );

    expect(user.deleteCalled, isFalse);
    expect(user.updateDisplayNameCalled, isTrue);
  });
}
