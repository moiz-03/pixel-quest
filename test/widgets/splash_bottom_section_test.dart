import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/splash/widgets/splash_bottom_section.dart';

void main() {
  Widget wrap({
    required bool checking,
    required bool showAuthButtons,
    VoidCallback? onLogin,
    VoidCallback? onRegister,
  }) => MaterialApp(
    home: Scaffold(
      body: SplashBottomSection(
        checking: checking,
        showAuthButtons: showAuthButtons,
        onLogin: onLogin ?? () {},
        onRegister: onRegister ?? () {},
      ),
    ),
  );

  testWidgets('checking → spinner, no buttons', (tester) async {
    await tester.pumpWidget(wrap(checking: true, showAuthButtons: false));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
    expect(find.text('REGISTER'), findsNothing);
  });

  testWidgets('not checking + auth buttons → both buttons, no spinner', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(checking: false, showAuthButtons: true));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('REGISTER'), findsOneWidget);
  });

  testWidgets('not checking + no auth buttons → empty', (tester) async {
    await tester.pumpWidget(wrap(checking: false, showAuthButtons: false));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('LOGIN'), findsNothing);
    expect(find.text('REGISTER'), findsNothing);
  });

  testWidgets('LOGIN tap fires onLogin', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        checking: false,
        showAuthButtons: true,
        onLogin: () => tapped = true,
      ),
    );
    await tester.tap(find.text('LOGIN'));
    expect(tapped, isTrue);
  });

  testWidgets('REGISTER tap fires onRegister', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        checking: false,
        showAuthButtons: true,
        onRegister: () => tapped = true,
      ),
    );
    await tester.tap(find.text('REGISTER'));
    expect(tapped, isTrue);
  });
}
