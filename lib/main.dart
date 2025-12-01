import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MawjoodApp());
}

class MawjoodApp extends StatelessWidget {
  const MawjoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'موجود',
      debugShowCheckedModeBanner: false,
      // Use the safe theme we will define
      theme: AppTheme.lightTheme,
      // RTL Support
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OnboardingScreen(),
    );
  }
}