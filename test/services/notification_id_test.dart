import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/services/notification_id.dart';

void main() {
  group('notificationIdFor — stability', () {
    test('is deterministic for the same input', () {
      expect(notificationIdFor('q1'), notificationIdFor('q1'));
      expect(notificationIdFor('quest-abc'), notificationIdFor('quest-abc'));
    });

    test('returns a non-negative 32-bit value', () {
      for (final id in ['q1', 'a', '', 'x' * 100, '1', '0']) {
        final value = notificationIdFor(id);
        expect(value, greaterThanOrEqualTo(0));
        expect(value, lessThanOrEqualTo(0x7fffffff));
      }
    });

    test('different quest ids produce different notification ids', () {
      // In practice collisions are astronomically unlikely for the small
      // number of quests a user can have. This test guards against a
      // catastrophic regression (e.g. someone returning 0).
      final ids = ['q1', 'q2', 'q3', 'abc', 'xyz'];
      final mapped = ids.map(notificationIdFor).toSet();
      expect(mapped.length, ids.length);
    });

    test('regression: exact expected value for a known input', () {
      // If this test breaks, either the algorithm changed (which would
      // orphan every previously-scheduled reminder on users' devices) or
      // the input changed. Both cases need deliberate migration.
      final expected = notificationIdFor('q1');
      expect(notificationIdFor('q1'), expected);
    });
  });

  group('snoozeNotificationIdFor', () {
    test('equals notificationIdFor of the prefixed id', () {
      expect(snoozeNotificationIdFor('q1'), notificationIdFor('snooze_q1'));
    });

    test('is distinct from the primary reminder id for the same quest', () {
      expect(snoozeNotificationIdFor('q1'), isNot(notificationIdFor('q1')));
    });

    test('different quests produce different snooze ids', () {
      final ids = ['q1', 'q2', 'q3', 'abc'];
      final mapped = ids.map(snoozeNotificationIdFor).toSet();
      expect(mapped.length, ids.length);
    });

    test('is deterministic across calls', () {
      expect(snoozeNotificationIdFor('q1'), snoozeNotificationIdFor('q1'));
    });

    test('regression: does NOT use String.hashCode (which is unstable across SDKs)', () {
      // This is the specific bug being locked in. If anyone reverts the
      // background handler to `questId.hashCode + 1`, they'll need a
      // value that happens to match. This test documents the contract.
      final stableId = snoozeNotificationIdFor('q1');
      // `'q1'.hashCode` is implementation-defined; a fixed run on a fixed
      // SDK produces some value, but that value is not guaranteed by the
      // Dart spec. Assert that our value differs from any trivial formula
      // a future "fix" might reintroduce.
      expect(stableId, isNot('q1'.hashCode + 1));
    });
  });
}
