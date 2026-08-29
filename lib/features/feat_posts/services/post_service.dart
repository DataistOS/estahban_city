// lib/features/feat_posts/services/post_service.dart

import '../models/post_model.dart';
import '../../feat_auth/services/auth_service.dart';

class PostService {
  Future<List<PostModel>> fetchPosts({int page = 1, int perPage = 100}) async {
    try {
      final resultList = await AuthService.pb
          .collection('posts')
          .getList(
            page: page,
            perPage: perPage,
            sort: '-created',
            filter: 'is_deleted = false',
          );

      return resultList.items.map((record) => PostModel(record)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت آگهی‌ها: $e');
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
