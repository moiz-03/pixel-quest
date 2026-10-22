import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/stat_card.dart';
import 'package:pixel_quest/screens/home/widgets/stats/stats_summary_row.dart';

void main() {
  testWidgets('renders four StatCards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsSummaryRow(
            level: 3,
            totalXp: 500,
            currentStreak: 5,
            longestStreak: 10,
          ),
        ),
      ),
    );
    expect(find.byType(StatCard), findsNWidgets(4));
  });

  testWidgets('renders all four labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsSummaryRow(
            level: 3,
            totalXp: 500,
            currentStreak: 5,
            longestStreak: 10,
          ),
        ),
      ),
    );
    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('TOTAL XP'), findsOneWidget);
    expect(find.text('CURRENT STREAK'), findsOneWidget);
    expect(find.text('LONGEST STREAK'), findsOneWidget);
  });

  testWidgets('renders the numeric values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsSummaryRow(
            level: 3,
            totalXp: 500,
            currentStreak: 5,
            longestStreak: 10,
          ),
        ),
      ),
    );
    expect(find.text('3'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('renders zero values without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsSummaryRow(
            level: 0,
            totalXp: 0,
            currentStreak: 0,
            longestStreak: 0,
          ),
        ),
      ),
    );
    expect(find.byType(StatCard), findsNWidgets(4));
  });
}
