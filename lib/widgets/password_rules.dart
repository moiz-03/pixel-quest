import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';

class PasswordRules extends StatelessWidget {
  final String password;

  const PasswordRules({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final rules = [
      _Rule(
        'At least ${Validators.passwordMinLength} characters',
        password.length >= Validators.passwordMinLength,
      ),
      _Rule('Uppercase letter (A-Z)', _hasUpper(password)),
      _Rule('Lowercase letter (a-z)', _hasLower(password)),
      _Rule('Number (0-9)', _hasDigit(password)),
      _Rule('Special character (!@#\$...)', _hasSpecial(password)),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  Icon(
                    r.ok ? Icons.check_circle : Icons.circle_outlined,
                    size: 12,
                    color: r.ok ? AppColors.xpGreen : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.label,
                    style: AppTextStyles.micro.copyWith(
                      color: r.ok ? AppColors.xpGreen : AppColors.textMuted,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasUpper(String v) => RegExp(r'[A-Z]').hasMatch(v);
  bool _hasLower(String v) => RegExp(r'[a-z]').hasMatch(v);
  bool _hasDigit(String v) => RegExp(r'[0-9]').hasMatch(v);
  bool _hasSpecial(String v) => RegExp(r'[^A-Za-z0-9]').hasMatch(v);
}

class _Rule {
  final String label;
  final bool ok;
  const _Rule(this.label, this.ok);
}
