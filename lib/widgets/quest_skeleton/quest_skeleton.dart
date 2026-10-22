import 'package:flutter/material.dart';

import 'widgets/skeleton_tile.dart';

/// A pulsing grey placeholder that mimics the shape of a quest tile.
/// Shows while the real list is loading so the screen never feels empty.
class QuestSkeleton extends StatefulWidget {
  final int count;

  const QuestSkeleton({super.key, this.count = 4});

  @override
  State<QuestSkeleton> createState() => _QuestSkeletonState();
}

class _QuestSkeletonState extends State<QuestSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        // Pulse between 0.4 and 0.9 opacity.
        final pulse = 0.4 + (_ctrl.value * 0.5);
        return Column(
          children: List.generate(
            widget.count,
            (i) => SkeletonTile(pulse: pulse),
          ),
        );
      },
    );
  }
}
