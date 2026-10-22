import 'package:flutter/material.dart';

import '../../../models/tier.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class TierRow extends StatelessWidget {
  final Tier tier;
  final bool isCurrent;
  final bool isUnlocked;

  const TierRow({
    super.key,
    required this.tier,
    required this.isCurrent,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isUnlocked ? 1.0 : 0.42;
    final borderColor = isCurrent
        ? tier.color
        : (isUnlocked ? tier.color.withValues(alpha: 0.35) : AppColors.border);
    final borderWidth = isCurrent ? 1.8 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isCurrent
            ? tier.color.withValues(alpha: 0.08)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: tier.color.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Opacity(
        opacity: opacity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tierIcon(),
            const SizedBox(width: AppSizes.md),
            Expanded(child: _tierDetails()),
            if (isCurrent) _currentChip(),
          ],
        ),
      ),
    );
  }

  Widget _tierIcon() {
    return Container(
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tier.color.withValues(alpha: 0.5)),
      ),
      child: Icon(tier.icon, color: tier.color, size: 22),
    );
  }

  Widget _tierDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tier.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h3.copyWith(color: tier.color),
        ),
        const SizedBox(height: 4),
        Text(
          _levelRangeLabel(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.micro.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tier.flavor,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  String _levelRangeLabel() {
    if (tier.minLevel == tier.maxLevel) {
      return 'LEVEL ${tier.minLevel}';
    }
    if (tier.maxLevel >= 999999) {
      return 'LEVEL ${tier.minLevel}+';
    }
    return 'LEVELS ${tier.minLevel} - ${tier.maxLevel}';
  }

  Widget _currentChip() {
    return Container(
      margin: const EdgeInsets.only(left: AppSizes.sm),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: tier.color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'YOU',
        style: AppTextStyles.micro.copyWith(
          color: Colors.black,
          fontSize: 7,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
