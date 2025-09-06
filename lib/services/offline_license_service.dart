import 'package:shared_preferences/shared_preferences.dart';
import '../license_manager.dart';

class OfflineLicenseService {
  static const String _lastOnlineCheckKey = 'last_online_check';
  static const String _cachedLicenseStatusKey = 'cached_license_status';
  
  // المدة المسموحة للعمل بدون إنترنت (7 أيام)
  static const int maxOfflineDays = 7;
  
  // فحص إمكانية العمل بدون إنترنت
  static Future<bool> canWorkOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastOnlineCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // إذا مر أكثر من 7 أيام، يحتاج للاتصال بالإنترنت
    final daysPassed = (now - lastCheck) / (1000 * 60 * 60 * 24);
    return daysPassed <= maxOfflineDays;
  }
  
  // حفظ آخر فحص عبر الإنترنت
  static Future<void> saveLastOnlineCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastOnlineCheckKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  // حفظ حالة الترخيص في الذاكرة المحلية
  static Future<void> cacheLicenseStatus(Map<String, dynamic> status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedLicenseStatusKey, status.toString());
  }
  
  // جلب حالة الترخيص المحفوظة محلياً
  static Future<Map<String, dynamic>?> getCachedLicenseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedLicenseStatusKey);
    
    if (cached != null) {
      // تحويل النص المحفوظ إلى Map (يحتاج لمعالجة أفضل)
      // هنا نستخدم طريقة مبسطة
      return {
        'isActivated': cached.contains('isActivated: true'),
        'isTrialActive': cached.contains('isTrialActive: true'),
        'remainingDays': extractRemainingDays(cached),
        'status': cached.contains('isActivated: true') ? 'activated' : 'trial',
      };
    }
    return null;
  }
  
  static int extractRemainingDays(String cachedData) {
    final match = RegExp(r'remainingDays: (\d+)').firstMatch(cachedData);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
  
  // فحص الترخيص (أونلاين أو أوفلاين)
  static Future<Map<String, dynamic>> checkLicense() async {
    try {
      // محاولة الفحص عبر الإنترنت أولاً
      final onlineStatus = await LicenseManager.getLicenseStatus();
      
      // حفظ الحالة والوقت
      await cacheLicenseStatus(onlineStatus);
      await saveLastOnlineCheck();
      
      print('✅ تم فحص الترخيص عبر الإنترنت');
      return onlineStatus;
      
    } catch (e) {
      print('⚠️ فشل الاتصال بالإنترنت، محاولة العمل بدون إنترنت...');
      
      // فحص إمكانية العمل بدون إنترنت
      if (await canWorkOffline()) {
        final cached = await getCachedLicenseStatus();
        if (cached != null) {
          print('✅ تم استخدام البيانات المحفوظة محلياً');
          return cached;
        }
      }
      
      print('❌ لا يمكن العمل بدون إنترنت، يرجى الاتصال بالشبكة');
      return {
        'isActivated': false,
        'isTrialActive': false,
        'remainingDays': 0,
        'status': 'requires_internet',
        'error': 'يرجى الاتصال بالإنترنت للتحقق من الترخيص'
      };
    }
  }
}
