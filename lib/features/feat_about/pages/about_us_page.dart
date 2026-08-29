// lib/features/feat_about/pages/about_us_page.dart
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("درباره")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "درباره",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "دیوار استهبان یک پلتفرم متمرکز برای تعاملات محلی شهروندان است. این سامانه با هدف ایجاد بازاری شفاف و امن برای تبادل کالا، ارائه خدمات و آگاهی از فرصت‌های شهری در اکوسیستم دیتائیست طراحی شده است",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
