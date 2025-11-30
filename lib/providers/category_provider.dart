import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';

// Repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final connectivityService = ConnectivityService();

  // Try cache first
  final cachedCategories = await CacheService.getCachedCategories();
  if (cachedCategories != null && cachedCategories.isNotEmpty) {
    return cachedCategories;
  }

  // If offline and no cache, return empty
  if (!connectivityService.isOnline) {
    return [];
  }

  // Fetch from API
  try {
    final categories = await repository.fetchAll();

    // Cache the results
    if (categories.isNotEmpty) {
      await CacheService.cacheCategories(categories);
    }

    return categories;
  } catch (e) {
    // If API fails, try cache even if expired
    final expiredCache = await CacheService.getCachedCategories();
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
