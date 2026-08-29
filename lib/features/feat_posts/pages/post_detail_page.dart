// lib/features/feat_posts/pages/post_detail_page.dart

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../../feat_auth/services/auth_service.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl = AuthService.pb.files
        .getUrl(post.toRecord(), post.image)
        .toString();

    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
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
                  "${post.price.toInt()} تومان",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
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
}
