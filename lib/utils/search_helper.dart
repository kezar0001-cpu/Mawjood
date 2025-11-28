import '../mock/mock_businesses.dart';
import '../models/business.dart';

List<Business> searchBusinessesLocally(String query, {List<Business> all = mockBusinesses}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return [];

  final lowerQuery = trimmed.toLowerCase();
  return all.where((business) {
    return business.name.toLowerCase().contains(lowerQuery) ||
        business.description.toLowerCase().contains(lowerQuery) ||
        business.categoryName.toLowerCase().contains(lowerQuery);
  }).toList();
}
