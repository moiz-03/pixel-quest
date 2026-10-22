import 'package:flutter/material.dart';

import '../../../theme/app_sizes.dart';

class RegisterButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onPressed;

  const RegisterButton({
    super.key,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: busy ? null : onPressed,
        child: const Text('REGISTER'),
      ),
    );
  }
}
