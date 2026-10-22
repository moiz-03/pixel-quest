import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

class PermissionRationaleDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const PermissionRationaleDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onAllow,
    required this.onDeny,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PermissionRationaleDialog(
        title: title,
        description: description,
        icon: icon,
        onAllow: () => Navigator.pop(context, true),
        onDeny: () => Navigator.pop(context, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceHigh,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: AppColors.glowPrimary(blur: 16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.sm),
            Text(
              description,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onAllow,
                child: const Text('ALLOW', style: AppTextStyles.button),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onDeny,
                child: const Text('NOT NOW', style: AppTextStyles.buttonSm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
