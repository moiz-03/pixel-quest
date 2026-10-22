import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class StreakHeader extends StatelessWidget {
  const StreakHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Pixel.zap, color: AppColors.accentGold, size: 24),
        const SizedBox(width: AppSizes.sm),
        const Expanded(child: Text('STREAK', style: AppTextStyles.h2)),
        IconButton(
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Pixel.close, color: AppColors.textPrimary, size: 20),
        ),
      ],
    );
  }
}
