import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawjood/config/env_config.dart';
import 'package:mawjood/services/supabase_service.dart';
import 'package:mawjood/services/cache_service.dart'; // Import CacheService
import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize CacheService first
  final CacheService cacheService = await CacheService.create();

  // Initialize SupabaseService and Supabase
  final SupabaseService supabaseService = await SupabaseService.initializeAndCreate();

  // Check if onboarding is completed
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(supabaseService),
        cacheServiceProvider.overrideWithValue(cacheService), // Provide CacheService
      ],
      child: MawjoodApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class MawjoodApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MawjoodApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'موجود',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: onboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}