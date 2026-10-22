import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

enum Tier {
  novice(
    name: 'NOVICE',
    minLevel: 0,
    maxLevel: 4,
    icon: Pixel.circle,
    color: Color(0xFF8FA3BF),
    flavor: 'Every legend starts somewhere.',
  ),
  squire(
    name: 'SQUIRE',
    minLevel: 5,
    maxLevel: 14,
    icon: Pixel.shield,
    color: Color(0xFFCD7F32),
    flavor: 'Your training begins.',
  ),
  knight(
    name: 'KNIGHT',
    minLevel: 15,
    maxLevel: 29,
    icon: Pixel.bullseye,
    color: Color(0xFF7BA7D9),
    flavor: 'Steel yourself for what\'s ahead.',
  ),
  champion(
    name: 'CHAMPION',
    minLevel: 30,
    maxLevel: 49,
    icon: Pixel.trophy,
    color: Color(0xFFFFC542),
    flavor: 'The crowd roars your name.',
  ),
  hero(
    name: 'HERO',
    minLevel: 50,
    maxLevel: 74,
    icon: Pixel.avatar,
    color: Color(0xFF00E5A0),
    flavor: 'Legends are written by heroes.',
  ),
  legend(
    name: 'LEGEND',
    minLevel: 75,
    maxLevel: 99,
    icon: Pixel.anchor,
    color: Color(0xFF9D6BFF),
    flavor: 'Your name echoes through ages.',
  ),
  mythic(
    name: 'MYTHIC',
    minLevel: 100,
    maxLevel: 999999,
    icon: Pixel.zap,
    color: Color(0xFFFF4D8F),
    flavor: 'You have transcended mortality.',
  );

  const Tier({
    required this.name,
    required this.minLevel,
    required this.maxLevel,
    required this.icon,
    required this.color,
    required this.flavor,
  });

  final String name;
  final int minLevel;
  final int maxLevel;
  final IconData icon;
  final Color color;
  final String flavor;

  static Tier forLevel(int level) {
    for (final t in Tier.values) {
      if (level >= t.minLevel && level <= t.maxLevel) return t;
    }
    return Tier.mythic;
  }

  Tier? get next {
    final i = Tier.values.indexOf(this);
    if (i >= Tier.values.length - 1) return null;
    return Tier.values[i + 1];
  }

  int get levelsInTier => maxLevel - minLevel + 1;

  int levelsToNext(int currentLevel) {
    if (next == null) return 0;
    return (maxLevel - currentLevel + 1).clamp(0, 9999);
  }
}
