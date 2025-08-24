import 'package:flutter/foundation.dart';

import '../models/user_models.dart';
import '../services/authservice.dart';

/// UserProvider - لإدارة حالة بيانات المستخدم الحالي عبر التطبيق
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _loading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchCurrentUser() async {
    // إذا كانت البيانات موجودة مسبقاً أو هناك تحميل جاري، لا نكرر الطلب
    if (_currentUser != null || _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('👤 [UserProvider] جلب بيانات المستخدم من /auth/user');
      final user = await _authService.fetchCurrentUser();
      _currentUser = user;
      print('✅ [UserProvider] تم تحديث بيانات المستخدم: ${user.name}');
    } catch (e) {
      _error = e.toString();
      print('❌ [UserProvider] فشل جلب بيانات المستخدم: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    print('🧹 [UserProvider] مسح بيانات المستخدم...');
    _currentUser = null;
    _error = null;
    _loading = false;
    notifyListeners();
    print('✅ [UserProvider] تم مسح بيانات المستخدم بنجاح');
  }
}

