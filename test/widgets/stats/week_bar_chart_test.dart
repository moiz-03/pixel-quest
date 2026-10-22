import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/stats/week_bar_chart.dart';

void main() {
  testWidgets('renders LAST 7 DAYS header', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WeekBarChart(quests: [])),
      ),
    );
    expect(find.text('LAST 7 DAYS'), findsOneWidget);
  });

  testWidgets('renders a bar for each of 7 days', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WeekBarChart(quests: [])),
      ),
    );
    // With zero completions, each bar shows '0'.
    expect(find.text('0'), findsNWidgets(7));
  });

  testWidgets('does not overflow with tall bar data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WeekBarChart(quests: [])),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
