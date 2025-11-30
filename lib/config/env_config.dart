import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the Mawjood application.
///
/// Loads Supabase credentials from a .env file for secure and flexible configuration.
class EnvConfig {
  /// Supabase project URL loaded from .env file.
  final String supabaseUrl;

  /// Supabase anonymous/public API key loaded from .env file.
  final String supabaseAnonKey;

  EnvConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  /// Factory constructor to load configuration from the .env file.
  factory EnvConfig.load() {
    // Ensure that the .env file is loaded before accessing variables
    if (dotenv.env.isEmpty) {
      throw Exception(
        'Dotenv has not been initialized. Call dotenv.load() in main.dart',
      );
    }
    return EnvConfig(
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  /// Validates that the configuration has been set up correctly.
  bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl.startsWith('https://') &&
        supabaseUrl.contains('.supabase.co');
  }

  /// Returns a user-friendly error message if configuration is invalid.
  String? get configurationError {
    if (supabaseUrl.isEmpty) {
      return 'SUPABASE_URL is not defined in .env file';
    }
    if (supabaseAnonKey.isEmpty) {
      return 'SUPABASE_ANON_KEY is not defined in .env file';
    }
    if (!supabaseUrl.startsWith('https://')) {
      return 'Supabase URL must start with https://';
    }
    if (!supabaseUrl.contains('.supabase.co')) {
      return 'Supabase URL must contain .supabase.co';
    }
    return null;
  }
}
