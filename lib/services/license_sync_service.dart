import 'package:isar/isar.dart';
import '../localdatabase/school.dart';
import '../main.dart';
import '../license_manager.dart';
import 'supabase_service.dart';

/// خدمة مزامنة معلومات الترخيص مع Supabase
class LicenseSyncService {
  
  /// تحديث معلومات الترخيص في Supabase عند تغيير حالة التفعيل
  static Future<void> syncLicenseWithSupabase() async {
    try {
      // الحصول على معلومات المدرسة المحلية
      final schools = await isar.schools.where().findAll();
      if (schools.isEmpty) {
        print('📋 لا توجد مدرسة مسجلة محلياً');
        return;
      }
      
      final school = schools.first;
      if (school.organizationId == null) {
        print('📋 المدرسة غير مرتبطة بمؤسسة في Supabase');
        return;
      }
      
      // الحصول على حالة الترخيص المحلية
      final licenseStatus = await LicenseManager.getLicenseStatus();
      String subscriptionStatus = 'trial';
      
      if (licenseStatus['isActivated']) {
        subscriptionStatus = 'active';
      } else if (licenseStatus['isTrialActive']) {
        subscriptionStatus = 'trial';
      } else {
        subscriptionStatus = 'expired';
      }
      
      print('🔄 مزامنة حالة الترخيص: $subscriptionStatus');
      
      // تحديث معلومات الترخيص في Supabase
      final success = await SupabaseService.updateOrganizationLicense(
        organizationId: school.organizationId!,
        newSubscriptionStatus: subscriptionStatus,
        updateDeviceInfo: true,
      );
      
      if (success) {
        // تحديث البيانات المحلية
        await isar.writeTxn(() async {
          school.subscriptionStatus = subscriptionStatus;
          school.lastSyncAt = DateTime.now();
          await isar.schools.put(school);
        });
        
        print('✅ تم مزامنة معلومات الترخيص مع السحابة');
      } else {
        print('⚠️ فشلت مزامنة معلومات الترخيص');
      }
    } catch (e) {
      print('❌ خطأ في مزامنة معلومات الترخيص: $e');
    }
  }

  /// التحقق من تطابق معلومات الترخيص مع السحابة
  static Future<Map<String, dynamic>?> checkLicenseSync() async {
    try {
      final schools = await isar.schools.where().findAll();
      if (schools.isEmpty || schools.first.organizationId == null) {
        print('📋 لا توجد مدرسة مرتبطة بمؤسسة');
        return null;
      }
      
      final organizationId = schools.first.organizationId!;
      print('🔍 التحقق من مزامنة الترخيص للمؤسسة: $organizationId');
      
      return await SupabaseService.getOrganizationLicenseInfo(organizationId);
    } catch (e) {
      print('❌ خطأ في التحقق من مزامنة الترخيص: $e');
      return null;
    }
  }

  /// مزامنة دورية لحالة الترخيص (يمكن استدعاؤها عند بدء التطبيق)
  static Future<void> periodicLicenseSync() async {
    try {
      print('🔄 بدء المزامنة الدورية للترخيص...');
      
      // التحقق من معلومات المزامنة
      final syncInfo = await checkLicenseSync();
      if (syncInfo == null) {
        print('📋 لا توجد معلومات مؤسسة للمزامنة');
        return;
      }
      
      final needsSync = syncInfo['needs_sync'] as bool? ?? false;
      final deviceMatches = syncInfo['device_matches'] as bool? ?? false;
      
      if (needsSync || !deviceMatches) {
        print('🔄 الجهاز تغير أو يحتاج مزامنة - تحديث المعلومات...');
        await syncLicenseWithSupabase();
      } else {
        print('✅ معلومات الترخيص متزامنة');
      }
      
      // طباعة تقرير مفصل
      print('📊 تقرير المزامنة:');
      print('  - تطابق الجهاز: ${deviceMatches ? "✅" : "❌"}');
      print('  - يحتاج مزامنة: ${needsSync ? "⚠️" : "✅"}');
      
      final orgInfo = syncInfo['organization_info'] as Map<String, dynamic>?;
      if (orgInfo != null) {
        print('  - حالة الاشتراك في السحابة: ${orgInfo['subscription_status']}');
      }
      
      final localStatus = syncInfo['local_license_status'] as Map<String, dynamic>?;
      if (localStatus != null) {
        print('  - حالة الترخيص المحلية: ${localStatus['status']}');
      }
      
    } catch (e) {
      print('❌ خطأ في المزامنة الدورية: $e');
    }
  }

  /// إظهار تقرير تفصيلي عن حالة المزامنة
  static Future<Map<String, dynamic>> getLicenseSyncReport() async {
    try {
      final syncInfo = await checkLicenseSync();
      if (syncInfo == null) {
        return {
          'status': 'no_organization',
          'message': 'لا توجد مؤسسة مرتبطة',
          'details': {},
        };
      }
      
      final deviceMatches = syncInfo['device_matches'] as bool? ?? false;
      final needsSync = syncInfo['needs_sync'] as bool? ?? false;
      final orgInfo = syncInfo['organization_info'] as Map<String, dynamic>?;
      final localStatus = syncInfo['local_license_status'] as Map<String, dynamic>?;
      
      String status = 'synced';
      String message = 'معلومات الترخيص متزامنة';
      
      if (!deviceMatches) {
        status = 'device_mismatch';
        message = 'بصمة الجهاز لا تتطابق مع السحابة';
      } else if (needsSync) {
        status = 'needs_sync';
        message = 'يحتاج مزامنة';
      }
      
      return {
        'status': status,
        'message': message,
        'device_matches': deviceMatches,
        'needs_sync': needsSync,
        'cloud_subscription_status': orgInfo?['subscription_status'],
        'local_license_status': localStatus?['status'],
        'trial_expires_at': orgInfo?['trial_expires_at'],
        'last_device_sync': orgInfo?['last_device_sync'],
        'details': syncInfo,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'خطأ في الحصول على تقرير المزامنة: $e',
        'details': {},
      };
    }
  }
}
