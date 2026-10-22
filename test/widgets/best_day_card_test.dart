import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/stats/best_day_card.dart';

Quest _q(String id, {List<String>? dates}) => Quest(
  id: id,
  title: 'quest $id',
  category: QuestCategory.health,
  xp: 10,
  completedDates: dates ?? [],
);

void main() {
  testWidgets('renders BEST DAY label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BestDayCard(quests: [])),
      ),
    );
    expect(find.text('BEST DAY'), findsOneWidget);
  });

  testWidgets('shows "Not enough data yet" when no completions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BestDayCard(quests: [])),
      ),
    );
    expect(find.text('Not enough data yet'), findsOneWidget);
  });

  testWidgets('renders the best weekday when data exists', (tester) async {
    // 2026-10-13 is a Tuesday → weekday 2 → "TUE"
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BestDayCard(
            quests: [
              _q('a', dates: ['2026-10-13']),
            ],
          ),
        ),
      ),
    );
    expect(find.textContaining('TUE'), findsOneWidget);
  });
}
