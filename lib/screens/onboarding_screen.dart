import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 80, color: Color(0xFF00897B)),
              const SizedBox(height: 24),
              const Text(
                'مرحباً بك في موجود',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'دليلك الأول للأعمال في العراق',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Home
                  debugPrint('Navigating to Home...');
                },
                child: const Text('ابدأ الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}