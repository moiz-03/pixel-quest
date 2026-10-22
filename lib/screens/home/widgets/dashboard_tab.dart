import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../models/quest.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';
import 'home_header.dart';
import 'new_quest_button.dart';
import 'next_tier_hint.dart';
import 'quest_list.dart';
import 'stats_row.dart';
import 'xp_bar.dart';

class DashboardTab extends StatelessWidget {
  final int level;
  final int currentXp;
  final int xpToNext;
  final int streak;
  final int totalXp;
  final int availableXp;
  final Set<String> streakHistory;
  final bool loaded;
  final List<Quest> quests;
  final VoidCallback onAddQuest;
  final void Function(Quest quest) onEditQuest;
  final void Function(Quest quest) onToggleQuest;
  final VoidCallback onSettingsTap;
  final VoidCallback onOpenShop;

  final Quest? suggestedQuest;
  final int suggestedQuestStreak;
  final VoidCallback? onAcceptSuggestion;
  final VoidCallback? onDismissSuggestion;

  const DashboardTab({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpToNext,
    required this.streak,
    required this.totalXp,
    required this.availableXp,
    required this.streakHistory,
    required this.loaded,
    required this.quests,
    required this.onAddQuest,
    required this.onEditQuest,
    required this.onToggleQuest,
    required this.onSettingsTap,
    required this.onOpenShop,
    this.suggestedQuest,
    this.suggestedQuestStreak = 0,
    this.onAcceptSuggestion,
    this.onDismissSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(level: level, onSettingsTap: onSettingsTap),
          const SizedBox(height: AppSizes.lg),
          XpBar(currentXp: currentXp, xpToNext: xpToNext),
          const SizedBox(height: AppSizes.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpenShop,
              icon: const Icon(
                Pixel.coin,
                size: 16,
                color: AppColors.accentGold,
              ),
              label: Text(
                'SHOP · $availableXp XP',
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.accentGold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          StatsRow(
            streak: streak,
            totalXp: totalXp,
            streakHistory: streakHistory,
          ),
          const SizedBox(height: AppSizes.md),
          NextTierHint(level: level),
          const SizedBox(height: AppSizes.lg),
          NewQuestButton(onPressed: onAddQuest),
          const SizedBox(height: AppSizes.lg),
          RepaintBoundary(
            child: QuestList(
              loaded: loaded,
              quests: quests,
              onEdit: onEditQuest,
              onToggle: onToggleQuest,
              suggestedQuest: suggestedQuest,
              suggestedQuestStreak: suggestedQuestStreak,
              onAcceptSuggestion: onAcceptSuggestion,
              onDismissSuggestion: onDismissSuggestion,
            ),
          ),
        ],
      ),
    );
  }
}
