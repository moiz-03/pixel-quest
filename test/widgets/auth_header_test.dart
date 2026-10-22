import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/widgets/auth_header.dart';

void main() {
  testWidgets('renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthHeader(title: 'WELCOME BACK', subtitle: 'Continue.'),
        ),
      ),
    );
    expect(find.text('WELCOME BACK'), findsOneWidget);
    expect(find.text('Continue.'), findsOneWidget);
  });

  testWidgets('renders arbitrary strings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthHeader(title: 'CREATE ACCOUNT', subtitle: 'Start quest.'),
        ),
      ),
    );
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    expect(find.text('Start quest.'), findsOneWidget);
  });
}
