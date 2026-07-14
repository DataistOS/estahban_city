import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  static final PocketBase pb = PocketBase(dotenv.env['POCKETBASE_URL'] ?? '');

  bool get isAuthenticated => pb.authStore.isValid;

  Future<void> login(String nationalCode, String password) async {
    try {
      await pb.collection('users').authWithPassword(nationalCode, password);
    } catch (e) {
      throw Exception('نام کاربری یا رمز عبور اشتباه است');
    }
  }

  void logout() => pb.authStore.clear();
}
