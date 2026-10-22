import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderTab({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: AppSizes.lg),
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: AppSizes.sm),
          const Text('Coming soon', style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}
