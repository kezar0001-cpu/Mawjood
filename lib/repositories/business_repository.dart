import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../services/supabase_service.dart';

class BusinessRepository {
  final SupabaseService _supabaseService;

  BusinessRepository(this._supabaseService); // Constructor takes SupabaseService

  Future<List<Business>> fetchByCategory(String categoryId) {
    return _supabaseService.getBusinessesByCategory(categoryId); // Use injected service
  }

  Future<List<Business>> searchBusinesses(String query) {
    return _supabaseService.searchBusinesses(query); // Use injected service
  }

  Future<Business?> fetchById(String id) {
    return _supabaseService.getBusinessById(id); // Use injected service
  }
}

// Riverpod provider for BusinessRepository
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return BusinessRepository(supabaseService);
});
