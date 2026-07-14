import '../models/post_model.dart';
import '../services/auth_service.dart';

class PostService {
  Future<List<PostModel>> fetchPosts() async {
    try {
      final records = await AuthService.pb
          .collection('posts')
          .getFullList(sort: '-created');

      return records.map((record) => PostModel(record)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت آگهی‌ها: $e');
    }
  }
}
