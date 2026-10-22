import 'package:flutter/material.dart';

import '../../../models/quest.dart';
import '../../../theme/app_sizes.dart';

class QuestCategoryIcon extends StatelessWidget {
  final Quest quest;

  const QuestCategoryIcon({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: quest.category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Icon(quest.category.icon, color: quest.category.color, size: 20),
    );
  }
}
