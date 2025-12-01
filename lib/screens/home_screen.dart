import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawjood/models/business.dart';
import 'package:mawjood/models/category.dart';
import 'package:mawjood/providers/business_provider.dart';
import 'package:mawjood/providers/category_provider.dart';
import 'package:mawjood/services/connectivity_service.dart'; // Keep this import for the provider itself if needed elsewhere
import 'package:mawjood/services/cache_service.dart';
import 'package:mawjood/widgets/business_card.dart';
import 'package:mawjood/widgets/category_card.dart';
import 'package:mawjood/widgets/mawjood_search_bar.dart';
import 'package:mawjood/widgets/offline_indicator.dart';
import 'business_list_screen.dart';
import 'business_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    // Clear caches to force refetch
    final cache = ref.read(cacheServiceProvider);
    await cache.clearAllCaches();
    ref.invalidate(categoriesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('موجود', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
          ),
        ],
      ),
      body: OfflineIndicator(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
                    },
                    child: MawjoodSearchBar(
                      controller: _searchController,
                      onSubmit: (_) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('الفئات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('لا توجد فئات متاحة'),
                      ));
                    }
                    return SizedBox(
                      height: 120,
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
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  )),
                  error: (err, stack) => Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('خطأ في تحميل الفئات: $err'),
                  )),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('أعمال مميزة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('لا توجد أعمال مميزة متاحة'),
                      ));
                    }
                    final firstCategoryId = categories.first.id;
                    final businessesAsync = ref.watch(businessesByCategoryProvider(firstCategoryId));

                    return businessesAsync.when(
                      data: (businesses) {
                        if (businesses.isEmpty) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('لا توجد أعمال في هذه الفئة'),
                          ));
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
                      loading: () => const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      )),
                      error: (err, stack) => Center(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text('خطأ في تحميل الأعمال: $err'),
                      )),
                    );
                  },
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  )),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
