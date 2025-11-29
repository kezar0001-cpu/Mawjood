import '../models/business.dart';
import '../services/supabase_service.dart';

class BusinessRepository {
  Future<List<Business>> fetchByCategory(String categoryId) {
    return SupabaseService.getBusinessesByCategory(categoryId);
  }

  Future<List<Business>> searchBusinesses(String query) {
    return SupabaseService.searchBusinesses(query);
  }

  Future<Business?> fetchById(String id) {
    return SupabaseService.getBusinessById(id);
  }
}
