// lib/features/feat_about/pages/about_us_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchEnamad() async {
    final Uri url = Uri.parse('https://trustseal.enamad.ir/?id=659692&Code=pSjlon0z5SPy68r7kiQ9617egIG1R1W3');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("درباره")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "درباره",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "دیوار استهبان یک پلتفرم متمرکز برای تعاملات محلی شهروندان است. این سامانه با هدف ایجاد بازاری شفاف و امن برای تبادل کالا، ارائه خدمات و آگاهی از فرصت‌های شهری در اکوسیستم دیتائیست طراحی شده است",
              style: TextStyle(fontSize: 12),
            ),
            const Spacer(),
            Center(
              child: InkWell(
                onTap: _launchEnamad,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Image.network(
                    'https://trustseal.enamad.ir/logo.aspx?id=659692&Code=pSjlon0z5SPy68r7kiQ9617egIG1R1W3',
                    width: 120,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'تصویر اینماد',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}