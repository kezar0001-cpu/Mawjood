import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

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
    debugPrint('🔍 [ENV] EnvConfig.load() called');
    
    String? url;
    String? key;

    // 1. Try DotEnv
    try {
      // Accessing dotenv.env *should* be safe even if load failed, but let's be careful.
      if (dotenv.isInitialized) {
         url = dotenv.env['SUPABASE_URL'];
         key = dotenv.env['SUPABASE_ANON_KEY'];
         debugPrint('🔍 [ENV] Found values in dotenv: URL=${url != null}, Key=${key != null}');
      } else {
         debugPrint('ℹ️ [ENV] dotenv not initialized, skipping lookup');
      }
    } catch (e) {
      debugPrint('⚠️ [ENV] Error accessing dotenv: $e');
    }

    // 2. Fallback to Dart Defines (Compiler flags)
    if (url == null || url.isEmpty) {
      const dartUrl = String.fromEnvironment('SUPABASE_URL');
      if (dartUrl.isNotEmpty) {
        url = dartUrl;
        debugPrint('🔍 [ENV] Found SUPABASE_URL in dart-define');
      }
    }

    if (key == null || key.isEmpty) {
      const dartKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      if (dartKey.isNotEmpty) {
        key = dartKey;
        debugPrint('🔍 [ENV] Found SUPABASE_ANON_KEY in dart-define');
      }
    }

    return EnvConfig(
      supabaseUrl: url ?? '',
      supabaseAnonKey: key ?? '',
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
      return 'SUPABASE_URL is not defined (checked .env and --dart-define)';
    }
    if (supabaseAnonKey.isEmpty) {
      return 'SUPABASE_ANON_KEY is not defined (checked .env and --dart-define)';
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

// Riverpod provider for EnvConfig
final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.load();
});
