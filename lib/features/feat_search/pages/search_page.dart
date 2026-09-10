// lib/features/feat_search/pages/search_page.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../../feat_posts/models/post_model.dart';
import '../../feat_posts/services/post_service.dart';
import '../../feat_posts/pages/post_detail_page.dart';
import '../services/search_history_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final PostService _postService = PostService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final TextEditingController _searchController = TextEditingController();

  List<PostModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  String _lastSavedQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    _performSearch(query);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        if (query != _lastSavedQuery) {
          _searchHistoryService.saveSearchQuery(query);
          _lastSavedQuery = query;
        }
      });
    } else {
      _lastSavedQuery = '';
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _postService.fetchPosts(onlyPaidTiers: true);
      final filtered = posts
          .where(
            (post) =>
                post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      setState(() {
        _searchResults = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطا در جستجو: $e")));
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("جستجوی آگهی‌ها")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "جستجو در عنوان یا توضیحات...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchController.text.trim().isEmpty
                  ? const Center(
                      child: Text("لطفاً عبارت مورد نظر را وارد کنید"),
                    )
                  : _searchResults.isEmpty
                  ? const Center(child: Text("نتیجه‌ای یافت نشد"))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final post = _searchResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(post.title),
                            subtitle: Text("قیمت: ${post.price} تومان"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailPage(post: post),
                                ),
                              );
                            },
                          ),
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
