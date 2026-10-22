import 'package:flutter/material.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/stats/best_day_card.dart';
import 'package:pixel_quest/screens/home/widgets/stats/category_breakdown_card.dart';
import 'package:pixel_quest/screens/home/widgets/stats/month_heatmap.dart';
import 'package:pixel_quest/screens/home/widgets/stats/stats_summary_row.dart';
import 'package:pixel_quest/screens/home/widgets/stats/top_quests_card.dart';
import 'package:pixel_quest/screens/home/widgets/stats/week_bar_chart.dart';
import 'package:pixel_quest/theme/app_colors.dart';
import 'package:pixel_quest/theme/app_sizes.dart';
import 'package:pixel_quest/theme/app_text_styles.dart';
import 'package:pixel_quest/utils/stats_calculator.dart';
import 'package:pixelarticons/pixelarticons.dart';

class StatsScreen extends StatelessWidget {
  final int level;
  final int totalXp;
  final int currentStreak;
  final Set<String> streakHistory;
  final List<Quest> quests;
  final bool loaded;

  const StatsScreen({
    super.key,
    required this.level,
    required this.totalXp,
    required this.currentStreak,
    required this.streakHistory,
    required this.quests,
    required this.loaded,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.md,
          AppSizes.lg,
          AppSizes.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.sm),
            const Row(
              children: [
                Icon(Pixel.chartbar, color: AppColors.accentGold, size: 22),
                SizedBox(width: AppSizes.sm),
                Text('STATS', style: AppTextStyles.h2),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            StatsSummaryRow(
              level: level,
              totalXp: totalXp,
              currentStreak: currentStreak,
              longestStreak: StatsCalculator.longestStreak(streakHistory),
            ),
            const SizedBox(height: AppSizes.lg),

            WeekBarChart(quests: quests),
            const SizedBox(height: AppSizes.lg),

            MonthHeatmap(quests: quests),
            const SizedBox(height: AppSizes.lg),

            BestDayCard(quests: quests),
            const SizedBox(height: AppSizes.md),

            TopQuestsCard(quests: quests),
            const SizedBox(height: AppSizes.md),

            CategoryBreakdownCard(quests: quests),
          ],
        ),
      ),
    );
  }
}
