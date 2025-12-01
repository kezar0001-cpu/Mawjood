import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawjood/models/business.dart';
import 'package:mawjood/models/category.dart';
import 'package:mawjood/providers/business_provider.dart';
import 'package:mawjood/providers/category_provider.dart';
import 'package:mawjood/services/connectivity_service.dart'; // Keep this import for the provider itself if needed elsewhere
import 'package:mawjood/widgets/business_card.dart';
import 'package:mawjood/widgets/category_card.dart';
import 'package:mawjood/widgets/mawjood_search_bar.dart';
import 'package:mawjood/widgets/offline_indicator.dart';
import 'business_list_screen.dart';
import 'business_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final _searchController = TextEditingController(); // Dummy controller for MawjoodSearchBar

    return Scaffold(
      appBar: AppBar(
        title: const Text('موجود', style: TextStyle(fontWeight: FontWeight.bold)), // Mawjood title
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(categoriesProvider);
              // Invalidate businesses as well.
              // This might need a more granular approach if there are many business providers
              // For simplicity, we can invalidate specific ones if a featured list is used.
              // For now, it will refresh when category changes.
            },
          ),
        ],
      ),
      body: OfflineIndicator( // Wrap the entire body with OfflineIndicator
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell( // Use InkWell for onTap behavior
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
                },
                child: MawjoodSearchBar(
                  controller: _searchController,
                  onSubmit: (_) { // onSubmit is required but we handle navigation via InkWell
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('الفئات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Categories
                    ),
                    categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Center(child: Text('لا توجد فئات متاحة')); // No categories available
                        }
                        return SizedBox(
                          height: 120, // Height for horizontal category list
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return CategoryCard(
                                category: category,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BusinessListScreen(category: category),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('خطأ في تحميل الفئات: $err')), // Error loading categories
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('أعمال مميزة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Featured Businesses
                    ),
                    // For MVP, we'll just show businesses from the first category if available
                    categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Center(child: Text('لا توجد أعمال مميزة متاحة')); // No featured businesses available
                        }
                        final firstCategoryId = categories.first.id;
                        final businessesAsync = ref.watch(businessesByCategoryProvider(firstCategoryId));

                        return businessesAsync.when(
                          data: (businesses) {
                            if (businesses.isEmpty) {
                              return const Center(child: Text('لا توجد أعمال في هذه الفئة')); // No businesses in this category
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: businesses.length,
                              itemBuilder: (context, index) {
                                final business = businesses[index];
                                return BusinessCard(
                                  business: business,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BusinessDetailScreen(businessId: business.id, initialBusiness: business),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Center(child: Text('خطأ في تحميل الأعمال: $err')), // Error loading businesses
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => const SizedBox.shrink(), // Error already handled above for categories
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}