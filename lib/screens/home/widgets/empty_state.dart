import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
      child: Column(
        children: [
          const Icon(Pixel.flag, size: 56, color: AppColors.textMuted),
          const SizedBox(height: AppSizes.lg),
          const Text('NO QUESTS YET', style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Tap NEW QUEST to start your first adventure.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
