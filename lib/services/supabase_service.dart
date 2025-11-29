import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: '<SUPABASE_URL>',
      anonKey: '<SUPABASE_ANON_KEY>',
    );
  }
}
