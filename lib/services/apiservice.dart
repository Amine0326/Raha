import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// ApiService - مسؤول عن جميع طلبات HTTP العامة في التطبيق
/// - يحتوي على دوال GET و POST عامة
/// - يضيف التوكن تلقائياً عندما يطلب withAuth
/// - يعالج الأخطاء ويطبع سجلات تصحيحية باللغة العربية
class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static const String baseUrl = 'https://rahati-platform.onrender.com/api';

  // مهلة عامة لجميع الطلبات
  static const Duration _timeout = Duration(seconds: 20);

  /// إنشاء الترويسات Headers مع خيار إضافة التوكن
  Future<Map<String, String>> _buildHeaders({bool withAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (withAuth) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // تجاهل إن فشل الوصول للمخزن، سيتم التعامل لاحقاً عند الاستدعاء
      }
    }

    return headers;
  }

  /// طلب POST عام
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders(withAuth: withAuth);

    // سجلات تصحيحية (وضع التصحيح فقط)
    if (kDebugMode) {
      print('🔵 [HTTP POST] إلى: $url');
      print('📦 الجسم المُرسل: ${jsonEncode(body ?? {})}');
      print('🪪 ترويسات: $headers');
    }

    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(_timeout);

      if (kDebugMode) {
        print('🟣 [HTTP POST] الحالة: ${response.statusCode}');
        print('📥 الاستجابة: ${response.body}');
      }

      return _handleResponse(response);
    } on SocketException {
      if (kDebugMode) {
        print('❌ فشل في الاتصال بالشبكة');
      }
      throw ApiException('تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.');
    } on TimeoutException {
      if (kDebugMode) {
        print('⏰ انتهت مهلة الطلب');
      }
      throw ApiException('انتهت مهلة الاتصال. يرجى المحاولة لاحقاً.');
    } on ApiException {
      // أعد رمي أخطاء HTTP كما هي بدون تغليف حتى لا نفقد رمز الحالة
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❗ خطأ غير متوقع أثناء الطلب: $e');
      }
      throw ApiException('حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.');
    }
  }

  /// طلب GET عام
  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool withAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = await _buildHeaders(withAuth: withAuth);

    // سجلات تصحيحية (وضع التصحيح فقط)
    if (kDebugMode) {
      print('🔵 [HTTP GET] إلى: $uri');
      print('🪪 ترويسات: $headers');
    }

    try {
      final response = await http.get(uri, headers: headers).timeout(_timeout);

      if (kDebugMode) {
        print('🟣 [HTTP GET] الحالة: ${response.statusCode}');
        print('📥 الاستجابة: ${response.body}');
      }

      return _handleResponse(response);
    } on SocketException {
      if (kDebugMode) {
        print('❌ فشل في الاتصال بالشبكة');
      }
      throw ApiException('تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.');
    } on TimeoutException {
      if (kDebugMode) {
        print('⏰ انتهت مهلة الطلب');
      }
      throw ApiException('انتهت مهلة الاتصال. يرجى المحاولة لاحقاً.');
    } on ApiException {
      // أعد رمي أخطاء HTTP كما هي بدون تغليف
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❗ خطأ غير متوقع أثناء الطلب: $e');
      }
      throw ApiException('حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.');
    }
  }

  /// معالجة الاستجابة العامة
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (e) {
      // إذا لم تكن الاستجابة JSON صالح
      data = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    // رسائل خطأ عربية بناءً على الحالة
    String message = 'حدث خطأ غير متوقع. (رمز: $statusCode)';
    if (statusCode == 400) {
      message = 'طلب غير صالح. يرجى التحقق من البيانات المُرسلة.';
    } else if (statusCode == 401) {
      // تخصيص رسالة بيانات اعتماد غير صحيحة إذا أرسل الخادم ذلك
      if (data is Map && (data['message']?.toString().toLowerCase().contains('invalid credentials') ?? false)) {
        message = 'بيانات تسجيل الدخول غير صحيحة.';
      } else {
        message = 'غير مخول. يرجى تسجيل الدخول من جديد.';
      }
    } else if (statusCode == 403) {
      message = 'صلاحيات غير كافية للوصول إلى المورد المطلوب.';
    } else if (statusCode == 404) {
      message = 'المورد غير موجود.';
    } else if (statusCode == 422) {
      message = 'البيانات غير صحيحة. يرجى مراجعة الحقول.';
    } else if (statusCode >= 500) {
      message = 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
    }

    throw ApiException(message, statusCode: statusCode, details: data);
  }
}

/// استثناء مخصص لواجهات البرمجة
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;
  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

