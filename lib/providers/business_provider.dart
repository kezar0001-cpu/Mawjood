import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../repositories/business_repository.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';

// Repository provider
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository();
});

// Businesses by category provider (family)
final businessesByCategoryProvider =
    FutureProvider.family<List<Business>, String>((ref, categoryId) async {
  final repository = ref.watch(businessRepositoryProvider);
  final connectivityService = ConnectivityService();

  // Try cache first
  final cachedBusinesses = await CacheService.getCachedBusinesses(categoryId);
  if (cachedBusinesses != null && cachedBusinesses.isNotEmpty) {
    return cachedBusinesses;
  }

  // If offline and no cache, return empty
  if (!connectivityService.isOnline) {
    return [];
  }

  // Fetch from API
  try {
    final businesses = await repository.fetchByCategory(categoryId);

    // Cache the results
    if (businesses.isNotEmpty) {
      await CacheService.cacheBusinesses(categoryId, businesses);
    }

    return businesses;
  } catch (e) {
    // If API fails, try cache even if expired
    final expiredCache = await CacheService.getCachedBusinesses(categoryId);
    if (expiredCache != null && expiredCache.isNotEmpty) {
      return expiredCache;
    }
    rethrow;
  }
});

// Search results provider (family)
final searchResultsProvider =
    FutureProvider.family<List<Business>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  final repository = ref.watch(businessRepositoryProvider);
  final connectivityService = ConnectivityService();

  // Try cache first
  final cachedResults = await CacheService.getCachedSearchResults(query);
  if (cachedResults != null && cachedResults.isNotEmpty) {
    return cachedResults;
  }

  // If offline and no cache, return empty
  if (!connectivityService.isOnline) {
    return [];
  }

  // Fetch from API
  try {
    final results = await repository.searchBusinesses(query);

    // Cache the results
    if (results.isNotEmpty) {
      await CacheService.cacheSearchResults(query, results);
    }

    // Add to recent searches
    if (query.trim().isNotEmpty) {
      await CacheService.addRecentSearch(query.trim());
    }

    return results;
  } catch (e) {
    // If API fails, try cache even if expired
    final expiredCache = await CacheService.getCachedSearchResults(query);
    if (expiredCache != null && expiredCache.isNotEmpty) {
      return expiredCache;
    }
    rethrow;
  }
});

// Single business provider
final businessByIdProvider =
    FutureProvider.family<Business?, String>((ref, businessId) async {
  final repository = ref.watch(businessRepositoryProvider);

  try {
    return await repository.fetchById(businessId);
  } catch (e) {
    return null;
  }
});
