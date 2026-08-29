// lib/features/feat_posts/pages/create_post_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../feat_auth/services/auth_service.dart';

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
  File? _selectedImage;
  bool _isLoading = false;

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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
      final body = {
        'title': _titleController.text,
        'description': _descController.text,
        'price': _priceController.text,
        'user': AuthService.pb.authStore.model.id,
      };

      final files = _selectedImage != null
          ? [await http.MultipartFile.fromPath('image', _selectedImage!.path)]
          : <http.MultipartFile>[];

      await AuthService.pb.collection('posts').create(body: body, files: files);
      if (mounted) Navigator.pop(context);
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
