import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/empty_state.dart';

void main() {
  testWidgets('renders NO QUESTS YET heading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyState())),
    );
    expect(find.text('NO QUESTS YET'), findsOneWidget);
  });

  testWidgets('renders hint text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyState())),
    );
    expect(find.textContaining('Tap NEW QUEST'), findsOneWidget);
  });

  testWidgets('renders a flag icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyState())),
    );
    expect(find.byType(Icon), findsOneWidget);
  });
}
