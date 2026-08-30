// lib/features/feat_posts/services/category_service.dart

import 'package:pocketbase/pocketbase.dart';
import '../../feat_auth/services/auth_service.dart';
import '../models/category_model.dart';

class CategoryService {
  final PocketBase _pb = AuthService.pb;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final records = await _pb
          .collection('posts_categories')
          .getFullList(sort: 'name');
      return records.map((record) => CategoryModel(record)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت دسته‌بندی‌ها: $e');
    }
  }
}
