import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/widgets/tier_badge.dart';

void main() {
  testWidgets('level 0 → shows NOVICE and "00"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TierBadge(level: 0))),
    );
    expect(find.text('NOVICE'), findsOneWidget);
    expect(find.text('00'), findsOneWidget);
  });

  testWidgets('level 5 → shows SQUIRE and "05"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TierBadge(level: 5))),
    );
    expect(find.text('SQUIRE'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);
  });

  testWidgets('level 100 → shows MYTHIC and "100"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TierBadge(level: 100))),
    );
    expect(find.text('MYTHIC'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('tap fires onTap when provided', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TierBadge(level: 0, onTap: () => tapped = true)),
      ),
    );
    await tester.tap(find.byType(TierBadge));
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // let AnimatedContainer settle
    expect(tapped, isTrue);
  });

  testWidgets('tap with null onTap does not throw', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TierBadge(level: 0))),
    );
    await tester.tap(find.byType(TierBadge));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
