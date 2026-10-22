import 'package:flutter/material.dart';

import '../models/tier.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

class TierBadge extends StatelessWidget {
  final int level;
  final VoidCallback? onTap;

  const TierBadge({super.key, required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tier = Tier.forLevel(level);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: tier.color, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tier.icon, color: tier.color, size: 11),
                  const SizedBox(width: 4),
                  Text(
                    tier.name,
                    style: AppTextStyles.micro.copyWith(
                      color: tier.color,
                      fontSize: 7,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                level.toString().padLeft(2, '0'),
                style: AppTextStyles.h3.copyWith(height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
