import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../mock/mock_businesses.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../utils/app_colors.dart';
import '../widgets/business_card.dart';
import '../widgets/mawjood_search_bar.dart';
import 'business_detail_screen.dart';

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
  List<Business> _allBusinesses = [];
  List<Business> _visibleBusinesses = [];
  bool _isLoading = true;

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
    final source = widget.businesses ??
        mockBusinesses.where((b) => b.categoryId == widget.category.id).toList();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _allBusinesses = source;
      _visibleBusinesses = source;
      _isLoading = false;
    });
  }

  void _handleSearch(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _visibleBusinesses = _allBusinesses);
      return;
    }
    setState(() {
      _visibleBusinesses = _allBusinesses.where((business) {
        return business.name.toLowerCase().contains(query) ||
            business.description.toLowerCase().contains(query) ||
            business.categoryName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('النتائج لـ ${widget.category.name}'),
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
                  onSubmit: _handleSearch,
                  onChanged: _handleSearch,
                  onFilterTap: () => _handleSearch(_searchController.text),
                  hintText: 'ابحث داخل ${widget.category.name}',
                ),
                const SizedBox(height: 12),
                Text(
                  'استكشف خيارات ${widget.category.name}',
                  textAlign: TextAlign.right,
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),
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
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BusinessDetailScreen(business: business),
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
