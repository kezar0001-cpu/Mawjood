import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/env_config.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/business_claim.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    // Validate configuration before initializing
    final configError = EnvConfig.configurationError;
    if (configError != null) {
      throw Exception('Supabase configuration error: $configError');
    }

    // Initialize with absolute URL - NEVER use relative paths

await Supabase.initialize(
  url: kIsWeb
      ? 'https://yywjdkunrkakxwgdwsjz.supabase.co'     // FULL STATIC URL FOR WEB
      : EnvConfig.supabaseUrl,                  // Safe for mobile
  anonKey: kIsWeb
      ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5d2pka3Vucmtha3h3Z2R3c2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzMjQwMjYsImV4cCI6MjA3OTkwMDAyNn0.TjviqrZWd1wUnTFS8YpbXDrH3BfidpmgQkgALZQNzs4'                  // FULL STATIC KEY FOR WEB
      : EnvConfig.supabaseAnonKey,
);
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response =
          await client.from('categories').select().order('name_ar', ascending: true);
      if (response is List) {
        return response.map((item) => Category.fromMap(item)).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  static Future<List<Business>> getBusinessesByCategory(String categoryId) async {
    try {
      final response = await client
          .from('businesses')
          .select()
          .eq('category_id', categoryId)
          .order('name', ascending: true);
      if (response is List) {
        return response.map((item) => Business.fromMap(item)).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  static Future<List<Business>> searchBusinesses(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final response = await client
          .from('businesses')
          .select()
          .or('name.ilike.%$trimmed%,description.ilike.%$trimmed%')
          .order('name', ascending: true);
      if (response is List) {
        return response.map((item) => Business.fromMap(item)).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  static Future<Business?> getBusinessById(String id) async {
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
            .select('id', const FetchOptions(count: CountOption.exact))
            .eq('business_id', id);

        final reviewCount = reviewCountResponse.count ?? 0;

        // Add review count to the business data
        response['review_count'] = reviewCount;

        return Business.fromMap(response);
      }
    } catch (_) {
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
