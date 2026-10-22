import 'package:flutter/material.dart';

import '../../../models/quest.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class QuestTitleBlock extends StatelessWidget {
  final Quest quest;

  const QuestTitleBlock({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          quest.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(height: 1.2),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: quest.category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quest.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.micro.copyWith(
                    color: quest.category.color,
                    fontSize: 7,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              '+${quest.xp} XP',
              style: AppTextStyles.micro.copyWith(color: AppColors.accentGold),
            ),
          ],
        ),
      ],
    );
  }
}
