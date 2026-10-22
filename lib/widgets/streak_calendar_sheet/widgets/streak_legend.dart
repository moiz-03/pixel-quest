import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';
import 'streak_legend_item.dart';

class StreakLegend extends StatelessWidget {
  final int currentStreak;
  final int maintained;
  final int broken;

  const StreakLegend({
    super.key,
    required this.currentStreak,
    required this.maintained,
    required this.broken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current streak banner
          Row(
            children: [
              const Icon(Pixel.zap, color: AppColors.accentGold, size: 18),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  '$currentStreak DAY STREAK',
                  style: AppTextStyles.h3.copyWith(color: AppColors.accentGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSizes.sm),
          // Legend items
          Row(
            children: [
              Expanded(
                child: StreakLegendItem(
                  icon: Pixel.check,
                  color: AppColors.xpGreen,
                  label: '$maintained MAINTAINED',
                ),
              ),
              Expanded(
                child: StreakLegendItem(
                  icon: Pixel.close,
                  color: AppColors.accentDanger,
                  label: '$broken MISSED',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
