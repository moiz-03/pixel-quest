import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/home_header.dart';
import 'package:pixel_quest/widgets/tier_badge.dart';

void main() {
  testWidgets('renders PIXELQUEST title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeHeader(level: 0, onSettingsTap: () {})),
      ),
    );
    expect(find.text('PIXELQUEST'), findsOneWidget);
  });

  testWidgets('renders tier badge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeHeader(level: 0, onSettingsTap: () {})),
      ),
    );
    expect(find.byType(TierBadge), findsOneWidget);
  });

  testWidgets('tier badge reflects level', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeHeader(level: 10, onSettingsTap: () {})),
      ),
    );
    final badge = tester.widget<TierBadge>(find.byType(TierBadge));
    expect(badge.level, 10);
  });

  testWidgets('settings icon tap fires onSettingsTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeHeader(level: 0, onSettingsTap: () => tapped = true),
        ),
      ),
    );
    await tester.tap(find.byType(IconButton));
    expect(tapped, isTrue);
  });
}
