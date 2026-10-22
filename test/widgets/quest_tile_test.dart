import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/quest_tile.dart';
import 'package:pixel_quest/theme/app_colors.dart';
import 'package:pixel_quest/utils/date_helper.dart';

Quest _q({
  String id = '1',
  String title = 'Read a Book',
  QuestCategory category = QuestCategory.health,
  int xp = 15,
  bool completed = false,
  String? reminder,
}) => Quest(
  id: id,
  title: title,
  category: category,
  xp: xp,
  completedDates: completed ? [DateHelper.todayIso()] : [],
  reminderTime: reminder,
);

void main() {
  testWidgets('renders quest title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestTile(
            quest: _q(title: 'Gym Time'),
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Gym Time'), findsOneWidget);
  });

  testWidgets('renders XP amount', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestTile(quest: _q(xp: 42), onEdit: (_) {}, onToggle: (_) {}),
        ),
      ),
    );
    expect(find.text('+42 XP'), findsOneWidget);
  });

  testWidgets('renders category label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestTile(
            quest: _q(category: QuestCategory.fitness),
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('FITNESS'), findsOneWidget);
  });

  testWidgets('tap on tile fires onEdit with the quest', (tester) async {
    final quest = _q();
    Quest? edited;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestTile(
            quest: quest,
            onEdit: (q) => edited = q,
            onToggle: (_) {},
          ),
        ),
      ),
    );
    await tester.tap(find.text('Read a Book'));
    expect(edited, same(quest));
  });

  testWidgets('completed quest renders with reduced background color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestTile(
            quest: _q(completed: true),
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );

    // The new implementation uses AnimatedContainer for the background.
    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = container.decoration as BoxDecoration;

    // Verify it uses the "done" background color
    expect(decoration.color, AppColors.cardBgDone);
  });

  testWidgets('incomplete quest renders with normal background color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestTile(quest: _q(), onEdit: (_) {}, onToggle: (_) {}),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = container.decoration as BoxDecoration;

    // Verify it uses the normal background color
    expect(decoration.color, AppColors.cardBg);
  });

  testWidgets('very long title truncates without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestTile(
            quest: _q(title: 'A' * 200),
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
