import 'package:flutter/material.dart';
import 'package:pixel_quest/widgets/quest_tile_animated.dart';

import '../../../models/quest.dart';
import '../../../widgets/quest_skeleton/quest_skeleton.dart';
import 'empty_state.dart';
import 'quest_tile.dart';
import 'suggestion_card.dart';

class QuestList extends StatelessWidget {
  final bool loaded;
  final List<Quest> quests;
  final void Function(Quest quest) onEdit;
  final void Function(Quest quest) onToggle;

  /// If non-null, a suggestion card is rendered above the quest tiles.
  final Quest? suggestedQuest;
  final int suggestedQuestStreak;
  final VoidCallback? onAcceptSuggestion;
  final VoidCallback? onDismissSuggestion;

  const QuestList({
    super.key,
    required this.loaded,
    required this.quests,
    required this.onEdit,
    required this.onToggle,
    this.suggestedQuest,
    this.suggestedQuestStreak = 0,
    this.onAcceptSuggestion,
    this.onDismissSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const QuestSkeleton(key: ValueKey('skeleton'), count: 4);
    }
    if (quests.isEmpty) {
      return const KeyedSubtree(key: ValueKey('empty'), child: EmptyState());
    }

    final showSuggestion =
        suggestedQuest != null &&
        onAcceptSuggestion != null &&
        onDismissSuggestion != null;

    return Column(
      key: const ValueKey('list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSuggestion)
          SuggestionCard(
            quest: suggestedQuest!,
            streak: suggestedQuestStreak,
            onAccept: onAcceptSuggestion!,
            onDismiss: onDismissSuggestion!,
          ),
        for (var i = 0; i < quests.length; i++)
          QuestTileAnimated(
            index: i,
            child: QuestTile(
              quest: quests[i],
              onEdit: onEdit,
              onToggle: onToggle,
            ),
          ),
      ],
    );
  }
}
