import 'package:flutter/material.dart';

import '../../../theme/app_sizes.dart';

class LoginInsteadButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onPressed;

  const LoginInsteadButton({
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
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('I ALREADY HAVE AN ACCOUNT', maxLines: 1),
        ),
      ),
    );
  }
}
