import 'package:flutter/material.dart';

import '../../../../models/quest.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_sizes.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/date_helper.dart';
import '../../../../utils/stats_calculator.dart';

class MonthHeatmap extends StatelessWidget {
  final List<Quest> quests;

  const MonthHeatmap({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    final days = StatsCalculator.currentMonthDays(quests);
    final todayIso = DateHelper.todayIso();
    final now = DateTime.now();
    final monthLabel = _monthLabel(now.month, now.year);

    // Weekday-aligned grid: column 0 = Monday, column 6 = Sunday.
    final startWeekday = DateTime.parse(days.first.iso).weekday;
    final leadingPad = startWeekday - 1;

    final list = <({String iso, int count})?>[
      ...List<({String iso, int count})?>.filled(leadingPad, null),
      ...days,
    ];

    final trailingPad = (7 - (list.length % 7)) % 7;
    list.addAll(List<({String iso, int count})?>.filled(trailingPad, null));

    final weeks = list.length ~/ 7;

    return RepaintBoundary(
      child: Container(
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
              children: [
                const Text('THIS MONTH', style: AppTextStyles.label),
                const Spacer(),
                Text(
                  monthLabel,
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 7,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Weekday header: M T W T F S S
            Row(
              children: [
                for (var d = 0; d < 7; d++) ...[
                  Expanded(
                    child: Center(
                      child: Text(
                        _weekdayLetter(d + 1),
                        style: AppTextStyles.micro.copyWith(
                          fontSize: 7,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  if (d < 6) const SizedBox(width: 3),
                ],
              ],
            ),
            const SizedBox(height: 3),

            // Week rows
            for (var w = 0; w < weeks; w++) ...[
              Row(
                children: [
                  for (var d = 0; d < 7; d++) ...[
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _Cell(data: list[w * 7 + d], todayIso: todayIso),
                      ),
                    ),
                    if (d < 6) const SizedBox(width: 3),
                  ],
                ],
              ),
              if (w < weeks - 1) const SizedBox(height: 3),
            ],

            const SizedBox(height: AppSizes.md),
            const _Legend(),
          ],
        ),
      ),
    );
  }

  String _weekdayLetter(int weekday) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    if (weekday < 1 || weekday > 7) return '?';
    return letters[weekday - 1];
  }

  String _monthLabel(int month, int year) {
    const names = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${names[month - 1]} $year';
  }
}

class _Cell extends StatelessWidget {
  final ({String iso, int count})? data;
  final String todayIso;

  const _Cell({required this.data, required this.todayIso});

  @override
  Widget build(BuildContext context) {
    // Empty padding cell — outside the month.
    if (data == null) return const SizedBox.shrink();

    final iso = data!.iso;
    final count = data!.count;
    final dayNumber = int.tryParse(iso.substring(8)) ?? 0;
    final isToday = iso == todayIso;
    final isFuture = iso.compareTo(todayIso) > 0;

    // Future day: no fill, no border, dimmed number.
    if (isFuture) {
      return Center(
        child: Text(
          '$dayNumber',
          style: AppTextStyles.micro.copyWith(
            fontSize: 7,
            color: AppColors.textMuted.withValues(alpha: 0.4),
            height: 1,
          ),
        ),
      );
    }

    final color = _colorFor(count);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.2)
              : (count > 0 ? color : AppColors.surface), // No border!
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text(
            '$dayNumber',
            style: AppTextStyles.micro.copyWith(
              fontSize: 7,
              color: count > 0 || isToday
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Color _colorFor(int count) {
    if (count == 0) return Colors.transparent;
    if (count == 1) return AppColors.xpGreen.withValues(alpha: 0.28);
    if (count == 2) return AppColors.xpGreen.withValues(alpha: 0.55);
    return AppColors.xpGreen;
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('LESS', style: _labelStyle),
        const SizedBox(width: 6),
        _dot(Colors.transparent, AppColors.border),
        const SizedBox(width: 3),
        _dot(AppColors.xpGreen.withValues(alpha: 0.28), null),
        const SizedBox(width: 3),
        _dot(AppColors.xpGreen.withValues(alpha: 0.55), null),
        const SizedBox(width: 3),
        _dot(AppColors.xpGreen, null),
        const SizedBox(width: 6),
        Text('MORE', style: _labelStyle),
        const SizedBox(width: 12),
        Text('TODAY', style: _labelStyle.copyWith(color: AppColors.primary)),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
      ],
    );
  }

  TextStyle get _labelStyle =>
      AppTextStyles.micro.copyWith(fontSize: 7, color: AppColors.textMuted);

  Widget _dot(Color color, Color? border) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
      border: Border.all(
        color: border ?? color.withValues(alpha: 0.8),
        width: 1,
      ),
    ),
  );
}
