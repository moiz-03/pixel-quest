import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/quest_list.dart';
import 'package:pixel_quest/screens/home/widgets/quest_tile.dart';
import 'package:pixel_quest/screens/home/widgets/suggestion_card.dart';
import 'package:pixel_quest/widgets/quest_skeleton/quest_skeleton.dart';
import 'package:pixel_quest/widgets/quest_tile_animated.dart';

Quest _q(String id) =>
    Quest(id: id, title: 'quest $id', category: QuestCategory.health, xp: 10);

void main() {
  testWidgets('not loaded → shows skeleton', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestList(
            loaded: false,
            quests: const [],
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(QuestSkeleton), findsOneWidget);
  });

  testWidgets('loaded but empty → shows empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestList(
            loaded: true,
            quests: const [],
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('NO QUESTS YET'), findsOneWidget);
    expect(find.byType(QuestTile), findsNothing);
  });

  testWidgets('loaded with quests → renders tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestList(
            loaded: true,
            quests: [_q('1'), _q('2'), _q('3')],
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(QuestTile), findsNWidgets(3));
    expect(find.byType(QuestTileAnimated), findsNWidgets(3));
  });

  testWidgets('suggestion card renders above quest tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestList(
            loaded: true,
            quests: [_q('1')],
            onEdit: (_) {},
            onToggle: (_) {},
            suggestedQuest: _q('1'),
            suggestedQuestStreak: 3,
            onAcceptSuggestion: () {},
            onDismissSuggestion: () {},
          ),
        ),
      ),
    );
    expect(find.byType(SuggestionCard), findsOneWidget);
    expect(find.textContaining('3-DAY STREAK'), findsOneWidget);
  });

  testWidgets('no suggestion card when suggestions are null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestList(
            loaded: true,
            quests: [_q('1')],
            onEdit: (_) {},
            onToggle: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(SuggestionCard), findsNothing);
  });

  testWidgets('skeleton shows even when suggestions are configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestList(
            loaded: false,
            quests: const [],
            onEdit: (_) {},
            onToggle: (_) {},
            suggestedQuest: _q('1'),
            suggestedQuestStreak: 3,
            onAcceptSuggestion: () {},
            onDismissSuggestion: () {},
          ),
        ),
      ),
    );
    expect(find.byType(QuestSkeleton), findsOneWidget);
    expect(find.byType(SuggestionCard), findsNothing);
  });
}
