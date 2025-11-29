import 'package:flutter/material.dart';

import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../utils/app_colors.dart';
import '../utils/app_text.dart';
import '../widgets/category_card.dart';
import '../widgets/mawjood_search_bar.dart';
import 'business_list_screen.dart';
import 'settings_screen.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> _categoriesFuture;
  final TextEditingController _searchController = TextEditingController();
  final CategoryRepository _categoryRepository = CategoryRepository();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryRepository.fetchAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _categoriesFuture = _categoryRepository.fetchAll();
    });
    await _categoriesFuture;
  }

  void _openSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(initialQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary search entry point with soft shadow and RTL-friendly hint.
                _buildSearchBar(),
                const SizedBox(height: 16),
                // Section title row with mock-mode badge for transparency.
                _buildSectionHeader(),
                const SizedBox(height: 16),
                // Premium grid of categories with refined spacing.
                _buildCategoryGrid(),
              ],
            ),
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
    return MawjoodSearchBar(
      controller: _searchController,
      onSubmit: _openSearch,
      onChanged: (_) => setState(() {}),
      onFilterTap: () => _openSearch(_searchController.text),
    );
  }

  /// Section header with clear titling and a restyled mock badge for transparency.
  Widget _buildSectionHeader() {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppText.categoriesTitle,
                textAlign: TextAlign.right,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر مجالاً للبدء في الاستكشاف',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black54),
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
          return const _CategoryShimmerGrid();
        }
        if (snapshot.hasError) {
          return const _ErrorBanner(message: 'تعذر تحميل التصنيفات من الخادم');
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const _ErrorBanner(message: 'لا توجد تصنيفات متاحة حالياً');
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = (constraints.maxWidth / 180).floor().clamp(2, 4);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessListScreen(category: category),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CategoryShimmerGrid extends StatelessWidget {
  const _CategoryShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDED),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 14,
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
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
      padding: EdgeInsetsDirectional.fromSTEB(16, statusBarPadding + 8, 16, 16),
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
