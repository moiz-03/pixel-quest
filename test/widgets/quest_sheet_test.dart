import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/models/quest.dart';
import 'package:pixel_quest/widgets/quest_sheet/quest_sheet.dart';

/// Opens [QuestSheet] inside a modal bottom sheet and returns a way to
/// capture the result once it pops.
///
/// Must be awaited — `tester.pumpWidget` is a guarded call.
Future<QuestSheetResult? Function()> _setupSheet(
  WidgetTester tester, {
  Quest? existing,
}) async {
  QuestSheetResult? captured;

  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              captured = await showModalBottomSheet<QuestSheetResult>(
                context: ctx,
                isScrollControlled: true,
                builder: (_) => QuestSheet(existing: existing),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  return () => captured;
}

void main() {
  testWidgets('add mode shows ADD NEW QUEST and CREATE QUEST', (tester) async {
    await _setupSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('ADD NEW QUEST'), findsOneWidget);
    expect(find.text('CREATE QUEST'), findsOneWidget);
  });

  testWidgets('edit mode shows EDIT QUEST and SAVE CHANGES', (tester) async {
    final existing = Quest(
      id: 'q1',
      title: 'Read',
      category: QuestCategory.selfImprovement,
      xp: 25,
    );
    await _setupSheet(tester, existing: existing);
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('EDIT QUEST'), findsOneWidget);
    expect(find.text('SAVE CHANGES'), findsOneWidget);
  });

  testWidgets('add mode returns QuestSaved on submit', (tester) async {
    final getResult = await _setupSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'My New Quest');
    await tester.tap(find.text('CREATE QUEST'));
    await tester.pumpAndSettle();

    final result = getResult();
    expect(result, isA<QuestSaved>());
    expect((result as QuestSaved).quest.title, 'My New Quest');
    expect(result.quest.id, isNotEmpty);
  });

  testWidgets('edit mode returns a new Quest (original untouched)', (
    tester,
  ) async {
    final existing = Quest(
      id: 'q1',
      title: 'Old Title',
      category: QuestCategory.health,
      xp: 10,
    );
    final getResult = await _setupSheet(tester, existing: existing);
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'New Title');
    await tester.tap(find.text('SAVE CHANGES'));
    await tester.pumpAndSettle();

    final result = getResult();
    expect(result, isA<QuestSaved>());
    final saved = (result as QuestSaved).quest;
    expect(saved.id, 'q1');
    expect(saved.title, 'New Title');
    expect(existing.title, 'Old Title'); // original unchanged
  });

  testWidgets('empty title blocks submission', (tester) async {
    final getResult = await _setupSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Leave title empty.
    await tester.tap(find.text('CREATE QUEST'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a quest title'), findsOneWidget);
    expect(getResult(), isNull);
  });
}
