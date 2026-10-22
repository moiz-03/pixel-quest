import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/bottom_nav.dart';
import 'package:pixel_quest/screens/home/widgets/nav_item.dart';

void main() {
  testWidgets('renders 3 nav items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BottomNav(tabIndex: 0, onTabChanged: (_) {})),
      ),
    );
    expect(find.byType(NavItem), findsNWidgets(3));
    expect(find.text('QUESTS'), findsOneWidget);
    expect(find.text('STATS'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });

  testWidgets('QUESTS active when tabIndex is 0', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BottomNav(tabIndex: 0, onTabChanged: (_) {})),
      ),
    );
    final items = tester.widgetList<NavItem>(find.byType(NavItem)).toList();
    expect(items[0].active, isTrue);
    expect(items[1].active, isFalse);
    expect(items[2].active, isFalse);
  });

  testWidgets('STATS active when tabIndex is 1', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BottomNav(tabIndex: 1, onTabChanged: (_) {})),
      ),
    );
    final items = tester.widgetList<NavItem>(find.byType(NavItem)).toList();
    expect(items[0].active, isFalse);
    expect(items[1].active, isTrue);
    expect(items[2].active, isFalse);
  });

  testWidgets('tapping QUESTS fires onTabChanged(0)', (tester) async {
    int? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomNav(tabIndex: 1, onTabChanged: (i) => received = i),
        ),
      ),
    );
    await tester.tap(find.text('QUESTS'));
    expect(received, 0);
  });

  testWidgets('tapping STATS fires onTabChanged(1)', (tester) async {
    int? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomNav(tabIndex: 0, onTabChanged: (i) => received = i),
        ),
      ),
    );
    await tester.tap(find.text('STATS'));
    expect(received, 1);
  });

  testWidgets('tapping SETTINGS fires onTabChanged(2)', (tester) async {
    int? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomNav(tabIndex: 0, onTabChanged: (i) => received = i),
        ),
      ),
    );
    await tester.tap(find.text('SETTINGS'));
    expect(received, 2);
  });
}
