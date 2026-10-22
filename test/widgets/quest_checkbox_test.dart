import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/screens/home/widgets/quest_checkbox.dart';
import 'package:pixel_quest/theme/app_colors.dart';
import 'package:pixel_quest/utils/date_helper.dart';

Quest _q({bool completed = false}) => Quest(
  id: '1',
  title: 'x',
  category: QuestCategory.health,
  xp: 10,
  completedDates: completed ? [DateHelper.todayIso()] : [],
);

void main() {
  testWidgets('unchecked quest → no check icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestCheckbox(quest: _q(), onToggle: (_) {}),
        ),
      ),
    );
    // Pixel.check icon should not be present
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('checked quest → renders a check icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestCheckbox(quest: _q(completed: true), onToggle: (_) {}),
        ),
      ),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('checked box uses xpGreen background', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestCheckbox(quest: _q(completed: true), onToggle: (_) {}),
        ),
      ),
    );
    final containers = tester.widgetList<Container>(find.byType(Container));
    final hasGreen = containers.any((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.color == AppColors.xpGreen;
    });
    expect(hasGreen, isTrue);
  });

  testWidgets('tap fires onToggle with the quest', (tester) async {
    final quest = _q();
    Quest? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestCheckbox(quest: quest, onToggle: (q) => received = q),
        ),
      ),
    );
    await tester.tap(find.byType(GestureDetector));
    expect(received, same(quest));
  });
}
