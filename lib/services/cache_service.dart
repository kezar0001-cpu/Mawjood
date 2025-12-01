import 'package:hive_flutter/hive_flutter.dart';
import '../models/business.dart';
import '../models/category.dart';

class CacheService {
  static const String _categoriesBox = 'categories_cache';
  static const String _businessesBox = 'businesses_cache';
  static const String _recentSearchesBox = 'recent_searches';

  static const Duration _categoriesCacheDuration = Duration(hours: 24);
  static const Duration _businessesCacheDuration = Duration(hours: 1);
  static const int _maxRecentSearches = 10;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(BusinessAdapter());
    Hive.registerAdapter(CategoryAdapter());

    // Open boxes
    await Hive.openBox<Category>(_categoriesBox);
    await Hive.openBox<Business>(_businessesBox);
    await Hive.openBox<String>(_recentSearchesBox);
  }

  // Categories Cache
  static Future<void> cacheCategories(List<Category> categories) async {
    final box = Hive.box<Category>(_categoriesBox);
    await box.clear();

    final Map<String, Category> categoriesMap = {
      for (var category in categories) category.id: category,
    };

    await box.putAll(categoriesMap);
    await _storeTimestamp(_categoriesBox);
  }

  static Future<List<Category>?> getCachedCategories() async {
    final box = Hive.box<Category>(_categoriesBox);

    if (box.isEmpty) return null;

    final isCacheValid = await _isCacheValid(_categoriesBox, _categoriesCacheDuration);
    if (!isCacheValid) {
      await box.clear();
      return null;
    }

    return box.values
        .where((item) => item is Category)
        .cast<Category>()
        .toList();
  }

  // Businesses Cache (by category)
  static Future<void> cacheBusinesses(String categoryId, List<Business> businesses) async {
    final box = Hive.box<Business>(_businessesBox);

    // Clear old businesses for this category
    final keysToDelete = box.keys
        .where((key) => key.toString().startsWith('${categoryId}_'))
        .toList();
    await box.deleteAll(keysToDelete);

    // Store new businesses
    final Map<String, Business> businessesMap = {
      for (var business in businesses)
        '${categoryId}_${business.id}': business,
    };

    await box.putAll(businessesMap);
    await _storeTimestamp('${_businessesBox}_$categoryId');
  }

  static Future<List<Business>?> getCachedBusinesses(String categoryId) async {
    final box = Hive.box<Business>(_businessesBox);

    final isCacheValid = await _isCacheValid(
      '${_businessesBox}_$categoryId',
      _businessesCacheDuration,
    );

    if (!isCacheValid) {
      final keysToDelete = box.keys
          .where((key) => key.toString().startsWith('${categoryId}_'))
          .toList();
      await box.deleteAll(keysToDelete);
      return null;
    }

    return box.values
        .where((business) => business.categoryId == categoryId)
        .toList();
  }

  // Search Results Cache (generic key-value)
  static Future<void> cacheSearchResults(String query, List<Business> businesses) async {
    final box = Hive.box<Business>(_businessesBox);
    final cacheKey = 'search_${query.toLowerCase()}';

    // Clear old search results
    final keysToDelete = box.keys
        .where((key) => key.toString().startsWith(cacheKey))
        .toList();
    await box.deleteAll(keysToDelete);

    // Store new search results
    final Map<String, Business> businessesMap = {
      for (var business in businesses)
        '${cacheKey}_${business.id}': business,
    };

    await box.putAll(businessesMap);
    await _storeTimestamp('search_$query');
  }

  static Future<List<Business>?> getCachedSearchResults(String query) async {
    final box = Hive.box<Business>(_businessesBox);
    final cacheKey = 'search_${query.toLowerCase()}';

    final isCacheValid = await _isCacheValid(
      'search_$query',
      _businessesCacheDuration,
    );

    if (!isCacheValid) {
      final keysToDelete = box.keys
          .where((key) => key.toString().startsWith(cacheKey))
          .toList();
      await box.deleteAll(keysToDelete);
      return null;
    }

    return box.values
        .where((business) => box.keys.any((key) =>
            key.toString().startsWith(cacheKey)))
        .toList();
  }

  // Recent Searches
  static Future<void> addRecentSearch(String query) async {
    final box = Hive.box<String>(_recentSearchesBox);

    // Remove if already exists
    final existingKey = box.keys.firstWhere(
      (key) => box.get(key) == query,
      orElse: () => null,
    );
    if (existingKey != null) {
      await box.delete(existingKey);
    }

    // Add to beginning
    await box.put(DateTime.now().millisecondsSinceEpoch.toString(), query);

    // Keep only last N searches
    if (box.length > _maxRecentSearches) {
      final sortedKeys = box.keys.toList()..sort();
      final keysToDelete = sortedKeys.take(box.length - _maxRecentSearches);
      await box.deleteAll(keysToDelete);
    }
  }

  static Future<List<String>> getRecentSearches() async {
    final box = Hive.box<String>(_recentSearchesBox);

    final searches = box.values.toList();
    return searches.reversed.toList(); // Most recent first
  }

  static Future<void> clearRecentSearches() async {
    final box = Hive.box<String>(_recentSearchesBox);
    await box.clear();
  }

  // Helper: Store timestamp
  static Future<void> _storeTimestamp(String key) async {
    final timestampBox = await Hive.openBox('timestamps');
    await timestampBox.put(key, DateTime.now().millisecondsSinceEpoch);
  }

  // Helper: Check cache validity
  static Future<bool> _isCacheValid(String key, Duration validDuration) async {
    final timestampBox = await Hive.openBox('timestamps');
    final timestamp = timestampBox.get(key);

    if (timestamp == null) return false;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final age = DateTime.now().difference(cachedAt);

    return age <= validDuration;
  }

  // Clear all caches
  static Future<void> clearAllCaches() async {
    await Hive.box<Category>(_categoriesBox).clear();
    await Hive.box<Business>(_businessesBox).clear();
    final timestampBox = await Hive.openBox('timestamps');
    await timestampBox.clear();
  }
}
