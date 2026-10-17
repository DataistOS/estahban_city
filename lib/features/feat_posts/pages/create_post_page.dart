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
  final List<File> _galleryImages = [];

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

  Future<void> _pickMainImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedImage = File(file.path));
    }
  }

  Future<void> _pickGalleryImages() async {
    if (_galleryImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حداکثر می‌توانید ۴ تصویر برای گالری انتخاب کنید"),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var picked in pickedFiles) {
          if (_galleryImages.length < 4) {
            _galleryImages.add(File(picked.path));
          }
        }
      });
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

      List<http.MultipartFile> galleryMultipartFiles = [];
      for (var file in _galleryImages) {
        galleryMultipartFiles.add(
          await http.MultipartFile.fromPath('gallery', file.path),
        );
      }

      await _postService.createPost(
        title: _titleController.text,
        description: _descController.text,
        price: priceValue,
        categoryId: _selectedCategoryId!,
        imageFile: imageFile,
        galleryFiles: galleryMultipartFiles,
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

                  ElevatedButton.icon(
                    onPressed: _pickMainImage,
                    icon: const Icon(Icons.image),
                    label: const Text("انتخاب تصویر اصلی (کاور)"),
                  ),
                  if (_selectedImage != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.file(
                            _selectedImage!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                        ),
                      ],
                    ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: _pickGalleryImages,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      "افزودن تصاویر گالری (${_galleryImages.length}/4)",
                    ),
                  ),
                  if (_galleryImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _galleryImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              top: 8.0,
                            ),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.file(
                                  _galleryImages[index],
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(
                                      () => _galleryImages.removeAt(index),
                                    );
                                  },
                                  child: Container(
                                    color: Colors.black54,
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 25),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "ثبت نهایی آگهی",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
