import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/services/auth_service.dart';
import 'package:pixel_quest/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeDb;
  late FirestoreService firestoreService;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeDb = FakeFirebaseFirestore();
    firestoreService = FirestoreService.forTesting(fakeDb);
    mockAuth = MockFirebaseAuth();
    authService = AuthService.forTesting(
      auth: mockAuth,
      firestore: firestoreService,
    );
  });

  group('messageFor', () {
    test('maps known FirebaseAuthException codes to friendly strings', () {
      expect(
        authService.messageFor(FirebaseAuthException(code: 'invalid-email')),
        'That email address looks invalid.',
      );
      expect(
        authService.messageFor(FirebaseAuthException(code: 'user-not-found')),
        'No account found for that email.',
      );
      expect(
        authService.messageFor(FirebaseAuthException(code: 'wrong-password')),
        'Incorrect email or password.',
      );
      expect(
        authService.messageFor(
          FirebaseAuthException(code: 'invalid-credential'),
        ),
        'Incorrect email or password.',
      );
      expect(
        authService.messageFor(
          FirebaseAuthException(code: 'email-already-in-use'),
        ),
        'An account already exists for that email.',
      );
      expect(
        authService.messageFor(
          FirebaseAuthException(code: 'too-many-requests'),
        ),
        'Too many attempts. Try again later.',
      );
      expect(
        authService.messageFor(
          FirebaseAuthException(code: 'network-request-failed'),
        ),
        'Network error. Check your connection.',
      );
    });

    test('unknown code falls back to generic message', () {
      expect(
        authService.messageFor(FirebaseAuthException(code: 'some-new-code')),
        'Something went wrong. Please try again.',
      );
    });
  });

  group('signOut', () {
    test('clears auth state and Prefs session', () async {
      // Arrange: a signed-in user.
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1', email: 'a@b.co'),
      );
      authService = AuthService.forTesting(
        auth: mockAuth,
        firestore: firestoreService,
      );

      // Also seed Prefs so we can observe it being cleared.
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('pq_is_logged_in', true);
      await sp.setString('pq_user_id', 'u1');

      await authService.signOut();

      expect(mockAuth.currentUser, isNull);
      expect(sp.getBool('pq_is_logged_in'), isFalse);
      expect(sp.getString('pq_user_id'), isNull);
    });
  });

  group('deleteAccount', () {
    test('throws StateError when no user is signed in', () async {
      expect(
        () => authService.deleteAccount(password: 'x'),
        throwsA(isA<StateError>()),
      );
    });

    test('clears Firestore data and Prefs on success', () async {
      // Sign in a user.
      final user = MockUser(uid: 'u-delete', email: 'del@example.com');
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: user);
      authService = AuthService.forTesting(
        auth: mockAuth,
        firestore: firestoreService,
      );

      // Seed Firestore with quests + progress + username.
      await firestoreService.saveProgress(
        'u-delete',
        level: 5,
        currentXp: 10,
        xpToNext: 200,
        totalXp: 500,
        streak: 3,
      );
      await fakeDb
          .collection('users')
          .doc('u-delete')
          .collection('quests')
          .doc('q1')
          .set({'title': 'Test'});
      await fakeDb.collection('usernames').doc('deluser').set({
        'uid': 'u-delete',
      });

      // Seed Prefs.
      final sp = await SharedPreferences.getInstance();
      await sp.setString('pq_user_id', 'u-delete');
      await sp.setBool('pq_is_logged_in', true);

      await authService.deleteAccount(password: 'oldpass');

      // Firestore is empty.
      final questsSnap = await fakeDb
          .collection('users')
          .doc('u-delete')
          .collection('quests')
          .get();
      expect(questsSnap.docs, isEmpty);
      final userSnap = await fakeDb.collection('users').doc('u-delete').get();
      expect(userSnap.exists, isFalse);
      final usernameSnap = await fakeDb
          .collection('usernames')
          .doc('deluser')
          .get();
      expect(usernameSnap.exists, isFalse);

      // Local prefs cleared.
      expect(sp.getString('pq_user_id'), isNull);
      expect(sp.getBool('pq_is_logged_in'), isFalse);

      // Note: MockUser.delete() in firebase_auth_mocks doesn't clear
      // MockFirebaseAuth.currentUser, so we can't assert on that here.
      // The Firestore and Prefs assertions above prove deleteAccount
      // ran all the way through.
    });
  });
}
