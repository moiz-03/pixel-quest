import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../utils/validators.dart';

class RegisterEmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const RegisterEmailField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: Validators.gmail,
      enabled: enabled,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'you@gmail.com',
        prefixIcon: Icon(Pixel.mail, size: 20),
      ),
    );
  }
}
