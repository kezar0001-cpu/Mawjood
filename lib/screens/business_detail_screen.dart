import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business.dart';
import '../repositories/business_repository.dart';
import '../utils/app_colors.dart';
import '../widgets/business_card.dart';
import '../widgets/mawjood_action_button.dart';

class BusinessDetailScreen extends StatefulWidget {
  const BusinessDetailScreen({
    super.key,
    required this.businessId,
    this.initialBusiness,
  });

  static const String routeName = '/business-detail';

  final String businessId;
  final Business? initialBusiness;

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final BusinessRepository _repository = BusinessRepository();
  Business? _business;
  late Future<List<Business>> _relatedFuture;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _business = widget.initialBusiness;
    _relatedFuture = Future.value([]);
    _loadBusiness();
  }

  Future<void> _loadBusiness() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fetched = await _repository.fetchById(widget.businessId);
    final resolved = fetched ?? _business;

    if (resolved == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'لا توجد بيانات حاليا';
      });
      return;
    }

    setState(() {
      _business = resolved;
      _relatedFuture = _loadRelatedBusinesses(resolved.categoryId ?? '');
      _isLoading = false;
    });
  }

  Future<List<Business>> _loadRelatedBusinesses(String categoryId) async {
    final results = await _repository.fetchByCategory(categoryId);
    return results.where((b) => b.id != widget.businessId).toList();
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الرابط حالياً')),
      );
    }
  }

  void _callBusiness() {
    final phone = _business?.phone ?? '';
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الاتصال غير متوفر')),
      );
      return;
    }
    _launch(Uri.parse('tel:$phone'));
  }

  Future<void> _shareBusiness() async {
    final business = _business;
    if (business == null) return;

    final shareText = [
      business.name,
      if ((business.description ?? '').isNotEmpty) business.description ?? '',
      if ((business.displayAddress ?? '').isNotEmpty) business.displayAddress ?? '',
      if ((business.phone ?? '').isNotEmpty) business.phone ?? '',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ تفاصيل النشاط للمشاركة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = _business;
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : business == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _errorMessage ?? 'لا توجد بيانات حاليا',
                          style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HeroHeader(
                                imageUrl: business.primaryImage,
                                onBack: () => Navigator.pop(context),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      business.name,
                                      textAlign: TextAlign.right,
                                      style: theme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            (business.city ?? '').isNotEmpty ? (business.city ?? '') : 'غير محدد',
                                            style: theme.labelLarge?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 22),
                                        const SizedBox(width: 4),
                                        Text(
                                          (business.rating ?? 0.0).toStringAsFixed(1),
                                          style: theme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      business.description ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: theme.bodyLarge?.copyWith(color: Colors.black87),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MawjoodActionButton(
                                            icon: Icons.call_rounded,
                                            label: 'اتصال',
                                            onTap: _callBusiness,
                                            backgroundColor: AppColors.primary.withOpacity(0.12),
                                            foregroundColor: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: MawjoodActionButton(
                                            icon: Icons.chat_rounded,
                                            label: 'واتساب',
                                            onTap: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('واتساب غير متوفر حالياً')),
                                              );
                                            },
                                            backgroundColor: AppColors.primaryLight.withOpacity(0.16),
                                            foregroundColor: AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: MawjoodActionButton(
                                            icon: Icons.share_rounded,
                                            label: 'مشاركة',
                                            onTap: _shareBusiness,
                                            backgroundColor: AppColors.accentGold.withOpacity(0.2),
                                            foregroundColor: AppColors.darkText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 28, thickness: 1, color: Color(0xFFECE9DF)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionTitle(title: 'نبذة عن المحل'),
                                    const SizedBox(height: 8),
                                    Text(
                                      business.description ?? '',
                                      textAlign: TextAlign.right,
                                      style: theme.bodyMedium?.copyWith(color: Colors.black87),
                                    ),
                                    const SizedBox(height: 20),
                                    _SectionTitle(title: 'الموقع'),
                                    const SizedBox(height: 10),
                                    _MapPreview(
                                      address: business.displayAddress,
                                      onTap: null,
                                    ),
                                    if (business.displayAddress.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        business.displayAddress,
                                        textAlign: TextAlign.right,
                                        style: theme.bodyMedium?.copyWith(
                                          color: AppColors.darkText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    if (business.features.isNotEmpty) ...[
                                      _SectionTitle(title: 'مميزات'),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: business.features
                                            .map(
                                              (tag) => Chip(
                                                backgroundColor: AppColors.neutral,
                                                labelStyle: theme.labelLarge?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.darkText,
                                                ),
                                                label: Text(tag),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              FutureBuilder<List<Business>>(
                                future: _relatedFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const _RelatedShimmer();
                                  }
                                  final related = snapshot.data ?? [];
                                  if (related.isEmpty) return const SizedBox.shrink();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 28),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: _SectionTitle(title: 'اقتراحات مشابهة'),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 190,
                                        child: ListView.separated(
                                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: related.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                                          itemBuilder: (context, index) {
                                            final item = related[index];
                                            return SizedBox(
                                              width: 280,
                                              child: BusinessCard(
                                                business: item,
                                                categoryLabel: item.city,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => BusinessDetailScreen(
                                                        businessId: item.id,
                                                        initialBusiness: item,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                onCall: (item.phone ?? '').isNotEmpty
                                                    ? () => _launch(Uri.parse('tel:${item.phone ?? ''}'))
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
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

class _RelatedShimmer extends StatelessWidget {
  const _RelatedShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 14,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 3,
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.imageUrl,
    required this.onBack,
  });

  final String? imageUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.neutral,
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.store_mall_directory_outlined,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black38, Colors.black54],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 12,
              start: 12,
              child: Material(
                color: Colors.white.withOpacity(0.14),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.address, required this.onTap});

  final String address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.neutral,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place_rounded, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              address.isNotEmpty ? address : 'العنوان غير متوفر',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
