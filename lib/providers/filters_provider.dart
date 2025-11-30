import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/filters.dart';

// State notifier for managing filters
class FiltersNotifier extends StateNotifier<BusinessFilters> {
  FiltersNotifier() : super(BusinessFilters.defaults());

  void updateSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void updateMinRating(int? minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  void toggleTag(String tag) {
    final currentTags = List<String>.from(state.tags);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      currentTags.add(tag);
    }
    state = state.copyWith(tags: currentTags);
  }

  void reset() {
    state = BusinessFilters.defaults();
  }

  void applyFilters(BusinessFilters filters) {
    state = filters;
  }
}

// Filters provider
final filtersProvider = StateNotifierProvider<FiltersNotifier, BusinessFilters>((ref) {
  return FiltersNotifier();
});
