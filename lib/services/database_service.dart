import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../helpers/network_helper.dart';

/// خدمة قاعدة البيانات الرئيسية
/// تدير جميع العمليات مع Supabase بطريقة منظمة ومحسنة
class DatabaseService {
  static const String _supabaseUrl = 'https://hvqpucjmtwqtaqydpskv.supabase.co';
  static const String _supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2cXB1Y2ptdHdxdGFxeWRwc2t2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1Mjg3NjEsImV4cCI6MjA2OTEwNDc2MX0.trWf50z1EiUij7cwDUooo6jVFCjVIm2ya1Pf2Pmvg5c";
  
  static bool _isInitialized = false;
  static bool _isEnabled = false;
  
  static SupabaseClient get client => Supabase.instance.client;
  static bool get isEnabled => _isEnabled;
  static bool get isInitialized => _isInitialized;

  /// تهيئة قاعدة البيانات
  static Future<bool> initialize() async {
    if (_isInitialized) return _isEnabled;
    
    try {
      print('🔧 بدء تهيئة قاعدة البيانات...');
      
      // التحقق من صحة المتغيرات
      if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
        print('❌ متغيرات قاعدة البيانات غير مكتملة');
        _isEnabled = false;
        _isInitialized = true;
        return false;
      }
      
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        debug: false,
      );
      
      // اختبار الاتصال
      await client.from('educational_organizations').select('id').limit(1);
      
      _isEnabled = true;
      _isInitialized = true;
      print('✅ تم تهيئة قاعدة البيانات بنجاح');
      return true;
      
    } catch (e) {
      print('❌ فشل في تهيئة قاعدة البيانات: $e');
      _isEnabled = false;
      _isInitialized = true;
      return false;
    }
  }

  /// تشفير كلمة المرور
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// تنفيذ عملية مع إعادة المحاولة عند فشل الشبكة
  static Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
    String? operationName,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // التحقق من الاتصال قبل كل محاولة
        if (!await NetworkHelper.isConnected()) {
          throw Exception('لا يوجد اتصال بالإنترنت');
        }
        
        final result = await operation();
        if (operationName != null && attempt > 1) {
          print('✅ نجحت العملية ${operationName} في المحاولة $attempt');
        }
        return result;
        
      } catch (e) {
        final operationText = operationName ?? 'العملية';
        print('🔄 فشلت $operationText - المحاولة $attempt من $maxRetries: $e');
        
        if (attempt == maxRetries) {
          print('❌ فشلت $operationText نهائياً بعد $maxRetries محاولات');
          rethrow;
        }
        
        // انتظار متزايد بين المحاولات
        await Future.delayed(delay * attempt);
      }
    }
    return null;
  }

  /// التحقق من حالة قاعدة البيانات
  static Future<Map<String, dynamic>> checkStatus() async {
    final Map<String, dynamic> status = {
      'is_initialized': _isInitialized,
      'is_enabled': _isEnabled,
      'connection_test': false,
      'tables_accessible': false,
      'error': null,
    };

    if (!_isInitialized) {
      status['error'] = 'قاعدة البيانات غير مهيأة';
      return status;
    }

    if (!_isEnabled) {
      status['error'] = 'قاعدة البيانات غير مفعلة';
      return status;
    }

    try {
      // اختبار الاتصال الأساسي
      await client.from('educational_organizations').select('id').limit(1);
      status['connection_test'] = true;
      
      // اختبار الوصول للجداول الأساسية
      final tables = ['educational_organizations', 'schools', 'users', 'students'];
      for (final table in tables) {
        await client.from(table).select('id').limit(1);
      }
      status['tables_accessible'] = true;
      
    } catch (e) {
      status['error'] = 'خطأ في الاتصال: $e';
    }

    return status;
  }

  /// تنظيف الموارد
  static Future<void> dispose() async {
    try {
      await Supabase.instance.dispose();
      _isInitialized = false;
      _isEnabled = false;
      print('🧹 تم تنظيف موارد قاعدة البيانات');
    } catch (e) {
      print('⚠️ خطأ في تنظيف موارد قاعدة البيانات: $e');
    }
  }
}
