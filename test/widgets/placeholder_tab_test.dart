import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/placeholder_tab.dart';

void main() {
  testWidgets('renders title and coming soon text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlaceholderTab(title: 'STATS', icon: Icons.bar_chart),
        ),
      ),
    );
    expect(find.text('STATS'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('renders provided icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlaceholderTab(title: 'X', icon: Icons.star),
        ),
      ),
    );
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
