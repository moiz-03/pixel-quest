import 'package:flutter/material.dart';

import '../../../models/tier.dart';
import '../../../theme/app_text_styles.dart';

class NextTierHint extends StatelessWidget {
  final int level;

  const NextTierHint({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final tier = Tier.forLevel(level);
    final next = tier.next;
    if (next == null) return const SizedBox.shrink();

    final remaining = tier.levelsToNext(level);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(next.icon, size: 12, color: next.color),
          const SizedBox(width: 6),
          Text(
            '$remaining ${remaining == 1 ? "level" : "levels"} to ${next.name}',
            style: AppTextStyles.label.copyWith(
              color: next.color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
