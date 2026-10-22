import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/theme/app_colors.dart';
import 'package:pixel_quest/utils/snackbar_helper.dart';

void main() {
  testWidgets('error shows a SnackBar with the message', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    SnackbarHelper.error(ctx, 'boom');
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('success shows a SnackBar with the message', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    SnackbarHelper.success(ctx, 'yay');
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('yay'), findsOneWidget);
  });

  testWidgets('error uses AppColors.error background', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    SnackbarHelper.error(ctx, 'x');
    await tester.pump();

    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.backgroundColor, AppColors.error);
  });

  testWidgets('success uses AppColors.success background', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    SnackbarHelper.success(ctx, 'x');
    await tester.pump();

    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.backgroundColor, AppColors.success);
  });

  testWidgets('hides the previous snackbar before showing a new one', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    SnackbarHelper.error(ctx, 'first');
    await tester.pump(const Duration(milliseconds: 100));
    SnackbarHelper.error(ctx, 'second');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);
  });
}
