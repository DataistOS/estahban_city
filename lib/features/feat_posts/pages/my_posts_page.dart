// lib/features/feat_posts/pages/my_posts_page.dart

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final PostService _postService = PostService();
  List<PostModel> _myPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    try {
      final posts = await _postService.fetchMyPosts();
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطا: $e")));
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    String text;
    Color color;

    switch (status) {
      case 'approved':
        text = 'تایید شده';
        color = Colors.green;
        break;
      case 'rejected':
        text = 'رد شده';
        color = Colors.red;
        break;
      case 'pending':
      default:
        text = 'در انتظار تایید';
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("آگهی‌های من")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myPosts.isEmpty
          ? const Center(child: Text("شما هنوز آگهی ثبت نکرده‌اید"))
          : ListView.builder(
              itemCount: _myPosts.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final post = _myPosts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      post.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("قیمت: ${post.price} تومان"),
                        const SizedBox(height: 8),
                        _buildStatusBadge(post.status),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
