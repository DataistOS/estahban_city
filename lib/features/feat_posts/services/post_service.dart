// lib/features/feat_posts/services/post_service.dart

import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import '../../feat_auth/services/auth_service.dart';

class PostService {
  Future<List<PostModel>> fetchPosts({
    int page = 1,
    int perPage = 100,
    String? categoryId,
  }) async {
    try {
      String filter = 'is_deleted = false && status = "approved"';

      if (categoryId != null && categoryId.isNotEmpty) {
        filter += ' && category = "$categoryId"';
      }

      final resultList = await AuthService.pb
          .collection('posts')
          .getList(
            page: page,
            perPage: perPage,
            sort: '-created',
            filter: filter,
          );

      return resultList.items.map((record) => PostModel(record)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت آگهی‌ها: $e');
    }
  }

  Future<List<PostModel>> fetchMyPosts() async {
    try {
      final userId = AuthService.pb.authStore.record?.id;
      if (userId == null) return [];

      String filter = 'user = "$userId" && is_deleted = false';

      final resultList = await AuthService.pb
          .collection('posts')
          .getList(page: 1, perPage: 100, sort: '-created', filter: filter);

      return resultList.items.map((record) => PostModel(record)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت آگهی‌های شما: $e');
    }
  }

  Future<void> createPost({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    http.MultipartFile? imageFile,
  }) async {
    try {
      final userId = AuthService.pb.authStore.record?.id;

      final body = <String, dynamic>{
        'title': title,
        'description': description,
        'price': price,
        'category': categoryId,
        'user': userId,
        'is_deleted': false,
        'status': 'pending',
      };

      final files = <http.MultipartFile>[];
      if (imageFile != null) {
        files.add(imageFile);
      }

      await AuthService.pb.collection('posts').create(body: body, files: files);
    } catch (e) {
      throw Exception('خطا در ثبت آگهی: $e');
    }
  }

  Future<void> softDeletePost(String postId) async {
    try {
      await AuthService.pb
          .collection('posts')
          .update(postId, body: {'is_deleted': true});
    } catch (e) {
      throw Exception('خطا در حذف آگهی: $e');
    }
  }
}
