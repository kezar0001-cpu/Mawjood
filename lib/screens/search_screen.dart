import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawjood/providers/recent_searches_provider.dart';
import 'package:mawjood/widgets/mawjood_search_bar.dart';
import 'package:mawjood/screens/search_results_screen.dart'; // We will create this next

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).addSearch(query.trim());
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: query.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث'), // Search
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MawjoodSearchBar(
              controller: _searchController,
              onSubmit: _performSearch, // Changed from onSubmitted to onSubmit
            ),
          ),
          if (recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'عمليات البحث الأخيرة', // Recent Searches
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(recentSearchesProvider.notifier).clearAll();
                    },
                    child: const Text('مسح الكل'), // Clear All
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: recentSearches.length,
              itemBuilder: (context, index) {
                final search = recentSearches[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(search),
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(recentSearchesProvider.notifier).removeSearch(search);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
