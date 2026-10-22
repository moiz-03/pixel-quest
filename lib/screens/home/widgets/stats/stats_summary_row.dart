import 'package:flutter/material.dart';
import 'package:pixel_quest/screens/home/widgets/stat_card.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_sizes.dart';

class StatsSummaryRow extends StatelessWidget {
  final int level;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;

  const StatsSummaryRow({
    super.key,
    required this.level,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: const Icon(
                  Pixel.bullseye,
                  color: AppColors.accentGold,
                  size: 20,
                ),
                value: '$level',
                label: 'LEVEL',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: StatCard(
                icon: const Icon(
                  Pixel.coin,
                  color: AppColors.accentGold,
                  size: 20,
                ),
                value: '$totalXp',
                label: 'TOTAL XP',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: const Icon(
                  Pixel.zap,
                  color: AppColors.accentGold,
                  size: 20,
                ),
                value: '$currentStreak',
                label: 'CURRENT STREAK',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: StatCard(
                icon: const Icon(
                  Pixel.anchor,
                  color: AppColors.accentGold,
                  size: 20,
                ),
                value: '$longestStreak',
                label: 'LONGEST STREAK',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
