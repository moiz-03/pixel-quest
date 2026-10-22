import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/screens/home/widgets/nav_item.dart';

void main() {
  testWidgets('renders icon and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              NavItem(
                icon: Icons.home,
                label: 'QUESTS',
                active: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('QUESTS'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
  testWidgets('active=true uses xpGreen color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              NavItem(icon: Icons.home, label: 'X', active: true, onTap: () {}),
            ],
          ),
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, const Color(0xFF4DFF6B));
  });
  testWidgets('active=false uses muted color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              NavItem(
                icon: Icons.home,
                label: 'X',
                active: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.home));
    expect(icon.color, const Color(0xFF5C6E8C));
  });
  testWidgets('tap fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              NavItem(
                icon: Icons.home,
                label: 'X',
                active: false,
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('X'));
    expect(tapped, isTrue);
  });
}
