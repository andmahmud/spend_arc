import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spend_arc/core/theme/app_theme.dart';
import 'package:spend_arc/presentation/widgets/arc_meter.dart';

void main() {
  testWidgets('ArcMeter displays spent and total amounts',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: ArcMeter(
            percentage: 0.4,
            totalAmount: 5000,
            spentAmount: 2000,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('2000'), findsOneWidget);
    expect(find.textContaining('5000'), findsOneWidget);
    expect(find.textContaining('of'), findsOneWidget);
  });

  testWidgets('ArcMeter shows 0% spent correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: ArcMeter(
            percentage: 0.0,
            totalAmount: 5000,
            spentAmount: 0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('of \$5000'), findsOneWidget);
    expect(find.textContaining('\$0'), findsOneWidget);
  });

  testWidgets('ArcMeter shows 100% spent correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: ArcMeter(
            percentage: 1.0,
            totalAmount: 5000,
            spentAmount: 5000,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('\$5000'), findsNWidgets(2));
  });
}
