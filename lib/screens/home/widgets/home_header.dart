import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/tier_badge.dart';
import '../../../widgets/tier_info_sheet/tier_info_sheet.dart';

class HomeHeader extends StatelessWidget {
  final int level;
  final VoidCallback onSettingsTap;

  const HomeHeader({
    super.key,
    required this.level,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TierBadge(
          level: level,
          onTap: () => TierInfoSheet.show(context, currentLevel: level),
        ),
        const Spacer(),
        const Text(
          'PIXELQUEST',
          style: TextStyle(
            fontFamily: AppTextStyles.pixelFont,
            fontSize: AppSizes.fontXl,
            height: 1.6,
            letterSpacing: 1,
            color: AppColors.titleYellow,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(
            Pixel.sliders,
            color: AppColors.textPrimary,
            size: 22,
          ),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
