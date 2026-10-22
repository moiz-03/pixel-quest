import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/widgets/loading_button.dart';

void main() {
  testWidgets('not busy → shows label, no spinner', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingButton(
            busy: false,
            label: 'LOGIN',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isTrue);
  });

  testWidgets('busy → shows spinner, no label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingButton(busy: true, label: 'LOGIN', onPressed: () {}),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });

  testWidgets('busy → button disabled (tap does nothing)', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingButton(
            busy: true,
            label: 'X',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isFalse);
  });
}
