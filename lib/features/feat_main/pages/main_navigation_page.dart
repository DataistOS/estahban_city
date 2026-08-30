// lib/features/feat_main/pages/main_navigation_page.dart

import 'package:flutter/material.dart';
import '../../feat_posts/pages/home_page.dart';
import '../../feat_posts/pages/categories_page.dart';
import '../../feat_about/pages/about_us_page.dart';
import '../../feat_auth/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const AboutUsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'آگهی‌ها'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'دسته‌ها'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'درباره'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حساب کاربری',),
        ],
      ),
    );
  }
}
