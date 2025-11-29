import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/business_detail_screen.dart';
import 'screens/business_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'services/supabase_service.dart';
import 'models/business.dart';
import 'models/category.dart';
import 'utils/app_colors.dart';
import 'utils/app_text.dart';

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
  final initFuture = SupabaseService.initialize();

  try {
    await initFuture;
  } catch (e) {
    debugPrint('Init error: $e');
  }

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
        HomeScreen.routeName: (_) => const HomeScreen(),
        SearchScreen.routeName: (_) => const SearchScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == BusinessListScreen.routeName) {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['category'] is Category) {
            return MaterialPageRoute(
              builder: (_) => BusinessListScreen(
                category: args['category'] as Category,
                businesses: args['businesses'] as List<Business>?,
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
