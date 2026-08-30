// lib/features/feat_posts/pages/category_posts_page.dart

import 'post_detail_page.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class CategoryPostsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryPostsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostsPage> createState() => _CategoryPostsPageState();
}

class _CategoryPostsPageState extends State<CategoryPostsPage> {
  final PostService _postService = PostService();
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostsByCategory();
  }

  Future<void> _loadPostsByCategory() async {
    try {
      final posts = await _postService.fetchPosts(
        categoryId: widget.categoryId,
      );
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطا در بارگذاری آگهی‌ها: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(child: Text("آگهی‌ای در این دسته‌بندی یافت نشد."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
    );
  }
}
