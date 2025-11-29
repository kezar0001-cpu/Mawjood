import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../mock/mock_businesses.dart';
import '../models/business.dart';

class SupabaseService {
  static const bool useMock = false;

  static const String _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '<SUPABASE_URL>');
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '<SUPABASE_ANON_KEY>',
  );

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (useMock) return;

    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static Future<List<Business>> fetchBusinesses({
    String? categoryId,
    String? searchQuery,
    bool orderByPopularity = true,
  }) async {
    if (useMock) {
      return _filterMockBusinesses(categoryId: categoryId, searchQuery: searchQuery);
    }

    try {
      final trimmed = searchQuery?.trim();
      final query = client.from('businesses').select(_businessSelectColumns);

      if (categoryId != null && categoryId.isNotEmpty) {
        query.eq('category_id', categoryId);
      }

      if (trimmed != null && trimmed.isNotEmpty) {
        query.or('name.ilike.%$trimmed%,description.ilike.%$trimmed%');
      }

      if (orderByPopularity) {
        query.order('popular_score', ascending: false);
      }

      final response = await query;
      if (response is List) {
        return response.map((json) => Business.fromJson(json)).toList();
      }
    } catch (error, stackTrace) {
      debugPrint('Error loading businesses: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return [];
  }

  static Future<Business?> fetchBusinessById(String id) async {
    if (useMock) {
      try {
        return mockBusinesses.firstWhere((business) => business.id == id);
      } catch (_) {
        return null;
      }
    }

    try {
      final response = await client
          .from('businesses')
          .select(_businessSelectColumns)
          .eq('id', id)
          .limit(1);

      if (response is List && response.isNotEmpty) {
        return Business.fromJson(response.first);
      }
    } catch (error, stackTrace) {
      debugPrint('Error loading business by id: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return null;
  }

  static List<Business> _filterMockBusinesses({
    String? categoryId,
    String? searchQuery,
  }) {
    Iterable<Business> results = mockBusinesses;

    if (categoryId != null && categoryId.isNotEmpty) {
      results = results.where((business) => business.categoryId == categoryId);
    }

    final trimmed = searchQuery?.trim().toLowerCase();
    if (trimmed != null && trimmed.isNotEmpty) {
      results = results.where(
        (business) => business.name.toLowerCase().contains(trimmed) ||
            business.description.toLowerCase().contains(trimmed),
      );
    }

    return results.toList();
  }

  static const String _businessSelectColumns =
      'id, name, category_id, description, city, address, phone, rating, latitude, longitude, images, features, rating_count, whatsapp, maps_url, image_url, opening_hours, popular_score';
}
