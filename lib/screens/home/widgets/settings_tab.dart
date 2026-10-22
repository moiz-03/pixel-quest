import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class SettingsTab extends StatelessWidget {
  final String username;
  final bool loggingOut;
  final bool deletingAccount;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const SettingsTab({
    super.key,
    required this.username,
    required this.loggingOut,
    required this.deletingAccount,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final busy = loggingOut || deletingAccount;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.lg),
          const Text('SETTINGS', style: AppTextStyles.h1),
          const SizedBox(height: AppSizes.sm),
          Text('Signed in as $username', style: AppTextStyles.bodyMuted),
          const Spacer(),

          // ── Log out ──────────────────────────────────────────────────────
          SizedBox(
            height: AppSizes.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: busy ? null : onLogout,
              icon: loggingOut
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Icon(Pixel.logout, size: 20, color: Colors.white),
              label: const Text('LOG OUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentDanger,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // ── Delete account ───────────────────────────────────────────────
          SizedBox(
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: busy ? null : onDeleteAccount,
              icon: const Icon(
                Pixel.trash,
                size: 20,
                color: AppColors.accentDanger,
              ),
              label: const Text(
                'DELETE ACCOUNT',
                style: TextStyle(color: AppColors.accentDanger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.accentDanger,
                  width: 1.4,
                ),
                foregroundColor: AppColors.accentDanger,
              ),
            ),
          ),
          // TEMPORARY — remove before shipping.
          // Only shows in debug builds so it never reaches users.
          if (const bool.fromEnvironment('dart.vm.product') == false)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.md),
              child: SizedBox(
                height: AppSizes.buttonHeight,
                child: OutlinedButton(
                  onPressed: () {
                    // Deliberate crash to verify Crashlytics is wired.
                    throw Exception('Pixel Quest Crashlytics test crash');
                  },
                  child: const Text('TEST CRASH (DEV ONLY)'),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }
}
