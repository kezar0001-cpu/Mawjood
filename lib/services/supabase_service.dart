import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../config/env_config.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/business_claim.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static SupabaseClient get client {
    if (!_isInitialized) {
      debugPrint('❌ [SUPABASE] Attempting to access client before initialization');
      throw StateError(
        'Supabase has not been initialized. Call SupabaseService.initialize() '
        'and wait for it to complete before accessing the client.',
      );
    }
    return Supabase.instance.client;
  }

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    debugPrint('🔧 [SUPABASE] Starting initialization...');

    EnvConfig env;
    try {
      env = EnvConfig.load();
    } catch (e, s) {
      debugPrint('❌ [SUPABASE] CRITICAL: Failed to load environment config: $e');
      debugPrint('Stack: $s');
      rethrow;
    }

    final configError = env.configurationError;

    if (configError != null) {
      debugPrint('❌ [SUPABASE] Configuration error found: "$configError"');
      // Intentionally using toString() to ensure minified builds show the string message
      throw Exception('Supabase configuration error: $configError');
    }

    debugPrint('✓ [SUPABASE] Configuration validated');
    debugPrint('🔗 [SUPABASE] URL: ${env.supabaseUrl}');
    debugPrint('🔑 [SUPABASE] AnonKey: ${env.supabaseAnonKey.isNotEmpty ? "PRESENT" : "MISSING"}'); // Don't print actual key in logs if possible

    try {
      await Supabase.initialize(
        url: env.supabaseUrl,
        anonKey: env.supabaseAnonKey,
      );

      _isInitialized = true;
      debugPrint('✅ [SUPABASE] Initialization successful');
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Initialization failed: $e');
      debugPrint('Stack: $stackTrace');
      _isInitialized = false;
      rethrow;
    }
  }

  // Generic fetch method with error handling
  static Future<List<T>> _fetch<T>(
    Future<List<Map<String, dynamic>>> request,
    T Function(Map<String, dynamic>) fromMap,
    String methodName,
  ) async {
    if (!_isInitialized) {
      debugPrint('⚠️ [SUPABASE] $methodName called before initialization');
      return [];
    }
    try {
      final response = await request;
      return response.map(fromMap).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error in $methodName: $e');
      debugPrint('Stack: $stackTrace');
      rethrow; // Rethrow to be handled by the UI layer
    }
  }

  static Future<List<Category>> getCategories() {
    return _fetch(
      client.from('categories').select().order('name_ar', ascending: true).then((res) => List<Map<String, dynamic>>.from(res)),
      Category.fromMap,
      'getCategories',
    );
  }

  static Future<List<Business>> getBusinessesByCategory(String categoryId) {
    return _fetch(
      client.from('businesses').select().eq('category_id', categoryId).order('name', ascending: true).then((res) => List<Map<String, dynamic>>.from(res)),
      Business.fromMap,
      'getBusinessesByCategory',
    );
  }

  static Future<List<Business>> searchBusinesses(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value([]);

    return _fetch(
      client.from('businesses').select().or('name.ilike.%$trimmed%,description.ilike.%$trimmed%').order('name', ascending: true).then((res) => List<Map<String, dynamic>>.from(res)),
      Business.fromMap,
      'searchBusinesses',
    );
  }

  static Future<Business?> getBusinessById(String id) async {
    if (!_isInitialized) {
      debugPrint('⚠️ [SUPABASE] getBusinessById called before initialization');
      return null;
    }
    try {
      final response = await client.from('businesses').select().eq('id', id).limit(1).maybeSingle();
      if (response == null) return null;

      final reviewCountResponse = await client.from('reviews').select('id').eq('business_id', id).count(CountOption.exact);
      response['review_count'] = reviewCountResponse.count ?? 0;
      return Business.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error fetching business by ID: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  static Future<List<Review>> getReviewsForBusiness(String businessId) {
    return _fetch(
      client.from('reviews').select().eq('business_id', businessId).order('created_at', ascending: false).then((res) => List<Map<String, dynamic>>.from(res)),
      Review.fromMap,
      'getReviewsForBusiness',
    );
  }

  static Future<Review> submitReview({
    required String businessId,
    required String userName,
    required int rating,
    String? comment,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to submit a review');
    if (userName.isEmpty) throw Exception('User name cannot be empty');

    try {
      final response = await client.from('reviews').insert({
        'business_id': businessId,
        'user_id': userId,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
      }).select().single();
      return Review.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error submitting review: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  static Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to update a review');

    try {
      await client.from('reviews').update({
        'rating': rating,
        'comment': comment,
      }).eq('id', reviewId).eq('user_id', userId);
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error updating review: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  static Future<void> deleteReview(String reviewId) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to delete a review');

    try {
      await client.from('reviews').delete().eq('id', reviewId).eq('user_id', userId);
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error deleting review: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  static Future<BusinessClaim> submitBusinessClaim({
    required String businessId,
    required String userName,
    required String userEmail,
    String? userPhone,
    List<String>? proofDocuments,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in to claim a business');

    try {
      final response = await client.from('business_claims').insert({
        'business_id': businessId,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'user_phone': userPhone,
        'proof_documents': proofDocuments ?? [],
      }).select().single();
      return BusinessClaim.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error submitting business claim: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  static Future<BusinessClaim?> getBusinessClaimForUser(String businessId) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await client
          .from('business_claims')
          .select()
          .eq('business_id', businessId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return BusinessClaim.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error getting business claim for user: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }
}
