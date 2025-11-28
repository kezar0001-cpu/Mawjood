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
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Primary search entry point with soft shadow and RTL-friendly hint.
              _buildSearchBar(),
              const SizedBox(height: 24),
              // Section title row with mock-mode badge for transparency.
              _buildSectionHeader(),
              const SizedBox(height: 16),
              // Premium grid of categories with refined spacing.
              _buildCategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }

  /// Modernized app bar with centered branding and consistent settings access.
  PreferredSizeWidget _buildAppBar() {
    return _HomeHeader(
      onSettingsPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
    );
  }

  /// Redesigned search bar with rounded corners, subtle shadow, and themed icon.
  Widget _buildSearchBar() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                onSubmitted: _openSearch,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: AppText.searchHint,
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.45),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
              onPressed: () => _openSearch(_searchController.text),
              tooltip: AppText.searchHint,
            ),
          ],
        ),
      ),
    );
  }

  /// Section header with clear titling and a restyled mock badge for transparency.
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                AppText.categoriesTitle,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.darkText),
              ),
              SizedBox(height: 4),
              Text(
                'اختر مجالاً للبدء في الاستكشاف',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: const [
              Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                AppText.mockBadge,
                style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Premium-styled grid of category cards with consistent breathing room.
  Widget _buildCategoryGrid() {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('تعذر تحميل التصنيفات', textAlign: TextAlign.center),
          );
        }
        final categories = snapshot.data ?? [];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: 1,
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
    );
  }
}

class _HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const _HomeHeader({required this.onSettingsPressed});

  final VoidCallback onSettingsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(112);

  @override
  Widget build(BuildContext context) {
    final double statusBarPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsetsDirectional.fromSTEB(16, statusBarPadding + 12, 16, 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _HeaderIconButton(
              tooltip: AppText.settings,
              icon: Icons.settings_rounded,
              onTap: onSettingsPressed,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                AppText.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppText.tagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.tooltip, required this.icon, required this.onTap});

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
