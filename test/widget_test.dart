import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleep_tracker/app/app.dart';
import 'package:sleep_tracker/app/app_config.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      AppConfig.keyOnboardingCompleted: true,
      AppConfig.keySleepGoal: 480,
    });
  });

  testWidgets('SomnaApp loads and renders main dashboard smoke test',
      (WidgetTester tester) async {
    // Build the Somna application
    await tester.pumpWidget(const SomnaApp());
    await tester.pumpAndSettle();

    // Verify bottom navigation items are rendered
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify action button to start sleep or log sleep exists
    expect(find.text('Start Sleep'), findsOneWidget);
  });
}
