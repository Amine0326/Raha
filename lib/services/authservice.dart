import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'apiservice.dart';
import '../models/user_models.dart';

/// AuthService - خدمة المصادقة (تسجيل الدخول والتسجيل) مع تخزين التوكن
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final ApiService _api = ApiService();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _roleKey = 'auth_role';

  /// تسجيل الدخول
  /// body: {"email": "...", "password": "..."}
  Future<AuthResult> login({required String email, required String password}) async {
    final body = {
      'email': email.trim(),
      'password': password,
    };

    final dynamic data = await _api.post('/auth/login', body: body, withAuth: false);

    // نتوقع: { token, userId, role }
    final token = data['token']?.toString();
    final userId = int.tryParse(data['userId'].toString());
    final role = data['role']?.toString();

    if (token == null || token.isEmpty) {
      throw ApiException('الاستجابة من الخادم غير صالحة: لا يوجد رمز توثيق.');
    }

    await _persistSession(token: token, userId: userId, role: role);

    print('✅ تم تسجيل الدخول بنجاح وتخزين التوكن.');

    return AuthResult(token: token, userId: userId, role: role);
  }

  /// التسجيل للمريض (الدور يثبت على "Patient" بغض النظر عن المُدخل)
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String caregiverName,
    required String caregiverPhone,
  }) async {
    final body = {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'role': 'Patient',
      'phone': phone.trim(),
      'address': address.trim(),
      'caregiver_name': caregiverName.trim(),
      'caregiver_phone': caregiverPhone.trim(),
    };

    final dynamic data = await _api.post('/auth/register', body: body, withAuth: false);

    // نتوقع: { token, userId, role }
    final token = data['token']?.toString();
    final userId = int.tryParse(data['userId'].toString());
    final role = data['role']?.toString();

    if (token == null || token.isEmpty) {
      throw ApiException('الاستجابة من الخادم غير صالحة: لا يوجد رمز توثيق.');
    }

    await _persistSession(token: token, userId: userId, role: role);

    print('✅ تم إنشاء الحساب وتخزين التوكن بنجاح.');

    return AuthResult(token: token, userId: userId, role: role);
  }

  /// جلب بيانات المستخدم الحالي عبر التوكن
  Future<User> fetchCurrentUser() async {
    print('🟦 بدء جلب بيانات المستخدم الحالي...');
    final dynamic data = await _api.get('/auth/user', withAuth: true);
    if (data is! Map<String, dynamic>) {
      throw ApiException('الاستجابة من الخادم غير متوقعة عند جلب الملف الشخصي.');
    }
    final user = User.fromJson(data);
    print('🟢 تم جلب بيانات المستخدم: ${user.name}');
    return user;
  }

  /// حفظ الجلسة (التوكن + userId + role)
  Future<void> _persistSession({
    required String token,
    int? userId,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
    }
    if (role != null) {
      await prefs.setString(_roleKey, role);
    }
  }

  /// استرجاع التوكن المخزن
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// استرجاع معلومات المستخدم
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// التحقق إن كان المستخدم مسجلاً الدخول
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// تسجيل الخروج ومسح الجلسة
  Future<void> logout() async {
    try {
      print('🔐 بدء مسح بيانات الجلسة...');
      final prefs = await SharedPreferences.getInstance();
      
      // Remove specific auth keys first
      final tokenRemoved = await prefs.remove(_tokenKey);
      final userIdRemoved = await prefs.remove(_userIdKey);
      final roleRemoved = await prefs.remove(_roleKey);
      
      print('🔐 تم مسح التوكن: $tokenRemoved');
      print('🔐 تم مسح معرف المستخدم: $userIdRemoved');
      print('🔐 تم مسح الدور: $roleRemoved');
      
      // Verify tokens are cleared
      final remainingToken = await prefs.getString(_tokenKey);
      if (remainingToken != null) {
        print('⚠️ التوكن لا يزال موجوداً، محاولة مسح شامل...');
        await prefs.clear();
      }
      
      print('✅ تم تسجيل الخروج ومسح بيانات الجلسة بنجاح.');
    } catch (e) {
      print('❌ خطأ أثناء تسجيل الخروج: $e');
      // Don't throw exception, just log the error
      // The app should still be able to navigate to login screen
    }
  }
}

class AuthResult {
  final String token;
  final int? userId;
  final String? role;

  AuthResult({required this.token, this.userId, this.role});
}

