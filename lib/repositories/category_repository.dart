import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/supabase_service.dart';

class CategoryRepository {
  final SupabaseService _supabaseService;

  CategoryRepository(this._supabaseService); // Constructor takes SupabaseService

  Future<List<Category>> fetchAll() {
    return _supabaseService.getCategories(); // Use injected service
  }
}

// Riverpod provider for CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return CategoryRepository(supabaseService);
});
