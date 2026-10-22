import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/widgets/or_divider.dart';

void main() {
  testWidgets('renders the word OR', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OrDivider())),
    );
    expect(find.text('OR'), findsOneWidget);
  });

  testWidgets('renders two dividers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OrDivider())),
    );
    expect(find.byType(Divider), findsNWidgets(2));
  });
}
