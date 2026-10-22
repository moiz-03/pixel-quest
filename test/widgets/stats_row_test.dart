import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/stat_card.dart';
import 'package:pixel_quest/screens/home/widgets/stats_row.dart';

void main() {
  testWidgets('renders 2 stat cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatsRow(streak: 0, totalXp: 0, streakHistory: const {}),
        ),
      ),
    );
    expect(find.byType(StatCard), findsNWidgets(2));
  });

  testWidgets('shows streak value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatsRow(streak: 12, totalXp: 0, streakHistory: const {}),
        ),
      ),
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('STREAK'), findsOneWidget);
  });

  testWidgets('shows total XP value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatsRow(streak: 0, totalXp: 1750, streakHistory: const {}),
        ),
      ),
    );
    expect(find.text('1750'), findsOneWidget);
    expect(find.text('TOTAL XP'), findsOneWidget);
  });

  testWidgets('streak card is tappable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatsRow(
            streak: 5,
            totalXp: 0,
            streakHistory: const {'2026-10-14'},
          ),
        ),
      ),
    );
    // First StatCard (streak) has onTap; second (total xp) does not.
    final cards = tester.widgetList<StatCard>(find.byType(StatCard)).toList();
    expect(cards[0].onTap, isNotNull);
    expect(cards[1].onTap, isNull);
  });
}
