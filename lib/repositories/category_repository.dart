import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../services/supabase_service.dart';

class CategoryRepository {
  CategoryRepository();

  final SupabaseClient _client = SupabaseService.client;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.from('categories').select();
      if (response is List) {
        return response.map((json) => Category.fromJson(json)).toList();
      }
    } catch (error, stackTrace) {
      debugPrint('Error loading categories: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return [];
  }
}
