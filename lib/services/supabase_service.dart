import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/business.dart';
import '../models/category.dart';

class SupabaseService {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response =
          await client.from('categories').select().order('name_ar', ascending: true);
      if (response is List) {
        return response.map((item) => Category.fromMap(item)).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  static Future<List<Business>> getBusinessesByCategory(String categoryId) async {
    try {
      final response = await client
          .from('businesses')
          .select()
          .eq('category_id', categoryId)
          .order('name', ascending: true);
      if (response is List) {
        return response.map((item) => Business.fromMap(item)).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  static Future<List<Business>> searchBusinesses(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final response = await client
          .from('businesses')
          .select()
          .or('name.ilike.%$trimmed%,description.ilike.%$trimmed%')
          .order('name', ascending: true);
      if (response is List) {
        return response.map((item) => Business.fromMap(item)).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  static Future<Business?> getBusinessById(String id) async {
    try {
      final response = await client
          .from('businesses')
          .select()
          .eq('id', id)
          .limit(1)
          .maybeSingle();
      if (response is Map<String, dynamic>) {
        return Business.fromMap(response);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
