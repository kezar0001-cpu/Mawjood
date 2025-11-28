import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../widgets/business_card.dart';
import 'business_detail_screen.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({
    super.key,
    required this.service,
    required this.categoryId,
    required this.categoryName,
  });

  static const String routeName = '/business-list';

  final SupabaseService service;
  final String categoryId;
  final String categoryName;

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  late Future<List<Business>> _businessesFuture;

  @override
  void initState() {
    super.initState();
    _businessesFuture = widget.service.getBusinessesByCategory(widget.categoryId);
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List<Business>>(
          future: _businessesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ في تحميل البيانات'));
            }
            final businesses = snapshot.data ?? [];
            if (businesses.isEmpty) {
              return const Center(child: Text('لا توجد أعمال في هذا التصنيف'));
            }
            return ListView.builder(
              itemCount: businesses.length,
              itemBuilder: (context, index) {
                final business = businesses[index];
                return BusinessCard(
                  business: business,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      BusinessDetailScreen.routeName,
                      arguments: {'business': business},
                    );
                  },
                  onCall: business.phone.isEmpty
                      ? null
                      : () => _launch('tel:${business.phone}'),
                  onWhatsApp: business.whatsapp.isEmpty
                      ? null
                      : () => _launch('https://wa.me/${business.whatsapp.replaceAll('+', '')}'),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: AppColors.primary,
        label: const Text('رجوع'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
