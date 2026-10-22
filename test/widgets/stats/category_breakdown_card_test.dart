import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/stats/category_breakdown_card.dart';

Quest _q(
  String id, {
  QuestCategory category = QuestCategory.health,
  List<String>? dates,
}) => Quest(
  id: id,
  title: 'quest $id',
  category: category,
  xp: 10,
  completedDates: dates ?? [],
);

void main() {
  testWidgets('renders BY CATEGORY label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoryBreakdownCard(quests: [])),
      ),
    );
    expect(find.text('BY CATEGORY'), findsOneWidget);
  });

  testWidgets('shows "No completions yet" when nothing completed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoryBreakdownCard(quests: [])),
      ),
    );
    expect(find.text('No completions yet'), findsOneWidget);
  });

  testWidgets('renders each category with a completion count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryBreakdownCard(
            quests: [
              _q('a', dates: ['2026-10-13'], category: QuestCategory.health),
              _q('b', dates: ['2026-10-13'], category: QuestCategory.health),
              _q('c', dates: ['2026-10-13'], category: QuestCategory.fitness),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Fitness'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // health count
    expect(find.text('1'), findsOneWidget); // fitness count
  });
}
