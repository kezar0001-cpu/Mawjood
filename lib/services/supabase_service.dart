import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

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

  List<Business> get _mockBusinesses => [
        Business(
          id: 'b1',
          name: 'مطعم دجلة',
          categoryId: '1',
          categoryName: 'مطاعم',
          city: 'بغداد',
          district: 'المنصور',
          description: 'أطباق عراقية أصلية مع جلسات عائلية مريحة.',
          images: [
            'https://images.unsplash.com/photo-1550547660-d9450f859349',
            'https://images.unsplash.com/photo-1604908177683-2ba522996acd',
          ],
          phone: '+9647700000001',
          whatsapp: '+9647700000001',
          mapsUrl: 'https://maps.google.com?q=Baghdad',
          openingHours: '١١:٠٠ صباحاً - ١٢:٠٠ ليلاً',
        ),
        Business(
          id: 'b2',
          name: 'مقهى البصرة',
          categoryId: '2',
          categoryName: 'مقاهي',
          city: 'البصرة',
          district: 'الجزائر',
          description: 'قهوة عربية، إنترنت سريع، ومساحات عمل هادئة.',
          images: [
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085',
          ],
          phone: '+9647700000002',
          whatsapp: '+9647700000002',
          mapsUrl: 'https://maps.google.com?q=Basra',
          openingHours: '٨:٠٠ صباحاً - ١١:٠٠ ليلاً',
        ),
        Business(
          id: 'b3',
          name: 'عيادة الشفاء',
          categoryId: '3',
          categoryName: 'عيادات',
          city: 'أربيل',
          district: 'عينكاوة',
          description: 'خدمات طبية متخصصة مع فريق محترف.',
          images: [
            'https://images.unsplash.com/photo-1582719478248-54e9f2af8295',
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773',
          ],
          phone: '+9647700000003',
          whatsapp: '+9647700000003',
          mapsUrl: 'https://maps.google.com?q=Erbil',
          openingHours: '٩:٠٠ صباحاً - ٩:٠٠ مساءً',
        ),
        Business(
          id: 'b4',
          name: 'خدمة التوصيل السريع',
          categoryId: '4',
          categoryName: 'خدمات',
          city: 'بغداد',
          district: 'زيونة',
          description: 'توصيل سريع وآمن داخل بغداد.',
          images: [
            'https://images.unsplash.com/photo-1541417904950-b855846fe074',
          ],
          phone: '+9647700000004',
          whatsapp: '+9647700000004',
          mapsUrl: 'https://maps.google.com?q=Baghdad',
          openingHours: 'متاح ٢٤ ساعة',
        ),
        Business(
          id: 'b5',
          name: 'متجر الرافدين',
          categoryId: '5',
          categoryName: 'متاجر',
          city: 'الموصل',
          district: 'الزهور',
          description: 'منتجات محلية وإلكترونيات بشحن داخل العراق.',
          images: [
            'https://images.unsplash.com/photo-1522199710521-72d69614c702',
          ],
          phone: '+9647700000005',
          whatsapp: '+9647700000005',
          mapsUrl: 'https://maps.google.com?q=Mosul',
          openingHours: '١٠:٠٠ صباحاً - ١٠:٠٠ مساءً',
        ),
        Business(
          id: 'b6',
          name: 'مركز المستقبل للتدريب',
          categoryId: '6',
          categoryName: 'تعليم',
          city: 'بغداد',
          district: 'الكرادة',
          description: 'دورات برمجة ولغات مع مدربين معتمدين.',
          images: [
            'https://images.unsplash.com/photo-1521737604893-d14cc237f11d',
            'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d',
          ],
          phone: '+9647700000006',
          whatsapp: '+9647700000006',
          mapsUrl: 'https://maps.google.com?q=Baghdad',
          openingHours: '٩:٠٠ صباحاً - ٨:٠٠ مساءً',
        ),
      ];

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
