import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../utils/validators.dart';

class RegisterUsernameField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const RegisterUsernameField({
    super.key,
    required this.controller,
    required this.enabled,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
      autofillHints: const [AutofillHints.newUsername],
      validator: Validators.username,
      enabled: enabled,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Username',
        hintText: 'pixel_hero',
        prefixIcon: Icon(Pixel.user, size: 20),
      ),
    );
  }
}
