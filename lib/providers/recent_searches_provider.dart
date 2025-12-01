import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

// Recent searches state notifier
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final CacheService _cacheService; // Add CacheService as a dependency

  RecentSearchesNotifier(this._cacheService) : super([]) {
    _loadSearches();
  }

  Future<void> _loadSearches() async {
    state = await _cacheService.getRecentSearches();
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    await _cacheService.addRecentSearch(query.trim());
    state = await _cacheService.getRecentSearches();
  }

  Future<void> clearAll() async {
    await _cacheService.clearRecentSearches();
    state = [];
  }

  Future<void> removeSearch(String query) async {
    await _cacheService.removeRecentSearch(query);
    state = await _cacheService.getRecentSearches();
  }

  Future<void> refresh() async {
    state = await _cacheService.getRecentSearches();
  }
}

// Recent searches provider
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  final cacheService = ref.watch(cacheServiceProvider); // Watch cacheService
  return RecentSearchesNotifier(cacheService);
});
