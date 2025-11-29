import '../models/category.dart';
import '../services/supabase_service.dart';

class CategoryRepository {
  Future<List<Category>> fetchAll() {
    return SupabaseService.getCategories();
  }
}
