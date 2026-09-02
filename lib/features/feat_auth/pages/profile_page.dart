// lib/features/feat_auth/pages/profile_page.dart

import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
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
    final model = AuthService.pb.authStore.model;

    if (!isLoggedIn || model == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFDDE3F1),
        appBar: AppBar(
          title: const Text(
            'حساب کاربری',
            style: TextStyle(fontFamily: 'Vazir', color: Color(0xFF333333)),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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

    final userName = model.data['name'] ?? 'شهروند استهبان';
    final userEmail = model.data['email'] ?? 'نامشخص';
    final userPhone = model.data['phone_number'] ?? 'وارد نشده';
    final userAddress = model.data['address'] ?? 'وارد نشده';
    final userType = model.data['user_type'] ?? 'عادی';

    final createdStr = model.created ?? '';
    final formattedDateCreated = createdStr.isNotEmpty
        ? intl.DateFormat('yyyy/MM/dd').format(DateTime.parse(createdStr))
        : 'نامشخص';

    return Scaffold(
      backgroundColor: const Color(0xFFDDE3F1),
      appBar: AppBar(
        title: const Text(
          'پروفایل کاربری',
          style: TextStyle(fontFamily: 'Vazir', color: Color(0xFF333333)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(context, userName),
            const SizedBox(height: 16),

            // دکمه دسترسی به آگهی‌های من
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
                padding: const EdgeInsets.all(8.0),
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
                padding: const EdgeInsets.all(8.0),
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

  Widget _buildProfileHeader(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF333333),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Vazir',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF333333),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
