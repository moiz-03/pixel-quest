import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../widgets/streak_calendar_sheet/streak_calendar_sheet.dart';
import 'stat_card.dart';

class StatsRow extends StatelessWidget {
  final int streak;
  final int totalXp;
  final Set<String> streakHistory;

  const StatsRow({
    super.key,
    required this.streak,
    required this.totalXp,
    required this.streakHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: const Icon(Pixel.zap, color: AppColors.accentGold, size: 20),
            value: '$streak',
            label: 'STREAK',
            onTap: () => StreakCalendarSheet.show(
              context,
              history: streakHistory,
              currentStreak: streak,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: StatCard(
            icon: const Icon(Pixel.coin, color: AppColors.accentGold, size: 20),
            value: '$totalXp',
            label: 'TOTAL XP',
          ),
        ),
      ],
    );
  }
}
