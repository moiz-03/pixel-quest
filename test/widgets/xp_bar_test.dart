import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/xp_bar.dart';
import 'package:pixel_quest/theme/app_colors.dart';

Widget _wrap(int current, int next) => MaterialApp(
  home: Scaffold(
    body: XpBar(currentXp: current, xpToNext: next),
  ),
);

void main() {
  testWidgets('shows current/total XP label', (tester) async {
    await tester.pumpWidget(_wrap(25, 100));
    expect(find.textContaining('25/100'), findsOneWidget);
  });

  testWidgets('renders 10 segments', (tester) async {
    await tester.pumpWidget(_wrap(50, 100));
    // The bar is a Row of Expanded containers; count the decorated containers.
    final containers = tester.widgetList<Container>(find.byType(Container));
    final segmentContainers = containers.where((c) {
      final d = c.decoration;
      return d is BoxDecoration &&
          (d.color == AppColors.xpGreen || d.color == AppColors.surfaceHigh);
    });
    expect(segmentContainers.length, 10);
  });

  testWidgets('0 xp → all segments unfilled', (tester) async {
    await tester.pumpWidget(_wrap(0, 100));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final filled = containers.where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.color == AppColors.xpGreen;
    });
    expect(filled.length, 0);
  });

  testWidgets('50 xp of 100 → 5 segments filled', (tester) async {
    await tester.pumpWidget(_wrap(50, 100));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final filled = containers.where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.color == AppColors.xpGreen;
    });
    expect(filled.length, 5);
  });

  testWidgets('100 xp of 100 → all 10 segments filled', (tester) async {
    await tester.pumpWidget(_wrap(100, 100));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final filled = containers.where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.color == AppColors.xpGreen;
    });
    expect(filled.length, 10);
  });

  testWidgets('current > next clamps to 10 segments', (tester) async {
    await tester.pumpWidget(_wrap(200, 100));
    final containers = tester.widgetList<Container>(find.byType(Container));
    final filled = containers.where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.color == AppColors.xpGreen;
    });
    expect(filled.length, 10);
  });
}
