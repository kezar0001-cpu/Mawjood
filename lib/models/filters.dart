class BusinessFilters {
  final String sortBy; // "nearest", "rating", "popular", "price"
  final int? minRating; // 4, 3, or null
  final List<String> tags; // ["delivery", "family", ...]

  const BusinessFilters({
    this.sortBy = 'nearest',
    this.minRating,
    this.tags = const [],
  });

  factory BusinessFilters.defaults() {
    return const BusinessFilters();
  }

  BusinessFilters copyWith({
    String? sortBy,
    int? minRating,
    List<String>? tags,
  }) {
    return BusinessFilters(
      sortBy: sortBy ?? this.sortBy,
      minRating: minRating ?? this.minRating,
      tags: tags ?? this.tags,
    );
  }

  bool get hasActiveFilters {
    return sortBy != 'nearest' || minRating != null || tags.isNotEmpty;
  }

  int get activeCount {
    var count = 0;
    if (sortBy != 'nearest') count++;
    if (minRating != null) count++;
    count += tags.length;
    return count;
  }
}
