import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/stat_card.dart';

void main() {
  testWidgets('renders value and label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(icon: Icon(Icons.star), value: '42', label: 'STREAK'),
        ),
      ),
    );
    expect(find.text('42'), findsOneWidget);
    expect(find.text('STREAK'), findsOneWidget);
  });

  testWidgets('without onTap → no InkWell', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(icon: Icon(Icons.star), value: '1', label: 'X'),
        ),
      ),
    );
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('with onTap → wrapped in InkWell, tap fires', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatCard(
            icon: const Icon(Icons.star),
            value: '1',
            label: 'X',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });
}
