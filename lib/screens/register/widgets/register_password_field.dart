import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../utils/validators.dart';
import '../../../widgets/password_rules.dart';
import '../../../widgets/password_strength_meter.dart';

class RegisterPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final bool enabled;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onSubmitted;
  final bool showRules;

  const RegisterPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.enabled,
    required this.onToggleObscure,
    this.onSubmitted,
    this.showRules = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          validator: Validators.password,
          enabled: enabled,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'At least 8 characters',
            prefixIcon: const Icon(Pixel.lock, size: 20),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(obscure ? Pixel.eye : Pixel.eyeclosed, size: 20),
            ),
          ),
        ),
        if (showRules)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSizes.sm,
                    left: 4,
                    right: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PasswordStrengthMeter(password: value.text),
                      const SizedBox(height: AppSizes.sm),
                      PasswordRules(password: value.text),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
