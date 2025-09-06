import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLicenseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // تحديث حالة الترخيص في Supabase
  static Future<void> updateLicenseStatusInSupabase({
    required int schoolId,
    required String status,
    required bool isActivated,
    required bool isTrialActive,
    required int remainingDays,
    String? licenseKey,
    DateTime? activationDate,
    DateTime? expiryDate,
  }) async {
    try {
      final data = <String, dynamic>{
        'subscription_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // إضافة البيانات الاختيارية فقط إذا كانت متوفرة
      if (activationDate != null) {
        data['trial_expires_at'] = activationDate.add(Duration(days: 365)).toIso8601String();
      }

      // تحديث البيانات في جدول educational_organizations
      await _supabase
          .from('educational_organizations')
          .update(data)
          .eq('id', schoolId);

      print('✅ تم تحديث حالة الترخيص في Supabase بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث حالة الترخيص في Supabase: $e');
      rethrow;
    }
  }

  // ملاحظة: لا نحتاج لتحديث الإحصائيات يدوياً لأنها محسوبة تلقائياً في الـ view
  // تحديث إحصائيات الترخيص (deprecated - الـ view يحسب تلقائياً)
  static Future<void> updateLicenseStatsInSupabase({
    required int schoolId,
    required int totalStudents,
    required int totalClasses,
    required int totalUsers,
    int totalPayments = 0,
    String licenseType = 'trial',
  }) async {
    // الإحصائيات محسوبة تلقائياً في license_stats_view
    // لا نحتاج لتحديث يدوي
    print('📊 الإحصائيات محسوبة تلقائياً في license_stats_view');
  }

  // جلب حالة الترخيص من Supabase
  static Future<Map<String, dynamic>?> getLicenseStatusFromSupabase(int schoolId) async {
    try {
      final response = await _supabase
          .from('license_status_view')
          .select()
          .eq('school_id', schoolId)
          .order('last_updated', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب حالة الترخيص من Supabase: $e');
      return null;
    }
  }

  // جلب إحصائيات الترخيص من Supabase
  static Future<Map<String, dynamic>?> getLicenseStatsFromSupabase(int schoolId) async {
    try {
      final response = await _supabase
          .from('license_stats_view')
          .select()
          .eq('school_id', schoolId)
          .order('last_calculated', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات الترخيص من Supabase: $e');
      return null;
    }
  }

  // تحديث كل من حالة الترخيص والإحصائيات
  static Future<void> updateAllLicenseDataInSupabase({
    required int schoolId,
    required Map<String, dynamic> licenseStatus,
    required int totalStudents,
    required int totalClasses,
    required int totalUsers,
    int totalPayments = 0,
  }) async {
    try {
      // تحديد نوع الترخيص
      String licenseType = 'trial';
      if (licenseStatus['isActivated'] == true) {
        licenseType = 'premium';
      } else if (licenseStatus['isTrialActive'] == false) {
        licenseType = 'expired';
      }

      // تحديث حالة الترخيص
      await updateLicenseStatusInSupabase(
        schoolId: schoolId,
        status: licenseStatus['status'] ?? 'trial',
        isActivated: licenseStatus['isActivated'] ?? false,
        isTrialActive: licenseStatus['isTrialActive'] ?? false,
        remainingDays: licenseStatus['remainingDays'] ?? 0,
        licenseKey: licenseStatus['licenseKey'],
        activationDate: licenseStatus['activationDate'],
        expiryDate: licenseStatus['expiryDate'],
      );

      // تحديث إحصائيات الترخيص
      await updateLicenseStatsInSupabase(
        schoolId: schoolId,
        totalStudents: totalStudents,
        totalClasses: totalClasses,
        totalUsers: totalUsers,
        totalPayments: totalPayments,
        licenseType: licenseType,
      );

      print('✅ تم تحديث جميع بيانات الترخيص في Supabase بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث بيانات الترخيص في Supabase: $e');
      rethrow;
    }
  }

  // فحص اتصال الإنترنت والمزامنة مع Supabase
  static Future<bool> syncWithSupabase(int schoolId) async {
    try {
      // اختبار الاتصال
      final testResponse = await _supabase
          .from('schools')
          .select('id')
          .eq('id', schoolId)
          .limit(1);

      return testResponse.isNotEmpty;
    } catch (e) {
      print('❌ فشل الاتصال بـ Supabase: $e');
      return false;
    }
  }

  // الحصول على معرف المدرسة الحالي
  static Future<int?> getCurrentSchoolId() async {
    try {
      // هنا يجب استخدام طريقة للحصول على معرف المدرسة الحالي
      // يمكن تخزينه في SharedPreferences أو الحصول عليه من المستخدم الحالي
      
      // مثال مؤقت - يجب تعديله حسب منطق التطبيق
      final response = await _supabase
          .from('schools')
          .select('id')
          .limit(1);

      if (response.isNotEmpty) {
        return response.first['id'];
      }
      return null;
    } catch (e) {
      print('❌ خطأ في الحصول على معرف المدرسة: $e');
      return null;
    }
  }

  // ===== طرق للعمل مع الـ Views =====

  // جلب جميع إحصائيات الترخيص من الـ view
  static Future<Map<String, dynamic>> getAllLicenseStats() async {
    try {
      final response = await _supabase
          .from('license_stats_view')
          .select()
          .single();

      return response;
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات الترخيص: $e');
      return {
        'total_organizations': 0,
        'active_count': 0,
        'trial_count': 0,
        'expired_count': 0,
        'devices_registered': 0,
        'recently_synced': 0,
        'avg_days_since_sync': 0.0,
      };
    }
  }

  // جلب حالة الترخيص للمؤسسة الحالية من الـ view
  static Future<Map<String, dynamic>?> getLicenseStatusView(String schoolId) async {
    try {
      final response = await _supabase
          .from('license_status_view')
          .select()
          .eq('id', schoolId)
          .single();

      return response;
    } catch (e) {
      print('❌ خطأ في جلب حالة الترخيص من الـ view: $e');
      return null;
    }
  }

  // جلب جميع حالات التراخيص من الـ view
  static Future<List<Map<String, dynamic>>> getAllLicenseStatusViews() async {
    try {
      final response = await _supabase
          .from('license_status_view')
          .select()
          .order('last_device_sync', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب جميع حالات التراخيص: $e');
      return [];
    }
  }

  // تحديث آخر وقت مزامنة للجهاز
  static Future<void> updateLastDeviceSync(String schoolId) async {
    try {
      await _supabase
          .from('educational_organizations')
          .update({
            'last_device_sync': DateTime.now().toIso8601String(),
          })
          .eq('id', schoolId);

      print('✅ تم تحديث وقت المزامنة للجهاز');
    } catch (e) {
      print('❌ خطأ في تحديث وقت المزامنة: $e');
    }
  }

  // البحث في حالات الترخيص حسب النص
  static Future<List<Map<String, dynamic>>> searchLicenseStatus(String searchText) async {
    try {
      final response = await _supabase
          .from('license_status_view')
          .select()
          .or('organization_name.ilike.%$searchText%,email.ilike.%$searchText%')
          .order('last_device_sync', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في البحث في حالات الترخيص: $e');
      return [];
    }
  }

  // ===== طرق تحديث device_fingerprint =====

  // تحديث device_fingerprint للمؤسسة
  static Future<bool> updateDeviceFingerprint(String orgId, String fingerprint) async {
    try {
      await _supabase
          .from('educational_organizations')
          .update({
            'device_fingerprint': fingerprint,
            'last_device_sync': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orgId);

      print('✅ تم تحديث device_fingerprint للمؤسسة: $orgId');
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث device_fingerprint: $e');
      return false;
    }
  }

  // تحديث activation_code للمؤسسة
  static Future<bool> updateActivationCode(String orgId, String activationCode) async {
    try {
      await _supabase
          .from('educational_organizations')
          .update({
            'activation_code': activationCode,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orgId);

      print('✅ تم تحديث activation_code للمؤسسة: $orgId');
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث activation_code: $e');
      return false;
    }
  }

  // مزامنة بيانات الجهاز (device_fingerprint + activation_code)
  static Future<Map<String, dynamic>> syncDeviceData({
    required String orgId,
    String? deviceFingerprint,
    String? activationCode,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'last_device_sync': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (deviceFingerprint != null) {
        updateData['device_fingerprint'] = deviceFingerprint;
      }

      if (activationCode != null) {
        updateData['activation_code'] = activationCode;
      }

      await _supabase
          .from('educational_organizations')
          .update(updateData)
          .eq('id', orgId);

      print('✅ تم مزامنة بيانات الجهاز للمؤسسة: $orgId');
      
      return {
        'status': 'success',
        'message': 'تم تحديث بيانات الجهاز بنجاح',
        'synced_at': DateTime.now().toIso8601String(),
        'device_fingerprint': deviceFingerprint,
        'activation_code': activationCode,
      };
    } catch (e) {
      print('❌ خطأ في مزامنة بيانات الجهاز: $e');
      return {
        'status': 'error',
        'message': 'فشل في تحديث بيانات الجهاز: $e',
      };
    }
  }

  // جلب device_fingerprint للمؤسسة
  static Future<String?> getDeviceFingerprint(String orgId) async {
    try {
      final response = await _supabase
          .from('educational_organizations')
          .select('device_fingerprint')
          .eq('id', orgId)
          .single();

      return response['device_fingerprint'] as String?;
    } catch (e) {
      print('❌ خطأ في جلب device_fingerprint: $e');
      return null;
    }
  }

  // التحقق من وجود device_fingerprint
  static Future<bool> hasDeviceFingerprint(String orgId) async {
    try {
      final fingerprint = await getDeviceFingerprint(orgId);
      return fingerprint != null && fingerprint.isNotEmpty;
    } catch (e) {
      print('❌ خطأ في التحقق من device_fingerprint: $e');
      return false;
    }
  }

  // جلب المؤسسات حسب device_fingerprint
  static Future<List<Map<String, dynamic>>> getOrganizationsByFingerprint(String fingerprint) async {
    try {
      final response = await _supabase
          .from('license_status_view')
          .select()
          .eq('device_fingerprint', fingerprint)
          .order('last_device_sync', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب المؤسسات حسب device_fingerprint: $e');
      return [];
    }
  }
}
