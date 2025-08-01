import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

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
