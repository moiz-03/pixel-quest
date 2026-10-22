import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';

class NewQuestButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewQuestButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.xpGreen,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Pixel.plus, size: 20),
            SizedBox(width: 8),
            Text('NEW QUEST'),
          ],
        ),
      ),
    );
  }
}
