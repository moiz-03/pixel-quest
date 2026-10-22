import 'package:flutter/material.dart';

import '../../../../models/quest.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_sizes.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/stats_calculator.dart';

class WeekBarChart extends StatelessWidget {
  final List<Quest> quests;

  const WeekBarChart({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    final days = StatsCalculator.lastNDays(quests, days: 7);
    final maxCount = days.fold<int>(1, (m, d) => d.count > m ? d.count : m);

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
          const Text('LAST 7 DAYS', style: AppTextStyles.label),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  Expanded(
                    child: _DayBar(
                      label: _dayLabel(days[i].iso),
                      count: days[i].count,
                      maxCount: maxCount,
                      isToday: i == days.length - 1,
                    ),
                  ),
                  if (i < days.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '?';
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return names[d.weekday - 1];
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;
  final bool isToday;

  const _DayBar({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
    final barColor = isToday ? AppColors.primary : AppColors.xpGreen;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$count',
          style: AppTextStyles.micro.copyWith(
            fontSize: 7,
            color: count > 0 ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio == 0 ? 0.05 : ratio,
              child: RepaintBoundary(
                // ← Add this
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: count > 0 ? barColor : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.micro.copyWith(
            fontSize: 7,
            color: isToday ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
