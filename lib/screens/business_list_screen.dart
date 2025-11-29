import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business.dart';
import '../models/category.dart';
import '../models/filters.dart';
import '../repositories/business_repository.dart';
import '../services/filter_service.dart';
import '../utils/app_colors.dart';
import '../widgets/business_card.dart';
import '../widgets/mawjood_action_button.dart';
import '../widgets/mawjood_search_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'business_detail_screen.dart';
import 'search_results_screen.dart';

class BusinessListScreen extends StatefulWidget {
  BusinessListScreen({
    super.key,
    required this.category,
    this.businesses,
  });

  static const String routeName = '/business-list';

  final Category category;
  final List<Business>? businesses;

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _shimmerController;
  final BusinessRepository _repository = BusinessRepository();
  List<Business> _allBusinesses = [];
  List<Business> _filteredBusinesses = [];
  List<Business> _visibleBusinesses = [];
  BusinessFilters _filters = BusinessFilters.defaults();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _shimmerController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
          ..repeat();
    _loadBusinesses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched =
          widget.businesses ?? await _repository.fetchByCategory(widget.category.id);

      setState(() {
        _allBusinesses = fetched;
        _refreshVisibleBusinesses();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل الأنشطة حالياً';
      });
    }
  }

  void _handleSearch(String value) {
    _refreshVisibleBusinesses(query: value);
  }

  void _handleSubmit(String value) {
    _handleSearch(value);
    _openSearchResults(value);
  }

  void _openSearchResults(String value) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(initialQuery: value),
      ),
    );
  }

  void _refreshVisibleBusinesses({String? query}) {
    final filtered = applyFilters(_allBusinesses, _filters);
    final visible = _applySearchQuery(filtered, query ?? _searchController.text);

    setState(() {
      _filteredBusinesses = filtered;
      _visibleBusinesses = visible;
    });
  }

  List<Business> _applySearchQuery(List<Business> source, String query) {
    final searchQuery = query.trim().toLowerCase();
    if (searchQuery.isEmpty) return source;

    return source.where((business) {
      return business.name.toLowerCase().contains(searchQuery) ||
          business.description.toLowerCase().contains(searchQuery) ||
          business.city.toLowerCase().contains(searchQuery) ||
          business.features.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<BusinessFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterBottomSheet(
        currentFilters: _filters,
        onApply: (updatedFilters) {
          Navigator.of(context).pop(updatedFilters);
        },
      ),
    );

    if (result != null) {
      setState(() => _filters = result);
      _refreshVisibleBusinesses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('النتائج لـ ${widget.category.displayName}'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MawjoodSearchBar(
                  controller: _searchController,
                  onSubmit: _handleSubmit,
                  onChanged: _handleSearch,
                  onFilterTap: () => _openSearchResults(_searchController.text),
                  hintText: 'ابحث داخل ${widget.category.displayName}',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MawjoodActionButton(
                        icon: Icons.tune_rounded,
                        label: 'فلترة',
                        onTap: _openFilters,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MawjoodActionButton(
                        icon: Icons.sort_rounded,
                        label: 'ترتيب',
                        onTap: _openFilters,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
                if (_filters.hasActiveFilters) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_filters.activeCount} عناصر مفعلة',
                      style: theme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'استكشف خيارات ${widget.category.displayName}',
                  textAlign: TextAlign.right,
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                if (_errorMessage != null)
                  _ErrorBanner(
                    message: _errorMessage!,
                    onRetry: _loadBusinesses,
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? _buildLoadingState()
                        : _visibleBusinesses.isEmpty
                            ? const _EmptyState()
                            : ListView.separated(
                                itemCount: _visibleBusinesses.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final business = _visibleBusinesses[index];
                                  return BusinessCard(
                                    business: business,
                                    categoryLabel: widget.category.displayName,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BusinessDetailScreen(
                                            businessId: business.id,
                                            initialBusiness: business,
                                          ),
                                        ),
                                      );
                                    },
                                    onCall: business.phone.isEmpty
                                        ? null
                                        : () => _launchCall(business.phone),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _ShimmerCard(animation: _shimmerController),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _ShimmerBox(animation: animation, height: 86, width: 86, radius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(animation: animation, height: 16, width: 140),
                  const SizedBox(height: 10),
                  _ShimmerBox(animation: animation, height: 14, width: 100),
                  const SizedBox(height: 10),
                  _ShimmerBox(animation: animation, height: 12, width: double.infinity),
                  const SizedBox(height: 6),
                  _ShimmerBox(animation: animation, height: 12, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.animation,
    required this.height,
    required this.width,
    this.radius = 12,
  });

  final Animation<double> animation;
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final shimmerPosition = (animation.value * 2) - 1;
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1, 0),
              end: Alignment(1, 0),
              colors: const [
                Color(0xFFEDEDED),
                Color(0xFFF7F7F7),
                Color(0xFFEDEDED),
              ],
              stops: [
                (shimmerPosition - 0.3).clamp(0.0, 1.0),
                shimmerPosition.clamp(0.0, 1.0),
                (shimmerPosition + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.neutral,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج حالياً في هذا القسم',
              textAlign: TextAlign.center,
              style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب البحث باسم النشاط أو تواصل مع دعم موجود للمساعدة.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
