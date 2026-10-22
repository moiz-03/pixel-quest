import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/settings_tab.dart';

Widget _wrap({
  String username = 'player',
  bool loggingOut = false,
  bool deletingAccount = false,
  VoidCallback? onLogout,
  VoidCallback? onDeleteAccount,
}) => MaterialApp(
  home: Scaffold(
    body: SettingsTab(
      username: username,
      loggingOut: loggingOut,
      deletingAccount: deletingAccount,
      onLogout: onLogout ?? () {},
      onDeleteAccount: onDeleteAccount ?? () {},
    ),
  ),
);

void main() {
  testWidgets('renders SETTINGS header', (tester) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('SETTINGS'), findsOneWidget);
  });

  testWidgets('shows username', (tester) async {
    await tester.pumpWidget(_wrap(username: 'alice'));
    expect(find.text('Signed in as alice'), findsOneWidget);
  });

  testWidgets('LOG OUT button fires callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(onLogout: () => tapped = true));
    await tester.tap(find.text('LOG OUT'));
    expect(tapped, isTrue);
  });

  testWidgets('DELETE ACCOUNT button fires callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(onDeleteAccount: () => tapped = true));
    await tester.tap(find.text('DELETE ACCOUNT'));
    expect(tapped, isTrue);
  });

  testWidgets('loggingOut shows spinner on log out button', (tester) async {
    await tester.pumpWidget(_wrap(loggingOut: true));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('loggingOut disables both buttons', (tester) async {
    var logoutTapped = false;
    var deleteTapped = false;
    await tester.pumpWidget(
      _wrap(
        loggingOut: true,
        onLogout: () => logoutTapped = true,
        onDeleteAccount: () => deleteTapped = true,
      ),
    );
    await tester.tap(find.text('LOG OUT'));
    await tester.tap(find.text('DELETE ACCOUNT'));
    expect(logoutTapped, isFalse);
    expect(deleteTapped, isFalse);
  });

  testWidgets('deletingAccount disables buttons', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(deletingAccount: true, onLogout: () => tapped = true),
    );
    await tester.tap(find.text('LOG OUT'));
    expect(tapped, isFalse);
  });
}
