import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/suggestion_card.dart';

Quest _quest({String title = 'Gym'}) =>
    Quest(id: 'a', title: title, category: QuestCategory.health, xp: 10);

void main() {
  testWidgets('renders streak and quest title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionCard(
            quest: _quest(title: 'Gym'),
            streak: 3,
            onAccept: () {},
            onDismiss: () {},
          ),
        ),
      ),
    );
    expect(find.textContaining('3-DAY STREAK'), findsOneWidget);
    expect(find.textContaining('"Gym"'), findsOneWidget);
  });

  testWidgets('renders ADD REMINDER button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionCard(
            quest: _quest(),
            streak: 3,
            onAccept: () {},
            onDismiss: () {},
          ),
        ),
      ),
    );
    expect(find.text('ADD REMINDER'), findsOneWidget);
  });

  testWidgets('tap ADD REMINDER fires onAccept', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionCard(
            quest: _quest(),
            streak: 3,
            onAccept: () => tapped = true,
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.text('ADD REMINDER'));
    expect(tapped, isTrue);
  });

  testWidgets('tap X icon fires onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionCard(
            quest: _quest(),
            streak: 3,
            onAccept: () {},
            onDismiss: () => dismissed = true,
          ),
        ),
      ),
    );
    // The X is a GestureDetector containing an Icon. Find the last icon
    // (the close icon) and tap its gesture detector parent.
    final gestureDetectors = find.byType(GestureDetector);
    await tester.tap(gestureDetectors.first);
    expect(dismissed, isTrue);
  });

  testWidgets('different streak values render correctly', (tester) async {
    for (final s in [3, 7, 30]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestionCard(
              quest: _quest(),
              streak: s,
              onAccept: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );
      expect(find.textContaining('$s-DAY STREAK'), findsOneWidget);
    }
  });

  testWidgets('long quest title does not overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionCard(
            quest: _quest(
              title:
                  'A very long quest title that should wrap or truncate nicely',
            ),
            streak: 3,
            onAccept: () {},
            onDismiss: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
