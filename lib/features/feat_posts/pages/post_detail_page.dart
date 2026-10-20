// lib/features/feat_posts/pages/post_detail_page.dart

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../../feat_auth/services/auth_service.dart';
import '../services/post_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final PostService _postService = PostService();
  int _currentImageIndex = 0;

  String _formatPrice(dynamic price) {
    if (price == null || price == 0 || price == '0' || price == '') {
      return "تماس بگیرید";
    }

    final numPrice = num.tryParse(price.toString()) ?? 0;
    if (numPrice <= 0) {
      return "تماس بگیرید";
    }

    return "$numPrice تومان";
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'نامشخص';
    final parsedDate = DateTime.tryParse(dateStr);
    if (parsedDate != null) {
      return '${parsedDate.year}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.day.toString().padLeft(2, '0')}';
    }
    return 'نامشخص';
  }

  void _openFullScreenGallery(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGalleryPage(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allImageUrls = [];
    if (widget.post.image.isNotEmpty) {
      allImageUrls.add(
        AuthService.pb.files
            .getUrl(widget.post.toRecord(), widget.post.image)
            .toString(),
      );
    }
    for (var galleryImg in widget.post.gallery) {
      if (galleryImg.isNotEmpty) {
        allImageUrls.add(
          AuthService.pb.files
              .getUrl(widget.post.toRecord(), galleryImg)
              .toString(),
        );
      }
    }

    final authRecord = AuthService.pb.authStore.record;
    final currentUserId = authRecord != null ? authRecord.id : '';

    final postUserId = widget.post.toRecord().getStringValue('user');
    final bool isOwner =
        currentUserId.isNotEmpty && postUserId == currentUserId;

    final formattedPrice = _formatPrice(widget.post.price);
    final bool isContactUs = formattedPrice == "تماس بگیرید";
    final formattedDate = _formatDate(widget.post.created);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmAndDelete(context),
            ),
        ],
      ),
      body: ListView(
        children: [
          if (allImageUrls.isNotEmpty) ...[
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: allImageUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        _openFullScreenGallery(context, allImageUrls, index),
                    child: Hero(
                      tag: 'post_image_$index',
                      child: Image.network(
                        allImageUrls[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (allImageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allImageUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentImageIndex == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.teal
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
          ] else
            Container(
              height: 300,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.grey,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: isContactUs ? 16 : 20,
                        color: isContactUs ? Colors.orange[800] : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'تاریخ ثبت: $formattedDate',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 30),
                Text(
                  widget.post.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAndDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف آگهی"),
        content: const Text(
          "آیا مطمئن هستید که می‌خواهید این آگهی را حذف کنید؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("انصراف"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _postService.softDeletePost(widget.post.id);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("خطا در حذف: $e")));
                }
              }
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class FullScreenGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGalleryPage({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenGalleryPage> createState() => _FullScreenGalleryPageState();
}

class _FullScreenGalleryPageState extends State<FullScreenGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} از ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white, fontFamily: 'Vazir'),
        ),
      ),
      body: Center(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
