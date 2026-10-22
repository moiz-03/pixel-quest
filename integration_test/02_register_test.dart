// ignore_for_file: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_quest/main.dart' as app;
import 'package:pixel_quest/screens/register/widgets/register_confirm_field.dart';
import 'package:pixel_quest/screens/register/widgets/register_email_field.dart';
import 'package:pixel_quest/screens/register/widgets/register_password_field.dart';
import 'package:pixel_quest/screens/register/widgets/register_username_field.dart';
import 'package:pixel_quest/screens/register/widgets/terms_checkbox_row.dart';
import 'package:pixel_quest/widgets/loading_button.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
  Duration settle = const Duration(milliseconds: 600),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 150));
    if (finder.evaluate().isNotEmpty) {
      final settleEnd = DateTime.now().add(settle);
      while (DateTime.now().isBefore(settleEnd)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      return;
    }
  }
  fail('Timed out waiting for: $finder');
}

Future<void> ensureVisibleAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('register flow → home screen', (tester) async {
    // Fresh state — no cached session.
    SharedPreferences.setMockInitialValues({});
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {}

    app.main();
    await pumpUntilFound(tester, find.text('REGISTER'));

    final unique = DateTime.now().millisecondsSinceEpoch % 100000000;
    final username = 'test_$unique';
    final email = 'test_$unique@gmail.com';
    const password = 'Test@1234';

    // Splash → Register
    await tester.tap(find.text('REGISTER'));
    await pumpUntilFound(tester, find.text('CREATE ACCOUNT'));

    // Fill the form.
    await ensureVisibleAndTap(
      tester,
      find.descendant(
        of: find.byType(RegisterUsernameField),
        matching: find.byType(TextFormField),
      ),
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(RegisterUsernameField),
        matching: find.byType(TextFormField),
      ),
      username,
    );
    await tester.pump(const Duration(milliseconds: 150));

    await ensureVisibleAndTap(
      tester,
      find.descendant(
        of: find.byType(RegisterEmailField),
        matching: find.byType(TextFormField),
      ),
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(RegisterEmailField),
        matching: find.byType(TextFormField),
      ),
      email,
    );
    await tester.pump(const Duration(milliseconds: 150));

    await ensureVisibleAndTap(
      tester,
      find.descendant(
        of: find.byType(RegisterPasswordField),
        matching: find.byType(TextFormField),
      ),
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(RegisterPasswordField),
        matching: find.byType(TextFormField),
      ),
      password,
    );
    await tester.pump(const Duration(milliseconds: 150));

    await ensureVisibleAndTap(
      tester,
      find.descendant(
        of: find.byType(RegisterConfirmField),
        matching: find.byType(TextFormField),
      ),
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(RegisterConfirmField),
        matching: find.byType(TextFormField),
      ),
      password,
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Terms checkbox.
    await ensureVisibleAndTap(
      tester,
      find.descendant(
        of: find.byType(TermsCheckboxRow),
        matching: find.byType(Checkbox),
      ),
    );

    // Register button.
    await ensureVisibleAndTap(
      tester,
      find.widgetWithText(LoadingButton, 'REGISTER'),
    );

    // Give the app 2 seconds to complete the async register + navigation.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Diagnostic — log any SnackBar content.
    final snackBars = find.byType(SnackBar).evaluate();
    if (snackBars.isNotEmpty) {
      final texts = find
          .descendant(of: find.byType(SnackBar), matching: find.byType(Text))
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .where((t) => t != null)
          .join(' | ');
      debugPrint('🐞 SnackBar content: $texts');
    }

    // Wait for home.
    await pumpUntilFound(tester, find.text('PIXELQUEST'));
    expect(find.text('PIXELQUEST'), findsOneWidget);
  });
}
