import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class RememberForgotRow extends StatelessWidget {
  final bool remember;
  final bool busy;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgotPassword;

  const RememberForgotRow({
    super.key,
    required this.remember,
    required this.busy,
    required this.onRememberChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: remember,
                  onChanged: busy ? null : onRememberChanged,
                  activeColor: AppColors.primary,
                  checkColor: AppColors.textOnPrimary,
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Flexible(
                child: Text(
                  'Remember me',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: busy ? null : onForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Forgot password?', style: AppTextStyles.caption),
        ),
      ],
    );
  }
}
