import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/stats/month_heatmap.dart';

/// Pumps [MonthHeatmap] inside a tall viewport so the 5–6 week grid
/// has room without overflowing.
Future<void> _pumpHeatmap(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: MonthHeatmap(quests: [])),
    ),
  );
}

void main() {
  testWidgets('renders THIS MONTH header', (tester) async {
    await _pumpHeatmap(tester);
    expect(find.text('THIS MONTH'), findsOneWidget);
  });

  testWidgets('renders the weekday column header', (tester) async {
    await _pumpHeatmap(tester);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
  });

  testWidgets('renders LESS / MORE / TODAY legend', (tester) async {
    await _pumpHeatmap(tester);
    expect(find.text('LESS'), findsOneWidget);
    expect(find.text('MORE'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });
}
