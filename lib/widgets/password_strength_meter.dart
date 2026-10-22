import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  static const int _segments = 4;

  @override
  Widget build(BuildContext context) {
    final score = Validators.passwordStrength(password);
    final color = _colorFor(score);
    final label = _labelFor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Segmented bar ───────────────────────────────────────────────────
        Row(
          children: List.generate(_segments, (i) {
            final filled = i < score;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == _segments - 1 ? 0 : 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  height: 8,
                  decoration: BoxDecoration(
                    color: filled ? color : AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: filled ? color : AppColors.border,
                      width: 1,
                    ),
                    boxShadow: filled
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.45),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 4),

        // ── Label ───────────────────────────────────────────────────────────
        SizedBox(
          height: 10,
          child: Text(
            label,
            style: AppTextStyles.micro.copyWith(
              color: color,
              fontSize: 7,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // ── Color mapping ────────────────────────────────────────────────────────
  Color _colorFor(int s) {
    switch (s) {
      case 1:
        return AppColors.accentDanger;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.accentGold;
      case 4:
        return AppColors.xpGreen;
      default:
        return AppColors.textMuted;
    }
  }

  // ── Label mapping ────────────────────────────────────────────────────────
  String _labelFor(int s) {
    if (password.isEmpty) return '';
    switch (s) {
      case 0:
        return 'TOO SHORT';
      case 1:
        return 'WEAK';
      case 2:
        return 'FAIR';
      case 3:
        return 'STRONG';
      case 4:
        return 'EXCELLENT';
      default:
        return '';
    }
  }
}
