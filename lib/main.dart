import 'package:firebase_core/firebase_core.dart';
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

  return base.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.darkText,
      displayColor: AppColors.darkText,
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize Firebase (with error handling for missing config)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Firebase Analytics and Crashlytics will not be available.');
  }

  // Initialize Hive cache
  await CacheService.initialize();

  // Initialize connectivity service
  await ConnectivityService().initialize();

  // Initialize analytics service
  await AnalyticsService().initialize();

  runApp(
    const ProviderScope(
      child: MawjoodApp(),
    ),
  );
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
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding;
      _isLoading = false;
    });
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
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => OfflineIndicator(
              child: BusinessDetailScreen(
                businessId: args['businessId'] as String,
                initialBusiness: args['business'] as Business?,
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
