import 'package:flutter/material.dart';

import '../../../theme/app_sizes.dart';

class SplashBottomSection extends StatelessWidget {
  final bool checking;
  final bool showAuthButtons;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const SplashBottomSection({
    super.key,
    required this.checking,
    required this.showAuthButtons,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const SizedBox(
        height: AppSizes.buttonHeight,
        child: Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (showAuthButtons) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: onLogin,
              child: const Text('LOGIN'),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: OutlinedButton(
              onPressed: onRegister,
              child: const Text('REGISTER'),
            ),
          ),
        ],
      );
    }

    return const SizedBox(height: AppSizes.buttonHeight);
  }
}
