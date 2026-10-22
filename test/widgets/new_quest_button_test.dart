import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/new_quest_button.dart';

void main() {
  testWidgets('renders NEW QUEST label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NewQuestButton(onPressed: () {})),
      ),
    );
    expect(find.text('NEW QUEST'), findsOneWidget);
  });

  testWidgets('tap fires callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NewQuestButton(onPressed: () => tapped = true)),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isTrue);
  });
}
