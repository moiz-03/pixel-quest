import 'package:flutter/material.dart';

import '../../../constants/app_durations.dart';
import '../../../models/quest.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import 'quest_category_icon.dart';
import 'quest_checkbox.dart';
import 'quest_title_block.dart';

class QuestTile extends StatelessWidget {
  final Quest quest;
  final void Function(Quest quest) onEdit;
  final void Function(Quest quest) onToggle;

  const QuestTile({
    super.key,
    required this.quest,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final done = quest.completed;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.md),
        child: AnimatedContainer(
          duration: AppDurations.quick,
          decoration: BoxDecoration(
            color: done ? AppColors.cardBgDone : AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: done
                  ? AppColors.border.withValues(alpha: 0.5)
                  : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              onTap: () => onEdit(quest),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Row(
                  children: [
                    QuestCategoryIcon(quest: quest),
                    const SizedBox(width: AppSizes.md),
                    Expanded(child: QuestTitleBlock(quest: quest)),
                    QuestCheckbox(quest: quest, onToggle: onToggle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
