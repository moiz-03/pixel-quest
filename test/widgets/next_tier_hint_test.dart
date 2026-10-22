import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/tier.dart';
import 'package:pixel_quest/screens/home/widgets/next_tier_hint.dart';

void main() {
  testWidgets('level 0 (novice) → shows levels to squire', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextTierHint(level: 0))),
    );
    // Novice maxLevel is 4 → 5 - 0 = 5 levels remaining
    expect(find.textContaining('5 levels to SQUIRE'), findsOneWidget);
  });

  testWidgets('level 4 (last novice level) → 1 level to squire', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextTierHint(level: 4))),
    );
    expect(find.textContaining('1 level to SQUIRE'), findsOneWidget);
  });

  testWidgets('level 5 (squire) → shows levels to knight', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextTierHint(level: 5))),
    );
    expect(find.textContaining('to KNIGHT'), findsOneWidget);
  });

  testWidgets('mythic tier → empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextTierHint(level: 100))),
    );
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('renders an icon of the next tier', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextTierHint(level: 0))),
    );
    // Squire icon
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Tier.squire.icon);
  });
}
