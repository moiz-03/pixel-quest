import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/stats/top_quests_card.dart';

Quest _q(String id, {String? title, List<String>? dates}) => Quest(
  id: id,
  title: title ?? 'quest $id',
  category: QuestCategory.health,
  xp: 10,
  completedDates: dates ?? [],
);

void main() {
  testWidgets('renders TOP QUESTS label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TopQuestsCard(quests: [])),
      ),
    );
    expect(find.text('TOP QUESTS'), findsOneWidget);
  });

  testWidgets('shows "No completions yet" when nothing completed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TopQuestsCard(quests: [])),
      ),
    );
    expect(find.text('No completions yet'), findsOneWidget);
  });

  testWidgets('renders quest title and completion count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopQuestsCard(
            quests: [
              _q('a', title: 'Read', dates: ['2026-10-12', '2026-10-13']),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('2x'), findsOneWidget);
  });
}
