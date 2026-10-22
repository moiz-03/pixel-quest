import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/tier.dart';
import 'package:pixel_quest/screens/home/widgets/tier_up_dialog.dart';

void main() {
  testWidgets('renders TIER UP heading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TierUpDialog(tier: Tier.squire, level: 5)),
      ),
    );
    expect(find.text('TIER UP!'), findsOneWidget);
  });

  testWidgets('renders tier name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TierUpDialog(tier: Tier.knight, level: 15)),
      ),
    );
    expect(find.text('KNIGHT'), findsOneWidget);
  });

  testWidgets('renders LEVEL chip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TierUpDialog(tier: Tier.champion, level: 30)),
      ),
    );
    expect(find.text('LEVEL 30'), findsOneWidget);
  });

  testWidgets('renders tier flavor text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TierUpDialog(tier: Tier.hero, level: 50)),
      ),
    );
    expect(find.text(Tier.hero.flavor), findsOneWidget);
  });

  testWidgets('renders ONWARD button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TierUpDialog(tier: Tier.legend, level: 75)),
      ),
    );
    expect(find.text('ONWARD'), findsOneWidget);
  });
}
