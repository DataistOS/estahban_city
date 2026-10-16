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

  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Vazir',
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (_myPosts.isEmpty)
        ? 1
        : (_myPosts.length / _itemsPerPage).ceil();

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < _myPosts.length)
        ? startIndex + _itemsPerPage
        : _myPosts.length;

    final paginatedPosts = _myPosts.isEmpty
        ? <PostModel>[]
        : _myPosts.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFDDE3F1),
      appBar: AppBar(
        title: const Text(
          "آگهی‌های من",
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myPosts.isEmpty
          ? const Center(
              child: Text(
                "شما هنوز آگهی ثبت نکرده‌اید",
                style: TextStyle(fontFamily: 'Vazir', fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: paginatedPosts.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final post = paginatedPosts[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1A365D,
                                ).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.article_outlined,
                                color: Color(0xFF1A365D),
                                size: 26,
                              ),
                            ),
                            title: Text(
                              post.title,
                              style: const TextStyle(
                                fontFamily: 'Vazir',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [_buildStatusBadge(post.status)],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (totalPages > 1)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white.withValues(alpha: 0.8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                          icon: const Icon(Icons.arrow_back_ios, size: 14),
                          label: const Text(
                            'قبلی',
                            style: TextStyle(fontFamily: 'Vazir'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF333333),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'صفحه $_currentPage از $totalPages',
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _currentPage < totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                          label: const Text(
                            'بعدی',
                            style: TextStyle(fontFamily: 'Vazir'),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF333333),
                            foregroundColor: Colors.white,
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
