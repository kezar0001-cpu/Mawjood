import 'package:flutter/material.dart';

import '../models/business.dart';
import '../repositories/business_repository.dart';
import '../widgets/business_card.dart';
import 'business_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const String routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BusinessRepository _repository = BusinessRepository();
  List<Business> _results = [];
  bool _loading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final query = args != null ? (args['query'] as String? ?? '') : '';
      if (query.isNotEmpty) {
        _searchController.text = query;
        _search(query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _lastQuery = '';
        _loading = false;
      });
      return;
    }
    if (query == _lastQuery) return;
    setState(() {
      _loading = true;
      _lastQuery = query;
    });
    try {
      final results = await _repository.searchBusinesses(query);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              onChanged: (value) => _search(value),
              decoration: const InputDecoration(
                hintText: 'أدخل كلمة البحث...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: _results.isEmpty && !_loading
                  ? const Center(child: Text('لا توجد نتائج حتى الآن'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final business = _results[index];
                        return BusinessCard(
                          business: business,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              BusinessDetailScreen.routeName,
                              arguments: {'business': business},
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
