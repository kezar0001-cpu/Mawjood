import 'package:flutter/material.dart';

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration required'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase not configured',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick fix:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1) Set SUPABASE_URL and SUPABASE_ANON_KEY in .env (or pass as --dart-define).\n'
              '2) Redeploy the web build so the new values are included.',
            ),
          ],
        ),
      ),
    );
  }
}
