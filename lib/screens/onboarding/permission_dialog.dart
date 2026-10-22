import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text_styles.dart';
import '../../services/permission_bootstrapper.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PermissionDialog(),
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
            // ── Pixel Icon ──
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: AppColors.glowPrimary(blur: 16),
              ),
              // Removed 'const' here because Pixel.notification is a getter
              child: Icon(
                Pixel.notification,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Text ──
            const Text(
              'KEEP YOUR STREAK',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'To send daily quest reminders and keep your streak alive in the background, Pixel Quest needs a few permissions.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSizes.xl),

            // ── Allow Button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await PermissionBootstrapper.requestAll();
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: const Text('ALLOW', style: AppTextStyles.button),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Not Now Button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: const Text('LATER', style: AppTextStyles.buttonSm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
