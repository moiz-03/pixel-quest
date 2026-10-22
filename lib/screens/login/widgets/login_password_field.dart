import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../utils/validators.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final bool enabled;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onSubmitted;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.enabled,
    required this.onToggleObscure,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: Validators.loginPassword,
      enabled: enabled,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Pixel.lock, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(obscure ? Pixel.eye : Pixel.eyeclosed, size: 20),
        ),
      ),
    );
  }
}
