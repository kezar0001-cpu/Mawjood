import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

// Recent searches state notifier
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]) {
    _loadSearches();
  }

  Future<void> _loadSearches() async {
    state = await CacheService.getRecentSearches();
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    await CacheService.addRecentSearch(query.trim());
    state = await CacheService.getRecentSearches();
  }

  Future<void> clearAll() async {
    await CacheService.clearRecentSearches();
    state = [];
  }

  Future<void> refresh() async {
    state = await CacheService.getRecentSearches();
  }
}

// Recent searches provider
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});
