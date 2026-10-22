// lib/features/feat_auth/pages/profile_page.dart

import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../../feat_posts/pages/my_posts_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.pb.authStore.isValid;
    final record = AuthService.pb.authStore.record;

    if (!isLoggedIn || record == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFDDE3F1),
        appBar: AppBar(title: const Text('حساب کاربری')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'برای ثبت آگهی و مدیریت حساب، لطفاً وارد شوید',
                  style: TextStyle(fontSize: 16, fontFamily: 'Vazir'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ورود به حساب کاربری',
                    style: TextStyle(fontFamily: 'Vazir', fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userName = record.data['name'] ?? 'شهروند استهبان';
    final userEmail = record.data['email'] ?? 'نامشخص';
    final userPhone = record.data['phone_number'] ?? 'وارد نشده';
    final userAddress = record.data['address'] ?? 'وارد نشده';

    final rawUserType = record.getStringValue('user_type', 'individual');
    final String userType = rawUserType == 'legal' ? 'حقوقی' : 'حقیقی';

    final rawTier = record.getStringValue('tier', 'free');
    String userTierLabel = 'عادی (Free)';
    if (rawTier == 'bronze') {
      userTierLabel = 'برنزی (Bronze)';
    } else if (rawTier == 'silver') {
      userTierLabel = 'نقره‌ای (Silver)';
    } else if (rawTier == 'gold') {
      userTierLabel = 'طلایی (Gold)';
    }

    final avatarFileName = record.getStringValue('avatar');
    String? avatarUrl;
    if (avatarFileName.isNotEmpty) {
      avatarUrl = AuthService.pb.files
          .getUrl(record, avatarFileName)
          .toString();
    }

    final createdStr = record.get<String>('created');
    String formattedDateCreated = 'نامشخص';
    if (createdStr.isNotEmpty) {
      final parsedDate = DateTime.tryParse(createdStr);
      if (parsedDate != null) {
        formattedDateCreated =
            '${parsedDate.year}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.day.toString().padLeft(2, '0')}';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDDE3F1),
      // AppBar به طور خودکار از تم سراسری main.dart پیروی می‌کند
      appBar: AppBar(title: const Text('پروفایل کاربری')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(context, userName, userTierLabel, avatarUrl),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.list_alt, color: Color(0xFF333333)),
                title: const Text(
                  'آگهی‌های من',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
                subtitle: const Text(
                  'مشاهده وضعیت تایید یا رد آگهی‌ها',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPostsPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildInfoTile(context, Icons.email, 'ایمیل', userEmail),
                    _buildInfoTile(
                      context,
                      Icons.phone,
                      'شماره تلفن',
                      userPhone,
                    ),
                    _buildInfoTile(
                      context,
                      Icons.location_on,
                      'آدرس',
                      userAddress,
                    ),
                    _buildInfoTile(
                      context,
                      Icons.person_pin,
                      'نوع کاربر',
                      userType,
                    ),
                    _buildInfoTile(
                      context,
                      Icons.workspace_premium,
                      'سطح اشتراک',
                      userTierLabel,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildInfoTile(
                      context,
                      Icons.date_range,
                      'تاریخ ثبت‌نام',
                      formattedDateCreated,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                AuthService.pb.authStore.clear();
                setState(() {});
              },
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                'خروج از حساب کاربری',
                style: TextStyle(fontFamily: 'Vazir', fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String tierLabel,
    String? avatarUrl,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFF333333),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Vazir',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.shade200, width: 1),
            ),
            child: Text(
              tierLabel,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF333333)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Vazir',
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF333333),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Vazir',
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
