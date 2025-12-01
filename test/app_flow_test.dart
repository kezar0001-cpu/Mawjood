import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawjood/main.dart';
import 'package:mawjood/screens/onboarding_screen.dart';
import 'package:mawjood/screens/home_screen.dart';
import 'package:mawjood/config/env_config.dart'; // Import EnvConfig

void main() {
  group('App Flow Tests', () {
    setUp(() async {
      // Reset any previous mock values
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App starts with OnboardingScreen if onboarding is not completed', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'onboardingCompleted': false,
      });

      // Override envConfigProvider for testing
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            envConfigProvider.overrideWithValue(
              EnvConfig(
                supabaseUrl: 'https://mock.supabase.co',
                supabaseAnonKey: 'mock_anon_key',
              ),
            ),
          ],
          child: MawjoodApp(onboardingCompleted: false),
        ),
      );
      await tester.pumpAndSettle(); // Wait for all animations and futures to complete

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('OnboardingScreen navigates to HomeScreen and sets flag on button tap', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'onboardingCompleted': false,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            envConfigProvider.overrideWithValue(
              EnvConfig(
                supabaseUrl: 'https://mock.supabase.co',
                supabaseAnonKey: 'mock_anon_key',
              ),
            ),
          ],
          child: MawjoodApp(onboardingCompleted: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Tap the "ابدأ الآن" button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // Wait for navigation and state updates

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify that the onboardingCompleted flag is set to true
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboardingCompleted'), isTrue);
    });

    testWidgets('App starts with HomeScreen if onboarding is completed', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'onboardingCompleted': true,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            envConfigProvider.overrideWithValue(
              EnvConfig(
                supabaseUrl: 'https://mock.supabase.co',
                supabaseAnonKey: 'mock_anon_key',
              ),
            ),
          ],
          child: MawjoodApp(onboardingCompleted: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
