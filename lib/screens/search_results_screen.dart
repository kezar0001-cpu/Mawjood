import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawjood/providers/business_provider.dart';
import 'package:mawjood/widgets/business_card.dart';
import 'package:mawjood/screens/business_detail_screen.dart';

class SearchResultsScreen extends ConsumerWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(searchResultsProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text('نتائج البحث لـ: "$query"'), // Search Results for: "$query"
      ),
      body: searchResultsAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return Center(
              child: Text(
                'لا توجد نتائج لـ: "$query"', // No results found for: "$query"
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
          child: Text('خطأ في تحميل نتائج البحث: $err'), // Error loading search results
        ),
      ),
    );
  }
}