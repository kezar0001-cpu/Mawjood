import 'dart:async';

import 'package:flutter/material.dart';

import '../models/business.dart';
import '../models/filters.dart';
import '../services/filter_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text.dart';
import '../utils/search_helper.dart';
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
  List<Business> _results = [];
  List<Business> _filteredResults = [];
  String _currentQuery = '';
  BusinessFilters _filters = BusinessFilters.defaults();

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

  void _runSearch(String value) {
    final trimmed = value.trim();
    setState(() {
      _currentQuery = value;
      _results = searchBusinessesLocally(trimmed);
      _filteredResults = applyFilters(_results, _filters);
    });
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
                  child: hasQuery
                      ? hasResults
                          ? _buildResultsList()
                          : _buildEmptyState(textTheme)
                      : _buildIdleState(textTheme),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BusinessDetailScreen(business: business),
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
