import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/features/dashboard/presentation/widgets/sleep_summary_ring.dart';

void main() {
  group('SleepSummaryRing Widget Tests', () {
    testWidgets('renders progress arc, percentage text, and duration readout',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SleepSummaryRing(
                durationMinutes: 420, // 7h
                goalMinutes: 480, // 8h -> 87.5% -> 88%
                size: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('7h'), findsOneWidget);
      expect(find.text('88% of goal'), findsOneWidget);
      expect(find.byIcon(Icons.timelapse_rounded), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders checkmark when goal is met or exceeded (>= 100%)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SleepSummaryRing(
                durationMinutes: 510, // 8.5h
                goalMinutes: 480, // 8h -> 106%
                size: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('8h 30m'), findsOneWidget);
      expect(find.text('106% of goal'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets(
        'repaints cleanly on theme switching between dark and light mode',
        (tester) async {
      final key = GlobalKey();

      // 1. Initial pump in Dark Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SleepSummaryRing(
              key: key,
              durationMinutes: 450,
              goalMinutes: 480,
              size: 200,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final darkPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(CustomPaint),
        ),
      );
      final darkPainter = darkPaint.painter!;

      // 2. Re-pump in Light Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SleepSummaryRing(
              key: key,
              durationMinutes: 450,
              goalMinutes: 480,
              size: 200,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(CustomPaint),
        ),
      );
      final lightPainter = lightPaint.painter!;

      // shouldRepaint must return true when isDark changes
      expect(lightPainter.shouldRepaint(darkPainter), isTrue);
    });

    testWidgets('handles edge cases: zero duration and micro sizes without crash',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Zero progress
                SleepSummaryRing(
                  durationMinutes: 0,
                  goalMinutes: 480,
                  size: 150,
                ),
                // Zero goal
                SleepSummaryRing(
                  durationMinutes: 100,
                  goalMinutes: 0,
                  size: 150,
                ),
                // Micro size
                SleepSummaryRing(
                  durationMinutes: 300,
                  goalMinutes: 480,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SleepSummaryRing), findsNWidgets(3));
    });
  });
}
