// test/utils/shop_boundary_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  bool canBuy({
    required int totalXp,
    required int xpSpent,
    required int freezesOwned,
  }) {
    const price = 500;
    const max = 2;
    return (totalXp - xpSpent) >= price && freezesOwned < max;
  }

  group('Shop purchase boundaries', () {
    test('0 XP → cannot buy', () {
      expect(canBuy(totalXp: 0, xpSpent: 0, freezesOwned: 0), isFalse);
    });

    test('499 XP → cannot buy', () {
      expect(canBuy(totalXp: 499, xpSpent: 0, freezesOwned: 0), isFalse);
    });

    test('exactly 500 XP → can buy', () {
      expect(canBuy(totalXp: 500, xpSpent: 0, freezesOwned: 0), isTrue);
    });

    test('owns 2 already → cannot buy even with 10000 XP', () {
      expect(canBuy(totalXp: 10000, xpSpent: 0, freezesOwned: 2), isFalse);
    });

    test('already spent 500 of 1000 → can still buy', () {
      expect(canBuy(totalXp: 1000, xpSpent: 500, freezesOwned: 1), isTrue);
    });

    test('spent all → cannot buy', () {
      expect(canBuy(totalXp: 1000, xpSpent: 1000, freezesOwned: 2), isFalse);
    });
  });
}
