// lib/features/feat_posts/pages/post_detail_page.dart

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../../feat_auth/services/auth_service.dart';
import '../services/post_service.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;
  final PostService _postService = PostService();

  PostDetailPage({super.key, required this.post});

  String _formatPrice(dynamic price) {
    if (price == null || price == 0 || price == '0' || price == '') {
      return "تماس بگیرید";
    }

    final numPrice = num.tryParse(price.toString()) ?? 0;
    if (numPrice <= 0) {
      return "تماس بگیرید";
    }

    return "$numPrice تومان";
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = AuthService.pb.files
        .getUrl(post.toRecord(), post.image)
        .toString();

    final authModel = AuthService.pb.authStore.model;
    final currentUserId = authModel != null ? authModel.id : '';

    final postUserId = post.toRecord().getStringValue('user');
    final bool isOwner =
        currentUserId.isNotEmpty && postUserId == currentUserId;

    final formattedPrice = _formatPrice(post.price);
    final bool isContactUs = formattedPrice == "تماس بگیرید";

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmAndDelete(context),
            ),
        ],
      ),
      body: ListView(
        children: [
          _buildImage(imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formattedPrice,
                  style: TextStyle(
                    fontSize: 20,
                    color: isContactUs ? Colors.orange[800] : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 30),
                Text(
                  post.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      height: 300,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 300,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      ),
    );
  }

  void _confirmAndDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف آگهی"),
        content: const Text(
          "آیا مطمئن هستید که می‌خواهید این آگهی را حذف کنید؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("انصراف"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _postService.softDeletePost(post.id);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("خطا در حذف: $e")));
                }
              }
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
