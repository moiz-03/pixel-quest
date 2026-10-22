import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class XpBar extends StatelessWidget {
  final int currentXp;
  final int xpToNext;

  const XpBar({super.key, required this.currentXp, required this.xpToNext});

  @override
  Widget build(BuildContext context) {
    const segments = 10;
    final ratio = (currentXp / xpToNext).clamp(0.0, 1.0);
    final filled = (ratio * segments).floor();

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'XP  $currentXp/$xpToNext',
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(segments, (i) {
              final isFilled = i < filled;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == segments - 1 ? 0 : 4),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: isFilled
                          ? AppColors.xpGreen
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isFilled ? AppColors.xpGreen : AppColors.border,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
