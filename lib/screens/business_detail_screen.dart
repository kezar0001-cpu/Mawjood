// FIXED: Removed dart:io import for Web compatibility - use kIsWeb instead
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business.dart';
import '../models/business_claim.dart';
import '../repositories/business_repository.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../widgets/business_card.dart';
import '../widgets/mawjood_action_button.dart';
import 'reviews_screen.dart';

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

  void _openWhatsApp() {
    final business = _business;
    if (business == null) return;

    final whatsappNumber = business.whatsapp ?? '';
    if (whatsappNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم واتساب غير متوفر')),
      );
      return;
    }

    // Remove any spaces, dashes, or special characters from the number
    final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Pre-filled message in Arabic
    final message = Uri.encodeComponent('مرحباً، أود الاستفسار عن ${business.name}');

    // Use wa.me URL scheme
    final whatsappUrl = Uri.parse('https://wa.me/$cleanNumber?text=$message');

    _launch(whatsappUrl);
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

  void _openReviews() {
    final business = _business;
    if (business == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewsScreen(business: business),
      ),
    ).then((_) => _loadBusiness()); // Refresh business data when returning
  }

  Future<void> _claimBusiness() async {
    final business = _business;
    if (business == null) return;

    // Check if user already has a claim
    final existingClaim = await SupabaseService.getBusinessClaimForUser(business.id);

    if (existingClaim != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لديك طلب مطالبة سابق بحالة: ${existingClaim.status.displayName}'),
        ),
      );
      return;
    }

    // Show claim dialog
    if (!mounted) return;
    _showClaimDialog();
  }

  void _showClaimDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('المطالبة بملكية المحل'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سيتم مراجعة طلبك من قبل الإدارة. يرجى تقديم معلومات صحيحة.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      if (!value.contains('@')) {
                        return 'البريد الإلكتروني غير صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final isValid = formKey.currentState?.validate() ?? false;
                if (isValid) {
                  final currentBusiness = _business;
                  if (currentBusiness == null) {
                    Navigator.pop(context);
                    return;
                  }

                  Navigator.pop(context);
                  final claim = await SupabaseService.submitBusinessClaim(
                    businessId: currentBusiness.id,
                    userName: nameController.text.trim(),
                    userEmail: emailController.text.trim(),
                    userPhone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  );

                  if (!mounted) return;
                  if (claim != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تقديم طلب المطالبة بنجاح. سيتم مراجعته قريباً.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('فشل في تقديم الطلب. الرجاء المحاولة مرة أخرى.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }

  void _openMaps() {
    final business = _business;
    if (business == null) return;

    final lat = business.latitude;
    final lng = business.longitude;

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الموقع الجغرافي غير متوفر')),
      );
      return;
    }

    // FIXED: Use Web-compatible URL scheme
    // For Web and all platforms, use Google Maps HTTPS URL which works universally
    final Uri mapsUrl;
    if (kIsWeb) {
      // Web: Use Google Maps web URL
      mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      // Mobile: Use universal https scheme that works on both iOS and Android
      mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    }

    _launch(mapsUrl);
  }

  @override
  Widget build(BuildContext context) {
    final business = _business;
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(business?.name ?? 'تفاصيل النشاط'),
          centerTitle: true,
          elevation: 0,
        ),
        body: _isLoading
            ? const _DetailShimmerLayout()
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
                              _HeroHeader(imageUrl: business.primaryImage),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            business.name,
                                            textAlign: TextAlign.right,
                                            style: theme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                        ),
                                        if (business.verified) ...[
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.verified,
                                            size: 24,
                                            color: Colors.blue,
                                          ),
                                        ],
                                      ],
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
                                        if (business.reviewCount > 0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${business.reviewCount} تقييم)',
                                            style: theme.bodyMedium?.copyWith(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
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
                                            onTap: _openWhatsApp,
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
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MawjoodActionButton(
                                            icon: Icons.rate_review,
                                            label: 'التقييمات',
                                            onTap: _openReviews,
                                            backgroundColor: Colors.purple.withOpacity(0.1),
                                            foregroundColor: Colors.purple,
                                          ),
                                        ),
                                        if (!business.verified) ...[
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: MawjoodActionButton(
                                              icon: Icons.verified_user,
                                              label: 'مطالبة',
                                              onTap: _claimBusiness,
                                              backgroundColor: Colors.orange.withOpacity(0.1),
                                              foregroundColor: Colors.orange,
                                            ),
                                          ),
                                        ],
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
                                      latitude: business.latitude,
                                      longitude: business.longitude,
                                      businessName: business.name,
                                      onTap: _openMaps,
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
  const _HeroHeader({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
  const _MapPreview({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.businessName,
    required this.onTap,
  });

  final String address;
  final double? latitude;
  final double? longitude;
  final String businessName;
  final VoidCallback? onTap;

  // You can add your Google Static Maps API key here
  String? get _staticMapUrl {
    if (latitude == null || longitude == null) return null;

    // Google Static Maps API URL
    // Note: Replace YOUR_API_KEY with actual Google Static Maps API key
    // For now, we'll return null to show the placeholder
    // const apiKey = 'YOUR_API_KEY';
    // return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=15&size=400x200&markers=color:red%7C$latitude,$longitude&key=$apiKey';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final staticMapUrl = _staticMapUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.neutral,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E6E6)),
          image: staticMapUrl != null
              ? DecorationImage(
                  image: NetworkImage(staticMapUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: staticMapUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.place_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    address.isNotEmpty ? address : 'العنوان غير متوفر',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                  ),
                  if (latitude != null && longitude != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'افتح في الخريطة',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              )
            : null,
      ),
    );
  }
}

class _DetailShimmerLayout extends StatelessWidget {
  const _DetailShimmerLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero image shimmer
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business name shimmer
                Container(
                  height: 24,
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                // City and rating shimmer
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 20,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Description shimmer
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 16,
                  width: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                // Action buttons shimmer
                Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        height: 48,
                        margin: EdgeInsets.only(
                          left: index < 2 ? 10 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
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
                // Section title shimmer
                Container(
                  height: 18,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                // Content lines shimmer
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      height: 14,
                      width: index == 2 ? 180 : double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Map preview shimmer
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
