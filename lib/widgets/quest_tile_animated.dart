import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps a child so it fades + slides in on first build.
/// Staggers based on [index] so a list looks like it's assembling.
class QuestTileAnimated extends StatefulWidget {
  final int index;
  final Widget child;

  const QuestTileAnimated({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<QuestTileAnimated> createState() => _QuestTileAnimatedState();
}

class _QuestTileAnimatedState extends State<QuestTileAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger: each tile waits 60ms longer than the previous one.
    // Using a Timer (not Future.delayed) so we can cancel on dispose.
    _staggerTimer = Timer(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // ← Add this
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
