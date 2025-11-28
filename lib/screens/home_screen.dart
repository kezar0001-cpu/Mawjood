import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text.dart';
import '../widgets/category_card.dart';
import 'business_list_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.service});

  static const String routeName = '/';
  final SupabaseService service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> _categoriesFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = widget.service.getCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: {
      'query': query,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(AppText.appName, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              AppText.tagline,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                onSubmitted: _openSearch,
                decoration: InputDecoration(
                  hintText: AppText.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => _openSearch(_searchController.text),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Text(
                    AppText.categoriesTitle,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  SizedBox(width: 8),
                  Chip(
                    backgroundColor: AppColors.primary,
                    label: Text(
                      AppText.mockBadge,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Category>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text('تعذر تحميل التصنيفات');
                  }
                  final categories = snapshot.data ?? [];
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryCard(
                        category: category,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            BusinessListScreen.routeName,
                            arguments: {'id': category.id, 'name': category.name},
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSearch(_searchController.text),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.search),
        label: const Text('بحث سريع'),
      ),
    );
  }
}
