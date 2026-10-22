import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../../models/quest.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_sizes.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/stats_calculator.dart';

class BestDayCard extends StatelessWidget {
  final List<Quest> quests;

  const BestDayCard({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    final best = StatsCalculator.bestWeekday(quests);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Pixel.zap, color: AppColors.accentGold, size: 20),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('BEST DAY', style: AppTextStyles.label),
                const SizedBox(height: 3),
                Text(
                  best == null
                      ? 'Not enough data yet'
                      : 'You crush it on ${StatsCalculator.weekdayName(best)}s',
                  style: AppTextStyles.body.copyWith(height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
