import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'models/business.dart';
import 'models/category.dart';
import 'screens/business_detail_screen.dart';
import 'screens/business_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'services/analytics_service.dart';
import 'services/cache_service.dart';
import 'services/connectivity_service.dart';
import 'services/supabase_service.dart';
import 'utils/app_colors.dart';
import 'utils/app_text.dart';
import 'widgets/offline_indicator.dart';

// FIXED: Added error handling for GoogleFonts to prevent Web crashes
ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Safe Google Fonts loading with fallback for Web
  try {
    final googleFontsTheme = GoogleFonts.cairoTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: googleFontsTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
    );
  } catch (e) {
    debugPrint('⚠️ [THEME] GoogleFonts failed to load, using fallback: $e');
    // Return base theme with manual Arabic font if GoogleFonts fails
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
        fontFamily: 'Arial', // Fallback font for Arabic
      ),
    );
  }
}

Future<void> main() async {
  // Global error handler to catch initialization errors before widget tree is built
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('Flutter Error Caught:');
    debugPrint('Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
    debugPrint('Library: ${details.library}');
    debugPrint('Context: ${details.context}');
    debugPrint('═══════════════════════════════════════════════════');
  };

  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 [MAIN] Starting Mawjood initialization...');
  debugPrint('🌐 [MAIN] Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

  final initFuture = SupabaseService.initialize();

  try {
    debugPrint('⏳ [MAIN] Waiting for Supabase initialization...');
    await initFuture;
    debugPrint('✅ [MAIN] Supabase initialization completed successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ [MAIN] Supabase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  debugPrint('🎬 [MAIN] Running app...');
  runApp(MawjoodBootstrap(initFuture: initFuture));
}

class MawjoodBootstrap extends StatefulWidget {
  const MawjoodBootstrap({super.key, required this.initFuture});

  final Future<void> initFuture;

  @override
  State<MawjoodBootstrap> createState() => _MawjoodBootstrapState();
}

class _MawjoodBootstrapState extends State<MawjoodBootstrap> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.initFuture;
  }

  void _retryInitialization() {
    setState(() {
      _initFuture = SupabaseService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: AppColors.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'تعذر تهيئة التطبيق',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _retryInitialization,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return const MawjoodApp();
      },
    );
  }
}

class MawjoodApp extends StatefulWidget {
  const MawjoodApp({super.key});

  @override
  State<MawjoodApp> createState() => _MawjoodAppState();
}

class _MawjoodAppState extends State<MawjoodApp> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📱 [APP] MawjoodApp initState called');
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    debugPrint('🔍 [APP] Checking onboarding status...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      debugPrint('✓ [APP] Onboarding status: ${hasSeenOnboarding ? "completed" : "not shown"}');

      setState(() {
        _hasSeenOnboarding = hasSeenOnboarding;
        _isLoading = false;
      });

      debugPrint('📍 [APP] Will navigate to: ${hasSeenOnboarding ? "HomeScreen" : "OnboardingScreen"}');
    } catch (e, stackTrace) {
      debugPrint('❌ [APP] Error checking onboarding status: $e');
      debugPrint('Stack: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: AppText.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: _hasSeenOnboarding ? HomeScreen.routeName : OnboardingScreen.routeName,
      // FIXED: Use const constructors for better performance and Web stability
      routes: {
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        HomeScreen.routeName: (_) => OfflineIndicator(child: const HomeScreen()),
        SearchScreen.routeName: (_) => OfflineIndicator(child: const SearchScreen()),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == BusinessListScreen.routeName) {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['category'] is Category) {
            return MaterialPageRoute(
              builder: (_) => OfflineIndicator(
                child: BusinessListScreen(
                  category: args['category'] as Category,
                  businesses: args['businesses'] as List<Business>?,
                ),
              ),
            );
          }
        }
        if (settings.name == BusinessDetailScreen.routeName) {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final businessId = args['businessId'];
            if (businessId is String) {
              return MaterialPageRoute(
                builder: (_) => BusinessDetailScreen(
                  businessId: businessId,
                  initialBusiness: args['business'] as Business?,
                ),
              );
            }
          }
        }
        return null;
      },
    );
  }
}
