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

  /// Factory constructor to load configuration from .env file or Dart defines.
  factory EnvConfig.load() {
    // Try reading from Dotenv first, then fallback to Dart environment variables (flags)
    // This supports both local dev (.env) and CI/CD (--dart-define)
    final url = dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL');
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY');

    return EnvConfig(
      supabaseUrl: url,
      supabaseAnonKey: key,
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
