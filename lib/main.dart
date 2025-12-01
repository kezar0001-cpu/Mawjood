import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'models/business.dart';
import 'models/category.dart';
import 'screens/business_detail_screen.dart';
import 'screens/business_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'services/supabase_service.dart';
import 'utils/app_text.dart';
import 'widgets/offline_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 [MAIN] Starting Mawjood initialization...');

  // 1. Load Environment Variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ [MAIN] .env file loaded successfully');
  } catch (e) {
    debugPrint('ℹ️ [MAIN] .env file not found (using build flags if available)');
  }

  // 2. Initialize Supabase (Non-blocking for UI startup, but required for data)
  final initFuture = SupabaseService.initialize().catchError((e) {
    debugPrint('❌ [MAIN] Supabase initialization error: $e');
  });

  runApp(
    ProviderScope(
      child: MawjoodApp(initFuture: initFuture),
    ),
  );
}

class MawjoodApp extends StatefulWidget {
  final Future<void> initFuture;

  const MawjoodApp({super.key, required this.initFuture});

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
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ [APP] Error checking onboarding status: $e');
      // Fallback: assume not seen if error, or just show home to be safe? 
      // Safer to show onboarding if we can't read prefs.
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: AppText.appName,
      debugShowCheckedModeBanner: false,
      
      // ✅ USE THE SAFE THEME
      theme: AppTheme.lightTheme,
      
      // ✅ RTL SUPPORT
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: _hasSeenOnboarding ? HomeScreen.routeName : OnboardingScreen.routeName,
      
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        HomeScreen.routeName: (context) => OfflineIndicator(child: const HomeScreen()),
        SearchScreen.routeName: (context) => OfflineIndicator(child: const SearchScreen()),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
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
