/// Environment configuration for the Mawjood application.
///
/// Supabase configuration with static credentials.
/// These values are hardcoded to ensure Flutter Web builds work correctly.
class EnvConfig {
  /// Supabase project URL
  /// This is an absolute URL that points to the Supabase project.
  static const String supabaseUrl = 'https://yywjdkunrkakxwgdwsjz.supabase.co';

  /// Supabase anonymous/public API key
  /// This is safe to use in client-side code
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5d2pka3Vucmtha3h3Z2R3c2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzMjQwMjYsImV4cCI6MjA3OTkwMDAyNn0.TjviqrZWd1wUnTFS8YpbXDrH3BfidpmgQkgALZQNzs4';

  /// Validates that the configuration has been set up correctly
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl.startsWith('https://') &&
        supabaseUrl.contains('.supabase.co');
  }

  /// Returns a user-friendly error message if configuration is invalid
  static String? get configurationError {
    if (supabaseUrl.isEmpty) {
      return 'Supabase URL is empty';
    }
    if (supabaseAnonKey.isEmpty) {
      return 'Supabase anon key is empty';
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
