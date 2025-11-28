import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../mock/mock_businesses.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../utils/app_colors.dart';

class SupabaseService {
  SupabaseService({
    this.client,
    this.useMock = true,
  });

  final SupabaseClient? client;
  final bool useMock;

  List<Category> get _mockCategories => const [
        Category(
          id: '1',
          name: 'مطاعم',
          icon: Icons.restaurant,
          color: AppColors.primary,
        ),
        Category(
          id: '2',
          name: 'مقاهي',
          icon: Icons.local_cafe,
          color: AppColors.primaryLight,
        ),
        Category(
          id: '3',
          name: 'عيادات',
          icon: Icons.local_hospital,
          color: AppColors.accentGold,
        ),
        Category(
          id: '4',
          name: 'خدمات',
          icon: Icons.build,
          color: AppColors.primary,
        ),
        Category(
          id: '5',
          name: 'متاجر',
          icon: Icons.store,
          color: AppColors.primaryLight,
        ),
        Category(
          id: '6',
          name: 'تعليم',
          icon: Icons.school,
          color: AppColors.accentGold,
        ),
      ];

  List<Business> get _mockBusinesses => mockBusinesses;

  Future<List<Category>> getCategories() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockCategories;
    }
    final response = await client!.from('categories').select();
    return (response as List).map((e) => Category.fromMap(e)).toList();
  }

  Future<List<Business>> getBusinessesByCategory(String categoryId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockBusinesses
          .where((business) => business.categoryId == categoryId)
          .toList();
    }
    final response =
        await client!.from('businesses').select().eq('category_id', categoryId);
    return (response as List).map((e) => Business.fromMap(e)).toList();
  }

  Future<List<Business>> searchBusinesses(String query) async {
    if (query.isEmpty) return [];
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      final lower = query.toLowerCase();
      return _mockBusinesses.where((business) {
        return business.name.toLowerCase().contains(lower) ||
            business.description.toLowerCase().contains(lower) ||
            business.city.toLowerCase().contains(lower) ||
            business.district.toLowerCase().contains(lower);
      }).toList();
    }
    final response = await client!
        .from('businesses')
        .select()
        .ilike('name', '%$query%');
    return (response as List).map((e) => Business.fromMap(e)).toList();
  }

  Future<Business?> getBusinessById(String id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      try {
        return _mockBusinesses.firstWhere((element) => element.id == id);
      } catch (_) {
        return null;
      }
    }
    final response = await client!.from('businesses').select().eq('id', id);
    if (response is List && response.isNotEmpty) {
      return Business.fromMap(response.first);
    }
    return null;
  }
}
