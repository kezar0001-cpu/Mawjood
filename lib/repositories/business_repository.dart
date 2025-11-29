import '../models/business.dart';
import '../services/supabase_service.dart';

class BusinessRepository {
  BusinessRepository();

  Future<List<Business>> getBusinessesByCategory(String categoryId) async {
    return SupabaseService.fetchBusinesses(categoryId: categoryId);
  }

  Future<List<Business>> searchBusinesses(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    return SupabaseService.fetchBusinesses(searchQuery: trimmed);
  }

  Future<List<Business>> getPopularBusinesses() async {
    return SupabaseService.fetchBusinesses();
  }

  Future<Business?> getBusinessById(String id) async {
    return SupabaseService.fetchBusinessById(id);
  }
}
