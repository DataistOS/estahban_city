// lib/features/feat_auth/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../feat_main/pages/main_navigation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nationalCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nationalCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        _nationalCodeController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
        );
      }
    }
  }

  Future<void> _launchSignUpUrl() async {
    final Uri url = Uri.parse('https://idna.dataist.ir');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE3F1),
      appBar: AppBar(
        title: const Text(
          'ورود به استهبان سیتی',
          style: TextStyle(fontFamily: 'Vazir'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'ورود به حساب کاربری',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                          fontFamily: 'Vazir',
                        ),
                      ),
                      const SizedBox(height: 48),

                      TextFormField(
                        controller: _nationalCodeController,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontFamily: 'Vazir',
                        ),
                        decoration: InputDecoration(
                          labelText: 'کد ملی',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Vazir',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(
                            Icons.credit_card,
                            color: Colors.grey,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا کد ملی خود را وارد کنید';
                          }
                          if (value.length != 10) {
                            return 'کد ملی باید ۱۰ رقم باشد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontFamily: 'Vazir',
                        ),
                        decoration: InputDecoration(
                          labelText: 'رمز عبور',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Vazir',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(
                            Icons.lock,
                            color: Colors.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا رمز عبور خود را وارد کنید';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      if (authProvider.errorMessage != null)
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),

                      authProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF333333),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333333),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'ورود',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Vazir',
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _launchSignUpUrl,
                        child: const Text(
                          'هنوز حساب کاربری ندارید؟ ثبت‌نام کنید.',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
