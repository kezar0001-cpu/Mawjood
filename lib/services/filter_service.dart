import '../models/business.dart';
import '../models/filters.dart';

List<Business> applyFilters(List<Business> all, BusinessFilters filters) {
  var filtered = List<Business>.from(all);

  if (filters.minRating != null) {
    filtered = filtered
        .where((business) => business.rating >= filters.minRating!)
        .toList();
  }

  if (filters.tags.isNotEmpty) {
    filtered = filtered
        .where(
          (business) {
            final businessTags =
                business.tags.map((tag) => tag.toLowerCase()).toList();
            return filters.tags.every((selectedTag) {
              final lowerSelected = selectedTag.toLowerCase();
              return businessTags.any((tag) => tag.contains(lowerSelected));
            });
          },
        )
        .toList();
  }

  switch (filters.sortBy) {
    case 'rating':
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case 'popular':
      filtered.sort((a, b) {
        final ratingCountA = a.ratingCount;
        final ratingCountB = b.ratingCount;
        if (ratingCountA == ratingCountB) {
          return b.rating.compareTo(a.rating);
        }
        return ratingCountB.compareTo(ratingCountA);
      });
      break;
    case 'price':
      filtered.sort((a, b) => a.name.compareTo(b.name));
      break;
    case 'nearest':
    default:
      break;
  }

  return filtered;
}
