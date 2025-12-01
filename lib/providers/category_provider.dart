import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart'; // Import the correct provider
import '../services/cache_service.dart';
import '../services/connectivity_service.dart'; // Import the new connectivity provider

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final isOnline = ref.watch(connectivityStatusProvider); // Use the new provider
  final cacheService = ref.watch(cacheServiceProvider); // Get CacheService instance

  // Try cache first
  final cachedCategories = await cacheService.getCachedCategories();
  if (cachedCategories != null && cachedCategories.isNotEmpty) {
    return cachedCategories;
  }

  // If offline and no cache, return empty
  if (!isOnline) { // Use the online status from the provider
    return [];
  }

  // Fetch from API
  try {
    final categories = await repository.fetchAll();

    // Cache the results
    if (categories.isNotEmpty) {
      await cacheService.cacheCategories(categories);
    }

    return categories;
  } catch (e) {
    // If API fails, try cache even if expired
    final expiredCache = await cacheService.getCachedCategories();
    if (expiredCache != null && expiredCache.isNotEmpty) {
      return expiredCache;
    }
    rethrow;
  }
});

// Force refresh categories
final refreshCategoriesProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(categoriesProvider);
  };
});
