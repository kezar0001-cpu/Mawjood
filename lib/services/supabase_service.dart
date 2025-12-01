import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

import '../config/env_config.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/business_claim.dart';

class SupabaseService {
  final SupabaseClient _client;
  bool _isInitialized = false;

  SupabaseService(this._client); // Constructor now takes SupabaseClient

  bool get isInitialized => _isInitialized;

  // Static factory to initialize and provide a configured instance (for main.dart)
  static Future<SupabaseService> initializeAndCreate() async {
    debugPrint('[SUPABASE] Starting initialization...');

    EnvConfig env;
    try {
      env = EnvConfig.load(); // Direct load for app startup
    } catch (e, s) {
      debugPrint('[SUPABASE] CRITICAL: Failed to load environment config: $e');
      debugPrint('Stack: $s');
      rethrow;
    }

    final configError = env.configurationError;

    if (configError != null) {
      debugPrint('[SUPABASE] Configuration error found: "$configError"');
      throw Exception('Supabase configuration error: $configError');
    }

    debugPrint('[SUPABASE] Configuration validated');
    debugPrint('[SUPABASE] URL: ${env.supabaseUrl}');
    debugPrint('[SUPABASE] AnonKey: ${env.supabaseAnonKey.isNotEmpty ? "PRESENT" : "MISSING"}');

    try {
      await Supabase.initialize(
        url: env.supabaseUrl,
        anonKey: env.supabaseAnonKey,
      );

      final service = SupabaseService(Supabase.instance.client);
      service._isInitialized = true; // Mark this instance as initialized
      debugPrint('[SUPABASE] Initialization successful');
      return service;
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Initialization failed: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  // Generic fetch method with error handling
  Future<List<T>> _fetch<T>(
    Future<List<Map<String, dynamic>>> request,
    T Function(Map<String, dynamic>) fromMap,
    String methodName,
  ) async {
    // Check initialization status of this specific instance
    if (!_isInitialized) {
      debugPrint('[SUPABASE] $methodName called before initialization');
      throw StateError('SupabaseService instance not initialized.');
    }
    try {
      final response = await request;
      return response.map(fromMap).toList();
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Error in $methodName: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Future<List<Category>> getCategories() {
    return _fetch(
      _client.from('categories').select().order('name_ar', ascending: true).then((res) => List<Map<String, dynamic>>.from(res)),
      Category.fromMap,
      'getCategories',
    );
  }

  Future<List<Business>> getBusinessesByCategory(String categoryId) {
    return _fetch(
      _client.from('businesses').select().eq('category_id', categoryId).order('name', ascending: true).then((res) => List<Map<String, dynamic>>.from(res)),
      Business.fromMap,
      'getBusinessesByCategory',
    );
  }

  Future<List<Business>> searchBusinesses(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value([]);

    return _fetch(
      _client.from('businesses').select().or('name.ilike.%$trimmed%,description.ilike.%$trimmed%').order('name', ascending: true).then((res) => List<Map<String, dynamic>>.from(res)),
      Business.fromMap,
      'searchBusinesses',
    );
  }

  Future<Business?> getBusinessById(String id) async {
    if (!_isInitialized) {
      debugPrint('[SUPABASE] getBusinessById called before initialization');
      return null;
    }
    try {
      final response = await _client.from('businesses').select().eq('id', id).limit(1).maybeSingle();
      if (response == null) return null;

      final reviewCountResponse = await _client.from('reviews').select('id').eq('business_id', id).count(CountOption.exact);
      response['review_count'] = reviewCountResponse.count ?? 0;
      return Business.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Error fetching business by ID: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Future<List<Review>> getReviewsForBusiness(String businessId) {
    return _fetch(
      _client.from('reviews').select().eq('business_id', businessId).order('created_at', ascending: false).then((res) => List<Map<String, dynamic>>.from(res)),
      Review.fromMap,
      'getReviewsForBusiness',
    );
  }

  Future<Review> submitReview({
    required String businessId,
    required String userName,
    required int rating,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to submit a review');
    if (userName.isEmpty) throw Exception('User name cannot be empty');

    try {
      final response = await _client.from('reviews').insert({
        'business_id': businessId,
        'user_id': userId,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
      }).select().single();
      return Review.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Error submitting review: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to update a review');

    try {
      await _client.from('reviews').update({
        'rating': rating,
        'comment': comment,
      }).eq('id', reviewId).eq('user_id', userId);
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Error updating review: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to delete a review');

    try {
      await _client.from('reviews').delete().eq('id', reviewId).eq('user_id', userId);
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Error deleting review: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Future<BusinessClaim> submitBusinessClaim({
    required String businessId,
    required String userName,
    required String userEmail,
    String? userPhone,
    List<String>? proofDocuments,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to claim a business');

    try {
      final response = await _client.from('business_claims').insert({
        'business_id': businessId,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'user_phone': userPhone,
        'proof_documents': proofDocuments ?? [],
      }).select().single();
      return BusinessClaim.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Error submitting business claim: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Future<BusinessClaim?> getBusinessClaimForUser(String businessId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('business_claims')
          .select()
          .eq('business_id', businessId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return BusinessClaim.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('[SUPABASE] Error getting business claim for user: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }
}

// Riverpod provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  // Ensure Supabase.instance.client is available before creating the service
  // This provider assumes Supabase.initialize has already been called in main()
  final client = Supabase.instance.client;
  final service = SupabaseService(client);
  service._isInitialized = true; // Mark as initialized when provided
  return service;
});
