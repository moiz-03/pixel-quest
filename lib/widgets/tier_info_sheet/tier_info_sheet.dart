import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../models/tier.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text_styles.dart';
import 'widgets/tier_row.dart';

class TierInfoSheet extends StatelessWidget {
  final int currentLevel;

  const TierInfoSheet({super.key, required this.currentLevel});

  static Future<void> show(BuildContext context, {required int currentLevel}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TierInfoSheet(currentLevel: currentLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = Tier.forLevel(currentLevel);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
        border: Border(
          top: BorderSide(color: AppColors.secondary, width: 2),
          left: BorderSide(color: AppColors.secondary, width: 2),
          right: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handleBar(),
          _header(context, currentTier),
          const SizedBox(height: AppSizes.md),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                0,
                AppSizes.lg,
                AppSizes.xxl,
              ),
              itemCount: Tier.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSizes.md),
              itemBuilder: (_, i) {
                final tier = Tier.values[i];
                return TierRow(
                  tier: tier,
                  isCurrent: tier == currentTier,
                  isUnlocked: currentLevel >= tier.minLevel,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _handleBar() {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.md),
      height: 4,
      width: 44,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
    );
  }

  Widget _header(BuildContext context, Tier currentTier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.xl,
        AppSizes.lg,
        AppSizes.xl,
        AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(currentTier.icon, color: currentTier.color, size: 22),
              const SizedBox(width: AppSizes.sm),
              const Text('RANKS', style: AppTextStyles.h2),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Pixel.close,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'You are ${currentTier.name} · Level $currentLevel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(
              color: currentTier.color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Complete quests to earn XP and climb the ranks.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
