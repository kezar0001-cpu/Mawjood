import 'dart:async';

import 'package:flutter/material.dart';

import '../models/business.dart';
import '../models/filters.dart';
import '../repositories/business_repository.dart';
import '../services/filter_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text.dart';
import '../widgets/business_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/mawjood_action_button.dart';
import 'business_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, required this.initialQuery});

  final String initialQuery;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _controller;
  Timer? _debounce;
  final BusinessRepository _repository = BusinessRepository();
  List<Business> _results = [];
  List<Business> _filteredResults = [];
  String _currentQuery = '';
  BusinessFilters _filters = BusinessFilters.defaults();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _currentQuery = widget.initialQuery;
    _runSearch(widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
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
      setState(() {
        _results = results;
        _filteredResults = applyFilters(_results, _filters);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل نتائج البحث حالياً';
      });
    }
  }

  void _onSubmit(String value) {
    _debounce?.cancel();
    _runSearch(value);
  }

  void _openFilters() async {
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
      setState(() {
        _filters = result;
        _filteredResults = applyFilters(_results, _filters);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trimmedQuery = _currentQuery.trim();
    final hasQuery = trimmedQuery.isNotEmpty;
    final hasResults = _filteredResults.isNotEmpty;

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
                Text(
                  hasQuery
                      ? '${AppText.searchResultsFor}: $trimmedQuery'
                      : AppText.searchDetailedHint,
                  textAlign: TextAlign.right,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
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
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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
    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 24),
      itemCount: _filteredResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final business = _filteredResults[index];
        return BusinessCard(
          business: business,
          categoryLabel: business.city,
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
        );
      },
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
