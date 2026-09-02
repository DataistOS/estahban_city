// lib/features/feat_posts/pages/create_post_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../feat_auth/services/auth_service.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/post_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  final CategoryService _categoryService = CategoryService();
  final PostService _postService = PostService();

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

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
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در دریافت دسته‌بندی‌ها: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedImage = File(file.path));
    }
  }

  List<DropdownMenuItem<String>> _buildCategoryDropdownItems() {
    List<DropdownMenuItem<String>> items = [];

    final parentCategories = _categories
        .where((c) => c.parent.isEmpty)
        .toList();

    for (var parent in parentCategories) {
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: 'parent_${parent.id}',
          child: Text(
            parent.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      );

      final children = _categories.where((c) => c.parent == parent.id).toList();
      for (var child in children) {
        items.add(
          DropdownMenuItem<String>(
            value: child.id,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('— ${child.name}'),
            ),
          ),
        );
      }
    }

    return items;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً یک دسته‌بندی انتخاب کنید")),
      );
      return;
    }

    if (!AuthService.pb.authStore.isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لطفاً ابتدا وارد حساب کاربری خود شوید"),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final priceValue = double.tryParse(_priceController.text) ?? 0.0;

      http.MultipartFile? imageFile;
      if (_selectedImage != null) {
        imageFile = await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        );
      }

      await _postService.createPost(
        title: _titleController.text,
        description: _descController.text,
        price: priceValue,
        categoryId: _selectedCategoryId!,
        imageFile: imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "آگهی شما با موفقیت ثبت شد و پس از تأیید مدیران نمایش داده خواهد شد",
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطا: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ثبت آگهی")),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: "دسته‌بندی"),
                    items: _buildCategoryDropdownItems(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (v) =>
                        v == null ? "انتخاب دسته‌بندی اجباری است" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "عنوان"),
                    validator: (v) => v == null || v.isEmpty ? "اجباری" : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "توضیحات"),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "قیمت"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("انتخاب عکس"),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.file(_selectedImage!, height: 150),
                    ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submit,
                          child: const Text("ثبت آگهی"),
                        ),
                ],
              ),
            ),
    );
  }
}
