import '../mock/mock_businesses.dart';
import '../models/business.dart';

List<Business> searchBusinessesLocally(String query, {List<Business>? all}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return [];

  final lowerQuery = trimmed.toLowerCase();
  final businesses = all ?? mockBusinesses;
  return businesses.where((business) {
    return business.name.toLowerCase().contains(lowerQuery) ||
        (business.description?.toLowerCase() ?? '').contains(lowerQuery) ||
        (business.city?.toLowerCase() ?? '').contains(lowerQuery);
  }).toList();
}
