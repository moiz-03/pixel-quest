import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../../models/quest.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_sizes.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/stats_calculator.dart';

class TopQuestsCard extends StatelessWidget {
  final List<Quest> quests;

  const TopQuestsCard({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    final top = StatsCalculator.topQuests(quests, limit: 3);

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
              Icon(Pixel.trophy, color: AppColors.accentGold, size: 20),
              SizedBox(width: AppSizes.sm),
              Text('TOP QUESTS', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (top.isEmpty)
            Text(
              'No completions yet',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            )
          else
            for (var i = 0; i < top.length; i++) ...[
              _row(i + 1, top[i]),
              if (i < top.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  Widget _row(int rank, Quest quest) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.xpGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$rank',
            style: AppTextStyles.micro.copyWith(
              color: AppColors.xpGreen,
              fontSize: 8,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            quest.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(height: 1.2),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          '${quest.completedDates.length}x',
          style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
