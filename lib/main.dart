import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/startup_error_screen.dart';
import 'services/cache_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
    if (details.library != null) {
      debugPrint('[FlutterError] Library: ${details.library}');
    }
    if (details.context != null) {
      debugPrint('[FlutterError] Context: ${details.context}');
    }
    if (details.stack != null) {
      debugPrint('[FlutterError] Stack: ${details.stack}');
    }
  };

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint('[MAIN] .env loaded successfully');
  } catch (e) {
    debugPrint('[MAIN] Failed to load .env: $e');
  }

  final cacheService = await CacheService.create();
  SupabaseService? supabaseService;
  String? startupError;

  try {
    supabaseService = await SupabaseService.initializeAndCreate();
  } catch (e, stackTrace) {
    startupError = 'Supabase is not configured correctly. Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env or dart-define.';
    debugPrint('[MAIN] Supabase init failed: $e');
    debugPrint('[MAIN] Stack: $stackTrace');
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        if (supabaseService != null)
          supabaseServiceProvider.overrideWithValue(supabaseService),
        cacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: MawjoodApp(
        onboardingCompleted: onboardingCompleted,
        startupError: startupError,
      ),
    ),
  );
}

class MawjoodApp extends StatelessWidget {
  const MawjoodApp({
    super.key,
    required this.onboardingCompleted,
    this.startupError,
  });

  final bool onboardingCompleted;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mawjood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: startupError != null
          ? StartupErrorScreen(message: startupError!)
          : onboardingCompleted
              ? const HomeScreen()
              : const OnboardingScreen(),
    );
  }
}
