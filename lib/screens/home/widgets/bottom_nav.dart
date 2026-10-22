import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import 'nav_item.dart';

class BottomNav extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  const BottomNav({
    super.key,
    required this.tabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundAlt,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              NavItem(
                icon: Pixel.home,
                label: 'QUESTS',
                active: tabIndex == 0,
                onTap: () => onTabChanged(0),
              ),
              NavItem(
                icon: Pixel.chartbar,
                label: 'STATS',
                active: tabIndex == 1,
                onTap: () => onTabChanged(1),
              ),
              NavItem(
                icon: Pixel.sliders,
                label: 'SETTINGS',
                active: tabIndex == 2,
                onTap: () => onTabChanged(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
