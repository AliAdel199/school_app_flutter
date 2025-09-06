import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String _offlineDaysKey = 'max_offline_days';
  static const String _autoSyncKey = 'auto_sync_enabled';
  
  // الحصول على عدد الأيام المسموحة للعمل بدون إنترنت
  static Future<int> getMaxOfflineDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_offlineDaysKey) ?? 7; // افتراضي 7 أيام
  }
  
  // تعديل عدد الأيام المسموحة
  static Future<void> setMaxOfflineDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_offlineDaysKey, days);
  }
  
  // فحص حالة المزامنة التلقائية
  static Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSyncKey) ?? true;
  }
  
  // تفعيل/إلغاء المزامنة التلقائية
  static Future<void> setAutoSync(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncKey, enabled);
  }
}
