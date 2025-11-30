import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/business.dart';
import '../models/filters.dart';
import '../providers/filters_provider.dart';
import '../providers/location_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../repositories/business_repository.dart';
import '../services/analytics_service.dart';
import '../services/filter_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text.dart';
import '../widgets/business_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'business_detail_screen.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, required this.initialQuery});

  final String initialQuery;

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late TextEditingController _controller;
  Timer? _debounce;
  final BusinessRepository _repository = BusinessRepository();
  final AnalyticsService _analytics = AnalyticsService();

  List<Business> _results = [];
  List<Business> _filteredResults = [];
  String _currentQuery = '';
  bool _isLoading = false;
  bool _isDebouncing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _currentQuery = widget.initialQuery;
    _analytics.logScreenView('search_results_screen');
    _runSearch(widget.initialQuery);
  }

  @override
  void dispose() {
    // CRITICAL: Cancel timer before disposal to prevent memory leaks
    _debounce?.cancel();
    _debounce = null;
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    // CRITICAL: Cancel existing timer before creating new one
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Show debouncing indicator
    setState(() {
      _isDebouncing = true;
      _currentQuery = value;
    });

    // Increased to 500ms for better Arabic typing experience
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isDebouncing = false;
      });
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String value) async {
    final trimmed = value.trim();
    setState(() {
      _currentQuery = value;
      _errorMessage = null;
    });

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _filteredResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _repository.searchBusinesses(trimmed);

      // Get user location and filters from providers
      final userLocationAsync = ref.read(userLocationProvider);
      final filters = ref.read(filtersProvider);
      Position? userLocation;

      userLocationAsync.whenData((location) {
        userLocation = location;
      });

      // Log search event
      _analytics.logSearch(trimmed, resultCount: results.length);

      // Add to recent searches
      ref.read(recentSearchesProvider.notifier).addSearch(trimmed);

      setState(() {
        _results = results;
        _filteredResults = applyFilters(_results, filters, userLocation: userLocation);
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      _analytics.logError(error, stackTrace, reason: 'Search failed');
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل نتائج البحث حالياً';
      });
    }
  }

  void _onSubmit(String value) {
    // CRITICAL: Cancel debounce timer on submit
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    setState(() {
      _isDebouncing = false;
    });
    _runSearch(value);
  }

  Future<void> _handleRefresh() async {
    await _runSearch(_currentQuery);
  }

  void _openFilters() async {
    final currentFilters = ref.read(filtersProvider);

    final result = await showModalBottomSheet<BusinessFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterBottomSheet(
        currentFilters: currentFilters,
        onApply: (updatedFilters) {
          Navigator.of(context).pop(updatedFilters);
        },
      ),
    );

    if (result != null) {
      // Update filters in provider
      ref.read(filtersProvider.notifier).applyFilters(result);

      // Log filter application
      _analytics.logFilterApplied(
        sortBy: result.sortBy,
        minRating: result.minRating,
        tags: result.tags,
      );

      // Re-apply filters to results
      final userLocationAsync = ref.read(userLocationProvider);
      Position? userLocation;
      userLocationAsync.whenData((location) {
        userLocation = location;
      });

      setState(() {
        _filteredResults = applyFilters(_results, result, userLocation: userLocation);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trimmedQuery = _currentQuery.trim();
    final hasQuery = trimmedQuery.isNotEmpty;
    final hasResults = _filteredResults.isNotEmpty;
    final filters = ref.watch(filtersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 88,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'عودة',
          ),
          titleSpacing: 0,
          title: _buildSearchField(),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppText.searchResultsLabel,
                  textAlign: TextAlign.right,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasQuery
                            ? '${AppText.searchResultsFor}: $trimmedQuery'
                            : AppText.searchDetailedHint,
                        textAlign: TextAlign.right,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    // Debouncing indicator
                    if (_isDebouncing) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (hasQuery)
                  Text(
                    '${AppText.searchResultsCount} ${_filteredResults.length}',
                    textAlign: TextAlign.right,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _openFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: filters.hasActiveFilters
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'فلترة وترتيب',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (filters.hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filters.activeCount}',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        _ErrorBanner(
                          message: _errorMessage!,
                          onRetry: () => _runSearch(_currentQuery),
                        ),
                      Expanded(
                        child: hasQuery
                            ? _isLoading
                                ? const _SearchShimmerList()
                                : hasResults
                                    ? _buildResultsList()
                                    : _buildEmptyState(textTheme)
                            : _buildIdleState(textTheme),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        onChanged: _onQueryChanged,
        onSubmitted: _onSubmit,
        decoration: InputDecoration(
          hintText: AppText.searchDetailedHint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 24),
        itemCount: _filteredResults.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final business = _filteredResults[index];
          return BusinessCard(
            business: business,
            categoryLabel: business.city,
            onTap: () {
              _analytics.logBusinessView(business.id, business.name);
              _analytics.logNavigation('search_results_screen', 'business_detail_screen');
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppText.searchNoResults,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              AppText.searchSuggestion,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'ابدأ الكتابة للعثور على نشاطك المفضل',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'استخدم كلمات واضحة مثل اسم المحل، الفئة، أو المنطقة.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchShimmerList extends StatelessWidget {
  const _SearchShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
