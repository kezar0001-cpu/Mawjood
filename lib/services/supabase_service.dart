import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

import '../config/env_config.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/business_claim.dart';

class SupabaseService {
  // Track initialization state to avoid accessing uninitialized instance
  static bool _isInitialized = false;

  /// Safe getter for Supabase client with null-safety checks
  /// This prevents "Null check operator used on a null value" errors on Web
  static SupabaseClient get client {
    if (!_isInitialized) {
      debugPrint('❌ [SUPABASE] Attempting to access client before initialization');
      throw StateError(
        'Supabase has not been initialized. '
        'Call SupabaseService.initialize() and wait for it to complete '
        'before accessing the client.',
      );
    }

    try {
      // Access Supabase.instance only after we know it's initialized
      final instance = Supabase.instance;
      final supabaseClient = instance.client;

      return supabaseClient;
    } catch (e) {
      debugPrint('❌ [SUPABASE] Error accessing client: $e');
      debugPrint('This usually means Supabase.initialize() failed or was not called.');
      rethrow;
    }
  }

  /// Check if Supabase has been initialized
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    debugPrint('🔧 [SUPABASE] Starting initialization...');
    debugPrint('🌐 [SUPABASE] Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

    // Validate configuration before initializing
    final configError = EnvConfig.configurationError;
    if (configError != null) {
      debugPrint('❌ [SUPABASE] Configuration error: $configError');
      throw Exception('Supabase configuration error: $configError');
    }

    debugPrint('✓ [SUPABASE] Configuration validated');

    final url = kIsWeb
        ? 'https://yywjdkunrkakxwgdwsjz.supabase.co'
        : EnvConfig.supabaseUrl;

    final anonKey = kIsWeb
        ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5d2pka3Vucmtha3h3Z2R3c2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzMjQwMjYsImV4cCI6MjA3OTkwMDAyNn0.TjviqrZWd1wUnTFS8YpbXDrH3BfidpmgQkgALZQNzs4'
        : EnvConfig.supabaseAnonKey;

    debugPrint('🔗 [SUPABASE] URL: $url');
    debugPrint('🔑 [SUPABASE] AnonKey: ${anonKey.substring(0, 20)}...');

    try {
      // Initialize with absolute URL - NEVER use relative paths
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );

      // Mark as initialized only after successful completion
      _isInitialized = true;

      debugPrint('✅ [SUPABASE] Initialization successful');
      debugPrint('✓ [SUPABASE] Client ready: ${isInitialized}');
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Initialization failed: $e');
      debugPrint('Stack: $stackTrace');

      // Ensure flag remains false on failure
      _isInitialized = false;

      rethrow;
    }
  }

  static Future<List<Category>> getCategories() async {
    debugPrint('📂 [SUPABASE] getCategories called');

    if (!_isInitialized) {
      debugPrint('⚠️ [SUPABASE] getCategories called before initialization');
      return [];
    }

    try {
      final response =
          await client.from('categories').select().order('name_ar', ascending: true);
      if (response is List) {
        debugPrint('✅ [SUPABASE] Fetched ${response.length} categories');
        return response.map((item) => Category.fromMap(item)).toList();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [SUPABASE] Error fetching categories: $e');
      debugPrint('Stack: $stackTrace');
      return [];
    }
    return [];
  }

  static Future<List<Business>> getBusinessesByCategory(String categoryId) async {
    if (!_isInitialized) {
      debugPrint('⚠️ [SUPABASE] getBusinessesByCategory called before initialization');
      return [];
    }

    try {
      final response = await client
          .from('businesses')
          .select()
          .eq('category_id', categoryId)
          .order('name', ascending: true);
      if (response is List) {
        return response.map((item) => Business.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint('❌ [SUPABASE] Error fetching businesses: $e');
      return [];
    }
    return [];
  }

  static Future<List<Business>> searchBusinesses(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    if (!_isInitialized) {
      debugPrint('⚠️ [SUPABASE] searchBusinesses called before initialization');
      return [];
    }

    try {
      final response = await client
          .from('businesses')
          .select()
          .or('name.ilike.%$trimmed%,description.ilike.%$trimmed%')
          .order('name', ascending: true);
      if (response is List) {
        return response.map((item) => Business.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint('❌ [SUPABASE] Error searching businesses: $e');
      return [];
    }
    return [];
  }

  static Future<Business?> getBusinessById(String id) async {
    if (!_isInitialized) {
      debugPrint('⚠️ [SUPABASE] getBusinessById called before initialization');
      return null;
    }

    try {
      final response = await client
          .from('businesses')
          .select()
          .eq('id', id)
          .limit(1)
          .maybeSingle();
      if (response is Map<String, dynamic>) {
        // Get review count for this business
        final reviewCountResponse = await client
            .from('reviews')
            .select('id')
            .eq('business_id', id)
            .count(CountOption.exact);

        final reviewCount = reviewCountResponse.count ?? 0;

        // Add review count to the business data
        response['review_count'] = reviewCount;

        return Business.fromMap(response);
      }
    } catch (e) {
      debugPrint('❌ [SUPABASE] Error fetching business by ID: $e');
      return null;
    }
    return null;
  }

  // Review-related methods
  static Future<List<Review>> getReviewsForBusiness(String businessId) async {
    try {
      final response = await client
          .from('reviews')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);
      if (response is List) {
        return response.map((item) => Review.fromMap(item)).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  static Future<Review?> submitReview({
    required String businessId,
    required String userName,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;

      final response = await client
          .from('reviews')
          .insert({
            'business_id': businessId,
            'user_id': userId,
            'user_name': userName,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();

      if (response is Map<String, dynamic>) {
        return Review.fromMap(response);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<bool> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      await client
          .from('reviews')
          .update({
            'rating': rating,
            'comment': comment,
          })
          .eq('id', reviewId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteReview(String reviewId) async {
    try {
      await client.from('reviews').delete().eq('id', reviewId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Business claim methods
  static Future<BusinessClaim?> submitBusinessClaim({
    required String businessId,
    required String userName,
    required String userEmail,
    String? userPhone,
    List<String>? proofDocuments,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from('business_claims')
          .insert({
            'business_id': businessId,
            'user_id': userId,
            'user_name': userName,
            'user_email': userEmail,
            'user_phone': userPhone,
            'proof_documents': proofDocuments ?? [],
          })
          .select()
          .single();

      if (response is Map<String, dynamic>) {
        return BusinessClaim.fromMap(response);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<BusinessClaim?> getBusinessClaimForUser(String businessId) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from('business_claims')
          .select()
          .eq('business_id', businessId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response is Map<String, dynamic>) {
        return BusinessClaim.fromMap(response);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
