// lib/features/feat_posts/pages/categories_page.dart

import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/post_service.dart';
import 'category_posts_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryService _categoryService = CategoryService();
  final PostService _postService = PostService();

  List<CategoryModel> _categories = [];
  int _totalPostsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await _categoryService.getCategories();
      final posts = await _postService.fetchPosts();

      setState(() {
        _categories = categories;
        _totalPostsCount = posts.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "خطا در دریافت اطلاعات: $e",
              style: const TextStyle(fontFamily: 'Vazir'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE3F1),
      appBar: AppBar(title: const Text("دسته‌بندی‌ها")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _buildCategoryTree(),
            ),
    );
  }

  List<Widget> _buildCategoryTree() {
    List<Widget> widgets = [];

    final totalCategoriesCount = _categories.length;

    widgets.add(
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      color: Colors.teal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'دسته‌بندی‌ها',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalCategoriesCount مورد',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(height: 35, width: 1, color: Colors.grey.shade300),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.article_outlined,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'کل آگهی‌ها',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_totalPostsCount آگهی',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final parents = _categories.where((c) => c.parent.isEmpty).toList();

    for (var parent in parents) {
      widgets.add(
        Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              parent.name,
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            leading: const Icon(Icons.folder, color: Colors.teal),
            children: _categories
                .where((c) => c.parent == parent.id)
                .map(
                  (child) => ListTile(
                    title: Text(
                      child.name,
                      style: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
                    ),
                    leading: const Icon(
                      Icons.subdirectory_arrow_left,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryPostsPage(
                            categoryId: child.id,
                            categoryName: child.name,
                          ),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return widgets;
  }
}
