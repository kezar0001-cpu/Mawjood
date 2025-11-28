import 'package:flutter/material.dart';

import '../models/filters.dart';
import '../utils/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  final BusinessFilters currentFilters;
  final ValueChanged<BusinessFilters> onApply;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late BusinessFilters _tempFilters;

  final Map<String, String> _sortOptions = const {
    'nearest': 'الأقرب',
    'rating': 'الأعلى تقييماً',
    'popular': 'الأكثر شعبية',
    'price': 'السعر الأقل',
  };

  final Map<int?, String> _ratingOptions = const {
    4: '4+ نجوم',
    3: '3+ نجوم',
    null: 'أي تقييم',
  };

  final Map<String, String> _tagOptions = const {
    'توصيل': 'توصيل',
    'عائلي': 'مناسب للعائلة',
    'مفتوح الآن': 'مفتوح الآن',
    'حلال': 'حلال',
    'خصومات': 'خصومات',
  };

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.currentFilters;
  }

  void _resetFilters() {
    setState(() {
      _tempFilters = BusinessFilters.defaults();
    });
  }

  void _apply() {
    widget.onApply(_tempFilters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'التصفية والترتيب',
                      textAlign: TextAlign.right,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اختر ما يناسبك للعثور على نتائج أدق',
                      textAlign: TextAlign.right,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('الترتيب حسب', textTheme),
                    const SizedBox(height: 8),
                    ..._sortOptions.entries.map(
                      (entry) => RadioListTile<String>(
                        value: entry.key,
                        groupValue: _tempFilters.sortBy,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _tempFilters = _tempFilters.copyWith(sortBy: value);
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: AppColors.primary,
                        title: Text(
                          entry.value,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: entry.key == 'nearest'
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSectionTitle('التقييم', textTheme),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _ratingOptions.entries.map((entry) {
                        final isSelected = _tempFilters.minRating == entry.key;
                        return ChoiceChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withOpacity(0.12),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            color: isSelected ? AppColors.primary : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _tempFilters = _tempFilters.copyWith(minRating: entry.key);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    _buildSectionTitle('المزايا', textTheme),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _tagOptions.entries.map((entry) {
                        final isSelected = _tempFilters.tags.contains(entry.key);
                        return FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withOpacity(0.14),
                          backgroundColor: Colors.grey.shade200,
                          checkmarkColor: AppColors.primary,
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            color: isSelected ? AppColors.primary : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              final updatedTags = List<String>.from(_tempFilters.tags);
                              if (selected) {
                                updatedTags.add(entry.key);
                              } else {
                                updatedTags.remove(entry.key);
                              }
                              _tempFilters = _tempFilters.copyWith(tags: updatedTags);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE9E9E9))),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'مسح التصفيات',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _apply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'تطبيق',
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
      ),
    );
  }
}
