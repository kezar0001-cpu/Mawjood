import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawjood/models/category.dart';
import 'package:mawjood/providers/business_provider.dart';
import 'package:mawjood/widgets/business_card.dart';
import 'package:mawjood/screens/business_detail_screen.dart';

class BusinessListScreen extends ConsumerWidget {
  final Category category;

  const BusinessListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesByCategoryProvider(category.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(category.displayName), // Use displayName
      ),
      body: businessesAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أعمال في فئة "${category.displayName}"', // Use displayName
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return BusinessCard(
                business: business,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BusinessDetailScreen(businessId: business.id, initialBusiness: business),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('خطأ في تحميل الأعمال: $err'), // Error loading businesses
        ),
      ),
    );
  }
}