import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business.dart';
import '../repositories/business_repository.dart';
import '../utils/app_colors.dart';
import '../widgets/business_card.dart';
import '../widgets/mawjood_action_button.dart';

class BusinessDetailScreen extends StatefulWidget {
  const BusinessDetailScreen({super.key, required this.business});

  static const String routeName = '/business-detail';

  final Business business;

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final BusinessRepository _repository = BusinessRepository();
  bool _isFavorite = false;
  late Future<List<Business>> _relatedFuture;

  @override
  void initState() {
    super.initState();
    _relatedFuture = _loadRelatedBusinesses();
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
    final phone = widget.business.phone;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الاتصال غير متوفر')),
      );
      return;
    }
    _launch(Uri.parse('tel:$phone'));
  }

  void _openWhatsapp() {
    final whatsapp = widget.business.whatsapp;
    if (whatsapp == null || whatsapp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('واتساب غير متوفر لهذا النشاط')), 
      );
      return;
    }
    final sanitized = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    _launch(Uri.parse('https://wa.me/$sanitized'));
  }

  Future<void> _shareBusiness() async {
    final business = widget.business;
    final shareText = [
      business.name,
      if (business.description.isNotEmpty) business.description,
      if (business.displayAddress.isNotEmpty) business.displayAddress,
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ تفاصيل النشاط للمشاركة')),
    );
  }

  Future<List<Business>> _loadRelatedBusinesses() async {
    try {
      final results =
          await _repository.getBusinessesByCategory(widget.business.categoryId);
      return results
          .where((b) => b.id != widget.business.id)
          .map(
            (b) => b.copyWith(
              categoryName: widget.business.categoryName.isNotEmpty
                  ? widget.business.categoryName
                  : b.categoryName,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final theme = Theme.of(context).textTheme;
    final heroImage = business.primaryImage;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroHeader(
                      imageUrl: heroImage,
                      onBack: () => Navigator.pop(context),
                      isFavorite: _isFavorite,
                      onToggleFavorite: () => setState(() => _isFavorite = !_isFavorite),
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
                                  business.categoryName,
                                  style: theme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.star_rounded, color: AppColors.accentGold, size: 22),
                              const SizedBox(width: 4),
                              Text(
                                business.rating.toStringAsFixed(1),
                                style: theme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              if (business.ratingCount > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '(${business.ratingCount})',
                                  style: theme.bodyMedium?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            business.description,
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
                                  onTap: _openWhatsapp,
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
                            business.description,
                            textAlign: TextAlign.right,
                            style: theme.bodyMedium?.copyWith(color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          _SectionTitle(title: 'الموقع'),
                          const SizedBox(height: 10),
                          _MapPreview(
                            address: business.displayAddress,
                            onTap: business.mapsUrl?.isNotEmpty == true
                                ? () => _launch(Uri.parse(business.mapsUrl!))
                                : null,
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
                          if (business.openingHours != null && business.openingHours!.isNotEmpty) ...[
                            _SectionTitle(title: 'ساعات العمل'),
                            const SizedBox(height: 10),
                            ...business.openingHours!.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.value,
                                      style: theme.bodyMedium?.copyWith(color: Colors.black87),
                                    ),
                                    Text(
                                      entry.key,
                                      style: theme.bodyMedium?.copyWith(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BusinessDetailScreen(business: item),
                                          ),
                                        );
                                      },
                                      onCall: item.phone.isNotEmpty
                                          ? () => _launch(Uri.parse('tel:${item.phone}'))
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
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final String? imageUrl;
  final VoidCallback onBack;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

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
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
            ),
            PositionedDirectional(
              top: 12,
              end: 12,
              child: _CircleButton(
                icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                onTap: onToggleFavorite,
                color: isFavorite ? Colors.redAccent : Colors.white,
                iconColor: isFavorite ? Colors.white : AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.darkText,
          ),
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.address,
    this.onTap,
  });

  final String address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.neutral,
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?auto=format&fit=crop&w=800&q=60',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 12,
            start: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موقع المحل',
                  style: theme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.isNotEmpty ? address : 'سيتم توفير العنوان قريباً',
                  style: theme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            bottom: 12,
            end: 12,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.map_rounded),
              label: const Text('عرض على الخارطة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkText,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Text(
      title,
      textAlign: TextAlign.right,
      style: theme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
      ),
    );
  }
}
