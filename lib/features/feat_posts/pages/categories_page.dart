// lib/features/feat_posts/pages/categories_page.dart

import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import 'category_posts_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در دریافت دسته‌بندی‌ها: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    final parents = _categories.where((c) => c.parent.isEmpty).toList();

    for (var parent in parents) {
      widgets.add(
        ExpansionTile(
          title: Text(
            parent.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          leading: const Icon(Icons.folder, color: Colors.teal),
          children: _categories
              .where((c) => c.parent == parent.id)
              .map(
                (child) => ListTile(
                  title: Text(child.name),
                  leading: const Icon(Icons.subdirectory_arrow_left, size: 18),
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
      );
    }
    return widgets;
  }
}
