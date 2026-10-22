import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../../models/quest.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_sizes.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/stats_calculator.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final List<Quest> quests;

  const CategoryBreakdownCard({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    final breakdown = StatsCalculator.categoryBreakdown(quests);
    final total = breakdown.values.fold<int>(0, (a, b) => a + b);
    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Pixel.chartbar, color: AppColors.accentGold, size: 20),
              SizedBox(width: AppSizes.sm),
              Text('BY CATEGORY', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (entries.isEmpty)
            Text(
              'No completions yet',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            )
          else
            for (var i = 0; i < entries.length; i++) ...[
              _bar(entries[i].key, entries[i].value, total),
              if (i < entries.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Widget _bar(QuestCategory cat, int count, int total) {
    final ratio = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(cat.icon, color: cat.color, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                cat.displayName,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$count',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 6,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(color: cat.color),
            ),
          ),
        ),
      ],
    );
  }
}
