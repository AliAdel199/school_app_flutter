import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkHelper {
  /// فحص حالة الاتصال بالإنترنت
  static Future<bool> isConnected() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      
      // إذا لم يكن هناك اتصال
      if (result.contains(ConnectivityResult.none)) {
        return false;
      }
      
      // فحص فعلي للاتصال عبر ping لـ Google DNS
      final result2 = await InternetAddress.lookup('google.com');
      return result2.isNotEmpty && result2[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// فحص الاتصال مع خدمة Supabase
  static Future<bool> canReachSupabase() async {
    try {
      const supabaseHost = 'hvqpucjmtwqtaqydpskv.supabase.co';
      final result = await InternetAddress.lookup(supabaseHost);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('❌ لا يمكن الوصول إلى Supabase: $e');
      return false;
    }
  }
  
  /// جلب معرف المؤسسة من التخزين المحلي
  static Future<String?> getOrganizationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('organization_id');
    } catch (e) {
      print('❌ خطأ في جلب معرف المؤسسة: $e');
      return null;
    }
  }
  
  /// حفظ معرف المؤسسة في التخزين المحلي
  static Future<bool> saveOrganizationId(String organizationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('organization_id', organizationId);
    } catch (e) {
      print('❌ خطأ في حفظ معرف المؤسسة: $e');
      return false;
    }
  }
  
  /// فحص شامل للشبكة والاتصال
  static Future<Map<String, dynamic>> checkNetworkStatus() async {
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();
    
    final isConnected = await NetworkHelper.isConnected();
    final canReachSupabase = await NetworkHelper.canReachSupabase();
    
    return {
      'connectivity_type': connectivityResult.first.toString(),
      'is_connected': isConnected,
      'can_reach_supabase': canReachSupabase,
      'message': _getNetworkMessage(connectivityResult.first, isConnected, canReachSupabase),
    };
  }
  
  /// حفظ اسم المؤسسة محلياً
  static Future<void> saveOrganizationName(String organizationName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('organization_name', organizationName);
    } catch (e) {
      print('❌ خطأ في حفظ اسم المؤسسة: $e');
    }
  }

  /// جلب اسم المؤسسة المحفوظ
  static Future<String?> getOrganizationName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('organization_name');
    } catch (e) {
      print('❌ خطأ في جلب اسم المؤسسة: $e');
      return null;
    }
  }

  /// حفظ بيانات المستخدم الحالي
  static Future<void> saveCurrentUser({
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userId);
      await prefs.setString('current_user_name', userName);
      await prefs.setString('current_user_email', userEmail);
      await prefs.setString('current_user_role', userRole);
      print('✅ تم حفظ بيانات المستخدم');
    } catch (e) {
      print('❌ خطأ في حفظ بيانات المستخدم: $e');
    }
  }

  /// جلب بيانات المستخدم الحالي
  static Future<Map<String, String?>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'user_id': prefs.getString('current_user_id'),
        'user_name': prefs.getString('current_user_name'),
        'user_email': prefs.getString('current_user_email'),
        'user_role': prefs.getString('current_user_role'),
      };
    } catch (e) {
      print('❌ خطأ في جلب بيانات المستخدم: $e');
      return {
        'user_id': null,
        'user_name': null,
        'user_email': null,
        'user_role': null,
      };
    }
  }

  /// مسح بيانات المستخدم فقط
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('current_user_name');
      await prefs.remove('current_user_email');
      await prefs.remove('current_user_role');
      print('✅ تم مسح بيانات المستخدم');
    } catch (e) {
      print('❌ خطأ في مسح بيانات المستخدم: $e');
    }
  }
  
  static String _getNetworkMessage(
    ConnectivityResult connectivity, 
    bool isConnected, 
    bool canReachSupabase
  ) {
    if (!isConnected) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    
    if (!canReachSupabase) {
      return 'يوجد اتصال بالإنترنت ولكن لا يمكن الوصول إلى خادم قاعدة البيانات';
    }
    
    return 'الاتصال ممتاز مع جميع الخدمات';
  }
}
