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
<<<<<<< HEAD

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize CacheService first
  final CacheService cacheService = await CacheService.create();
=======
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
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

  try {
    final googleFontsTheme = GoogleFonts.cairoTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: googleFontsTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
    );
  } catch (e) {
    debugPrint('[THEME] GoogleFonts failed to load, using fallback: $e');
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
        fontFamily: 'Arial',
      ),
    );
  }
}

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

  debugPrint('[MAIN] Starting Mawjood initialization...');
  debugPrint('[MAIN] Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

  try {
    await dotenv.load(fileName: ".env");
    debugPrint('[MAIN] .env file loaded successfully');
  } catch (e) {
    debugPrint('[MAIN] Error loading .env file: $e');
  }
>>>>>>> c0ab899 (Improve startup UX and logging for Mawjood)

  // Initialize SupabaseService and Supabase
  final SupabaseService supabaseService = await SupabaseService.initializeAndCreate();

<<<<<<< HEAD
  // Check if onboarding is completed
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

=======
  try {
    debugPrint('[MAIN] Waiting for Supabase initialization...');
    await initFuture;
    debugPrint('[MAIN] Supabase initialization completed successfully');
  } catch (e, stackTrace) {
    debugPrint('[MAIN] Supabase initialization error: $e');
    debugPrint('[MAIN] Stack trace: $stackTrace');
  }

  debugPrint('[MAIN] Running app...');
>>>>>>> c0ab899 (Improve startup UX and logging for Mawjood)
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

<<<<<<< HEAD
class MawjoodApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MawjoodApp({super.key, required this.onboardingCompleted});
=======
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
>>>>>>> c0ab899 (Improve startup UX and logging for Mawjood)

  Widget _buildStartupShell({required Widget child}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.neutral,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return _buildStartupShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.place, color: Colors.white, size: 32),
          ),
          SizedBox(height: 16),
          Text(
            'ماوجود',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          SizedBox(height: 8),
          Text(
            'نجهز لك التجربة، لحظة واحدة...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.darkText),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return _buildStartupShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.error,
            child: Icon(Icons.cloud_off, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'تعذر بدء التطبيق',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          const Text(
            'تأكد من الاتصال بالإنترنت وحاول مرة أخرى.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.darkText),
          ),
          const SizedBox(height: 12),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _retryInitialization,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error ?? 'خطأ غير متوقع');
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
    debugPrint('[APP] MawjoodApp initState called');
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    debugPrint('[APP] Checking onboarding status...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      debugPrint('[APP] Onboarding status: ${hasSeenOnboarding ? "completed" : "not shown"}');

      setState(() {
        _hasSeenOnboarding = hasSeenOnboarding;
        _isLoading = false;
      });

      debugPrint('[APP] Will navigate to: ${hasSeenOnboarding ? "HomeScreen" : "OnboardingScreen"}');
    } catch (e, stackTrace) {
      debugPrint('[APP] Error checking onboarding status: $e');
      debugPrint('[APP] Stack: $stackTrace');
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

>>>>>>> c0ab899 (Improve startup UX and logging for Mawjood)
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