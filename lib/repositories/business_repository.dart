import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/business.dart';
import '../services/supabase_service.dart';

class BusinessRepository {
  BusinessRepository();

  final SupabaseClient _client = SupabaseService.client;

  Future<List<Business>> getBusinessesByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('businesses')
          .select()
          .eq('category_id', categoryId)
          .order('popular_score', ascending: false);

      if (response is List) {
        return response
            .map((json) => Business.fromJson(json).copyWith(categoryId: categoryId))
            .toList();
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching businesses by category: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return [];
  }

  Future<List<Business>> searchBusinesses(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final response = await _client
          .from('businesses')
          .select()
          .or('name.ilike.%$trimmed%,description.ilike.%$trimmed%')
          .order('popular_score', ascending: false);

      if (response is List) {
        return response.map((json) => Business.fromJson(json)).toList();
      }
    } catch (error, stackTrace) {
      debugPrint('Error searching businesses: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return [];
  }

  Future<List<Business>> getPopularBusinesses() async {
    try {
      final response = await _client
          .from('businesses')
          .select()
          .order('popular_score', ascending: false);

      if (response is List) {
        return response.map((json) => Business.fromJson(json)).toList();
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching popular businesses: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return [];
  }

  Future<Business?> getBusinessById(String id) async {
    try {
      final response =
          await _client.from('businesses').select().eq('id', id).limit(1);

      if (response is List && response.isNotEmpty) {
        return Business.fromJson(response.first);
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching business by id: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return null;
  }
}
