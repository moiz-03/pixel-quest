import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/tier.dart';

void main() {
  group('Tier.forLevel', () {
    test('level 0 → novice', () => expect(Tier.forLevel(0), Tier.novice));
    test('level 4 → novice', () => expect(Tier.forLevel(4), Tier.novice));
    test(
      'level 5 → squire (boundary)',
      () => expect(Tier.forLevel(5), Tier.squire),
    );
    test('level 14 → squire', () => expect(Tier.forLevel(14), Tier.squire));
    test(
      'level 15 → knight (boundary)',
      () => expect(Tier.forLevel(15), Tier.knight),
    );
    test('level 29 → knight', () => expect(Tier.forLevel(29), Tier.knight));
    test(
      'level 30 → champion (boundary)',
      () => expect(Tier.forLevel(30), Tier.champion),
    );
    test('level 49 → champion', () => expect(Tier.forLevel(49), Tier.champion));
    test(
      'level 50 → hero (boundary)',
      () => expect(Tier.forLevel(50), Tier.hero),
    );
    test('level 74 → hero', () => expect(Tier.forLevel(74), Tier.hero));
    test(
      'level 75 → legend (boundary)',
      () => expect(Tier.forLevel(75), Tier.legend),
    );
    test('level 99 → legend', () => expect(Tier.forLevel(99), Tier.legend));
    test(
      'level 100 → mythic (boundary)',
      () => expect(Tier.forLevel(100), Tier.mythic),
    );
    test(
      'level 999999 → mythic (max)',
      () => expect(Tier.forLevel(999999), Tier.mythic),
    );
    test(
      'very high level → mythic (fallback)',
      () => expect(Tier.forLevel(9999999), Tier.mythic),
    );
    test(
      'negative level → mythic (fallback quirk)',
      () => expect(Tier.forLevel(-1), Tier.mythic),
    );
  });

  group('Tier.next', () {
    test('novice.next == squire', () => expect(Tier.novice.next, Tier.squire));
    test('squire.next == knight', () => expect(Tier.squire.next, Tier.knight));
    test(
      'knight.next == champion',
      () => expect(Tier.knight.next, Tier.champion),
    );
    test('champion.next == hero', () => expect(Tier.champion.next, Tier.hero));
    test('hero.next == legend', () => expect(Tier.hero.next, Tier.legend));
    test('legend.next == mythic', () => expect(Tier.legend.next, Tier.mythic));
    test(
      'mythic.next == null (top tier)',
      () => expect(Tier.mythic.next, isNull),
    );
  });

  group('Tier.levelsInTier', () {
    test('novice spans 5 levels', () => expect(Tier.novice.levelsInTier, 5));
    test('squire spans 10 levels', () => expect(Tier.squire.levelsInTier, 10));
    test('knight spans 15 levels', () => expect(Tier.knight.levelsInTier, 15));
    test(
      'champion spans 20 levels',
      () => expect(Tier.champion.levelsInTier, 20),
    );
    test('hero spans 25 levels', () => expect(Tier.hero.levelsInTier, 25));
    test('legend spans 25 levels', () => expect(Tier.legend.levelsInTier, 25));
    test(
      'mythic spans a huge range',
      () => expect(Tier.mythic.levelsInTier, 999900),
    );
  });

  group('Tier.levelsToNext', () {
    test(
      'mythic has no next → 0',
      () => expect(Tier.mythic.levelsToNext(100), 0),
    );
    test(
      'novice at level 0 → 5 remaining',
      () => expect(Tier.novice.levelsToNext(0), 5),
    );
    test(
      'novice at level 4 → 1 remaining',
      () => expect(Tier.novice.levelsToNext(4), 1),
    );
    test(
      'squire at level 5 → 10 remaining',
      () => expect(Tier.squire.levelsToNext(5), 10),
    );
    test(
      'squire at level 10 → 5 remaining',
      () => expect(Tier.squire.levelsToNext(10), 5),
    );
    test(
      'legend at level 99 → 1 remaining',
      () => expect(Tier.legend.levelsToNext(99), 1),
    );
    test('result is clamped to 0 minimum', () {
      // level above tier.maxLevel would go negative, but clamp(0, 9999) saves it
      expect(Tier.novice.levelsToNext(100), 0);
    });
  });

  group('Tier metadata', () {
    test('every tier has a non-empty name', () {
      for (final t in Tier.values) {
        expect(t.name, isNotEmpty);
      }
    });
    test('every tier has a non-empty flavor', () {
      for (final t in Tier.values) {
        expect(t.flavor, isNotEmpty);
      }
    });
    test('minLevel is strictly increasing', () {
      for (var i = 1; i < Tier.values.length; i++) {
        expect(
          Tier.values[i].minLevel,
          greaterThan(Tier.values[i - 1].minLevel),
        );
      }
    });
    test('tiers are contiguous (no gaps)', () {
      for (var i = 1; i < Tier.values.length; i++) {
        expect(Tier.values[i].minLevel, Tier.values[i - 1].maxLevel + 1);
      }
    });
  });
}
