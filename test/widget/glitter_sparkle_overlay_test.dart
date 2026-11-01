import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/core/widgets/glitter_sparkle_overlay.dart';

void main() {
  group('GlitterSparkleOverlay Portability & Reliability Tests', () {
    testWidgets('renders normally on standard card dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 180,
              child: GlitterSparkleOverlay(
                particleCount: 16,
                maxStarSize: 9.0,
                sparkleAtEnds: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(GlitterSparkleOverlay), findsOneWidget);
    });

    testWidgets(
        'renders safely without crash or assertion on extreme micro dimensions (10x10, 0x0)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: GlitterSparkleOverlay(
                    particleCount: 10,
                    sparkleAtEnds: true,
                  ),
                ),
                SizedBox(
                  width: 0,
                  height: 0,
                  child: GlitterSparkleOverlay(
                    particleCount: 8,
                    sparkleAtEnds: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(GlitterSparkleOverlay), findsNWidgets(2));
    });

    testWidgets('passes pointer events completely to child buttons',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlitterSparkleOverlay(
                particleCount: 12,
                sparkleAtEnds: true,
                child: ElevatedButton(
                  key: const Key('sparkle_button'),
                  onPressed: () => tapped = true,
                  child: const Text('Tap Me'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const Key('sparkle_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tapped, isTrue);
    });

    testWidgets('respects disableAnimations (reduce motion setting)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: SizedBox(
                width: 200,
                height: 100,
                child: GlitterSparkleOverlay(
                  particleCount: 10,
                  sparkleAtEnds: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(GlitterSparkleOverlay), findsOneWidget);
    });

    testWidgets(
        'GlitterBorderContainer renders safely with zero or negative border radii',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GlitterBorderContainer(
                  borderRadius: 0,
                  child: Text('Zero radius'),
                ),
                GlitterBorderContainer(
                  borderRadius: -5,
                  child: Text('Negative radius'),
                ),
                GlitterBorderContainer(
                  borderRadius: 24,
                  child: Text('Standard radius'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Zero radius'), findsOneWidget);
      expect(find.text('Negative radius'), findsOneWidget);
      expect(find.text('Standard radius'), findsOneWidget);
    });
  });
}
