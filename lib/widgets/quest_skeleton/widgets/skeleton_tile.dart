import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';

class SkeletonTile extends StatelessWidget {
  final double pulse;

  const SkeletonTile({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Row(
          children: [
            // Category icon square
            _block(width: 40, height: 40, radius: AppSizes.radiusSm),
            const SizedBox(width: AppSizes.md),
            // Title + badge lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _block(width: 140, height: 10, radius: 3),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _block(width: 60, height: 10, radius: 3),
                      const SizedBox(width: AppSizes.sm),
                      _block(width: 44, height: 10, radius: 3),
                    ],
                  ),
                ],
              ),
            ),
            // Checkbox square
            _block(width: 24, height: 24, radius: 6),
          ],
        ),
      ),
    );
  }

  Widget _block({
    required double width,
    required double height,
    required double radius,
  }) {
    return Opacity(
      opacity: pulse,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
