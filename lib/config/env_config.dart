/// Environment configuration for the Mawjood application.
///
/// IMPORTANT: Replace the placeholder values below with your actual Supabase credentials.
/// You can find these values in your Supabase project dashboard at:
/// https://app.supabase.com/project/<your-project-id>/settings/api
///
/// For production builds, these values should be passed at compile time using:
/// flutter build web --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
class EnvConfig {
  /// Supabase project URL
  /// Format: https://<YOUR_PROJECT_ID>.supabase.co
  ///
  /// This MUST be an absolute URL, not a relative path.
  /// DO NOT use relative paths like '/rest/v1' or 'rest/v1'
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co', // Replace with your actual Supabase URL
  );

  /// Supabase anonymous/public API key
  /// This is safe to use in client-side code
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-public-key', // Replace with your actual anon key
  );

  /// Validates that the configuration has been set up correctly
  static bool get isConfigured {
    return !supabaseUrl.contains('your-project-id') &&
        !supabaseAnonKey.contains('your-anon-public-key') &&
        supabaseUrl.startsWith('https://') &&
        supabaseUrl.contains('.supabase.co');
  }

  /// Returns a user-friendly error message if configuration is invalid
  static String? get configurationError {
    if (supabaseUrl.contains('your-project-id')) {
      return 'Supabase URL has not been configured. Please update lib/config/env_config.dart';
    }
    if (supabaseAnonKey.contains('your-anon-public-key')) {
      return 'Supabase anon key has not been configured. Please update lib/config/env_config.dart';
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
