import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';

class StreakLegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const StreakLegendItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.micro.copyWith(color: color, fontSize: 7),
          ),
        ),
      ],
    );
  }
}
