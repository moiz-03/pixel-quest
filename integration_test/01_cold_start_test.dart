// ignore_for_file: file_names
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_quest/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start → splash → login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Wait for splash auth buttons.
    final end = DateTime.now().add(const Duration(seconds: 15));
    while (DateTime.now().isBefore(end) &&
        find.text('LOGIN').evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('PIXEL QUEST'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('REGISTER'), findsOneWidget);

    await tester.tap(find.text('LOGIN'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final end2 = DateTime.now().add(const Duration(seconds: 15));
    while (DateTime.now().isBefore(end2) &&
        find.text('WELCOME BACK').evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
