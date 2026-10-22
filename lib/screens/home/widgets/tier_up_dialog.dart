import 'package:flutter/material.dart';

import '../../../models/tier.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class TierUpDialog extends StatelessWidget {
  final Tier tier;
  final int level;

  const TierUpDialog({super.key, required this.tier, required this.level});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: tier.color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tier.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: tier.color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: tier.color.withValues(alpha: 0.5),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: Icon(tier.icon, color: tier.color, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'TIER UP!',
                style: TextStyle(
                  fontFamily: AppTextStyles.pixelFont,
                  fontSize: AppSizes.fontLg,
                  height: 1.6,
                  letterSpacing: 3,
                  color: tier.color,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tier.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTextStyles.pixelFont,
                    fontSize: 24,
                    height: 1.4,
                    letterSpacing: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tier.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'LEVEL $level',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tier.flavor,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tier.color,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('ONWARD'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
