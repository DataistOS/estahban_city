// lib/features/feat_posts/pages/home_page.dart

import 'create_post_page.dart';
import 'post_detail_page.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../../feat_auth/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _postService = PostService();
  final List<PostModel> _posts = [];

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMorePosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMorePosts();
      }
    });
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newPosts = await _postService.fetchPosts(
        page: _currentPage,
        perPage: 20,
      );

      setState(() {
        _currentPage++;
        _isLoading = false;
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(newPosts);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطا در بارگذاری اطلاعات: $e")));
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _currentPage = 1;
      _posts.clear();
      _hasMore = true;
    });
    await _loadMorePosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("دیوار استهبان"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.pb.authStore.clear();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _posts.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
            ? const Center(child: Text("آگهی‌ای یافت نشد"))
            : ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _posts.length) {
                    return _PostItem(post: _posts[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
          _refreshPosts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PostItem extends StatelessWidget {
  final PostModel post;

  const _PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final url = AuthService.pb.files
        .getUrl(post.toRecord(), post.image)
        .toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image),
          ),
        ),
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${post.price.toInt()} تومان"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        ),
      ),
    );
  }
}
