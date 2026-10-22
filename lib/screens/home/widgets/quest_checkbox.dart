import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../models/quest.dart';
import '../../../theme/app_colors.dart';

class QuestCheckbox extends StatelessWidget {
  final Quest quest;
  final void Function(Quest quest) onToggle;

  const QuestCheckbox({super.key, required this.quest, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final checked = quest.completed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onToggle(quest),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: checked ? AppColors.xpGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: checked ? AppColors.xpGreen : AppColors.textSecondary,
              width: 2,
            ),
          ),
          child: checked
              ? const Icon(
                  Pixel.check,
                  size: 16,
                  color: AppColors.textOnPrimary,
                )
              : null,
        ),
      ),
    );
  }
}
