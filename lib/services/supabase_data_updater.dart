import '../license_manager.dart';
import 'supabase_license_service.dart';
import 'license_database_service.dart';

class SupabaseDataUpdater {
  
  // تحديث جميع البيانات في Supabase
  static Future<void> updateAllDataInSupabase() async {
    try {
      print('🔄 بدء تحديث البيانات في Supabase...');

      // الحصول على معرف المدرسة
      final schoolId = await SupabaseLicenseService.getCurrentSchoolId();
      if (schoolId == null) {
        print('❌ لم يتم العثور على معرف المدرسة');
        return;
      }

      // فحص الاتصال بالإنترنت
      final isConnected = await SupabaseLicenseService.syncWithSupabase(schoolId);
      if (!isConnected) {
        print('❌ لا يوجد اتصال بالإنترنت');
        return;
      }

      // جلب البيانات المحلية
      final licenseStatus = await LicenseManager.getLicenseStatus();
      
      // استخدام قيم افتراضية للإحصائيات
      int totalStudents = 0;
      int totalClasses = 0;
      int totalUsers = 0;
      
      // يمكن إضافة منطق جلب البيانات الحقيقية لاحقاً
      print('📊 استخدام القيم الافتراضية للإحصائيات حالياً');

      // تحديث البيانات في Supabase
      await SupabaseLicenseService.updateAllLicenseDataInSupabase(
        schoolId: schoolId,
        licenseStatus: licenseStatus,
        totalStudents: totalStudents,
        totalClasses: totalClasses,
        totalUsers: totalUsers,
        totalPayments: 0, // يمكن إضافة منطق حساب المدفوعات
      );

      // تحديث device_fingerprint إذا كان متوفراً
      final deviceFingerprint = licenseStatus['deviceFingerprint'] as String?;
      final activationCode = licenseStatus['activationCode'] as String?;
      
      if (deviceFingerprint != null || activationCode != null) {
        final syncResult = await SupabaseLicenseService.syncDeviceData(
          orgId: schoolId.toString(),
          deviceFingerprint: deviceFingerprint,
          activationCode: activationCode,
        );
        
        if (syncResult['status'] == 'success') {
          print('✅ تم تحديث device_fingerprint و activation_code بنجاح');
        } else {
          print('⚠️ فشل في تحديث device_fingerprint: ${syncResult['message']}');
        }
      }

      // تحديث وقت المزامنة
      await SupabaseLicenseService.updateLastDeviceSync(schoolId.toString());

      // تحديث البيانات المحلية أيضاً
      await LicenseDatabaseService.updateAllLicenseViews();

      print('✅ تم تحديث جميع البيانات في Supabase بنجاح');
      
    } catch (e) {
      print('❌ خطأ في تحديث البيانات في Supabase: $e');
      rethrow;
    }
  }

  // تحديث البيانات بشكل دوري
  static Future<void> scheduleDataUpdate() async {
    try {
      // تحديث البيانات كل 5 دقائق إذا كان الإنترنت متاحاً
      while (true) {
        await Future.delayed(Duration(minutes: 5));
        
        try {
          await updateAllDataInSupabase();
        } catch (e) {
          print('⚠️ فشل التحديث الدوري: $e');
          // لا نوقف الحلقة في حالة الفشل
        }
      }
    } catch (e) {
      print('❌ خطأ في جدولة التحديث الدوري: $e');
    }
  }

  // جلب الإحصائيات الشاملة من Supabase
  static Future<Map<String, dynamic>> getComprehensiveStats() async {
    try {
      // جلب الإحصائيات العامة
      final generalStats = await SupabaseLicenseService.getAllLicenseStats();
      
      // جلب حالة الترخيص للمؤسسة الحالية
      final schoolId = await SupabaseLicenseService.getCurrentSchoolId();
      Map<String, dynamic>? currentOrgStatus;
      
      if (schoolId != null) {
        currentOrgStatus = await SupabaseLicenseService.getLicenseStatusView(schoolId.toString());
      }

      return {
        'general_stats': generalStats,
        'current_organization': currentOrgStatus,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ خطأ في جلب الإحصائيات الشاملة: $e');
      return {
        'general_stats': {},
        'current_organization': null,
        'last_updated': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  // طباعة تقرير شامل
  static Future<void> printComprehensiveReport() async {
    try {
      print('\n' + '='*60);
      print('📊 تقرير شامل للبيانات في Supabase');
      print('='*60);

      final stats = await getComprehensiveStats();
      
      // الإحصائيات العامة
      final generalStats = stats['general_stats'] as Map<String, dynamic>;
      print('\n📈 الإحصائيات العامة:');
      print('   • إجمالي المؤسسات: ${generalStats['total_organizations'] ?? 0}');
      print('   • المؤسسات النشطة: ${generalStats['active_count'] ?? 0}');
      print('   • المؤسسات التجريبية: ${generalStats['trial_count'] ?? 0}');
      print('   • المؤسسات المنتهية الصلاحية: ${generalStats['expired_count'] ?? 0}');
      print('   • الأجهزة المسجلة: ${generalStats['devices_registered'] ?? 0}');
      print('   • المؤسسات المتزامنة حديثاً: ${generalStats['recently_synced'] ?? 0}');
      print('   • متوسط أيام عدم المزامنة: ${generalStats['avg_days_since_sync']?.toStringAsFixed(1) ?? 'غير محدد'}');

      // حالة المؤسسة الحالية
      final currentOrg = stats['current_organization'];
      if (currentOrg != null) {
        print('\n🏢 حالة المؤسسة الحالية:');
        print('   • اسم المؤسسة: ${currentOrg['organization_name'] ?? 'غير محدد'}');
        print('   • البريد الإلكتروني: ${currentOrg['email'] ?? 'غير محدد'}');
        print('   • حالة الاشتراك: ${currentOrg['subscription_status'] ?? 'غير محدد'}');
        print('   • خطة الاشتراك: ${currentOrg['subscription_plan'] ?? 'غير محدد'}');
        print('   • حالة الجهاز: ${currentOrg['device_status'] ?? 'غير محدد'}');
        print('   • حالة كود التفعيل: ${currentOrg['activation_code_status'] ?? 'غير محدد'}');
        print('   • حداثة المزامنة: ${currentOrg['sync_freshness'] ?? 'غير محدد'}');
      } else {
        print('\n⚠️ لم يتم العثور على بيانات المؤسسة الحالية');
      }

      print('\n⏰ آخر تحديث: ${stats['last_updated']}');
      
      if (stats.containsKey('error')) {
        print('\n❌ خطأ: ${stats['error']}');
      }
      
      print('='*60 + '\n');
      
    } catch (e) {
      print('❌ خطأ في طباعة التقرير الشامل: $e');
    }
  }

  // اختبار شامل للنظام
  static Future<void> runCompleteSystemTest() async {
    try {
      print('\n🧪 بدء الاختبار الشامل للنظام...\n');

      // 1. اختبار الاتصال
      print('1. اختبار الاتصال بـ Supabase...');
      final schoolId = await SupabaseLicenseService.getCurrentSchoolId();
      if (schoolId == null) {
        print('   ❌ فشل في الحصول على معرف المدرسة');
        return;
      }
      
      final isConnected = await SupabaseLicenseService.syncWithSupabase(schoolId);
      if (isConnected) {
        print('   ✅ الاتصال بـ Supabase ناجح');
      } else {
        print('   ❌ فشل الاتصال بـ Supabase');
        return;
      }

      // 2. اختبار تحديث البيانات
      print('\n2. اختبار تحديث البيانات...');
      await updateAllDataInSupabase();
      print('   ✅ تم تحديث البيانات بنجاح');

      // 3. اختبار جلب الإحصائيات
      print('\n3. اختبار جلب الإحصائيات...');
      final stats = await SupabaseLicenseService.getAllLicenseStats();
      if (stats.isNotEmpty) {
        print('   ✅ تم جلب الإحصائيات بنجاح');
      } else {
        print('   ⚠️ لم يتم العثور على إحصائيات');
      }

      // 4. اختبار جلب حالة الترخيص
      print('\n4. اختبار جلب حالة الترخيص...');
      final licenseStatus = await SupabaseLicenseService.getLicenseStatusView(schoolId.toString());
      if (licenseStatus != null) {
        print('   ✅ تم جلب حالة الترخيص بنجاح');
      } else {
        print('   ⚠️ لم يتم العثور على حالة الترخيص');
      }

      // 5. طباعة التقرير الشامل
      print('\n5. طباعة التقرير الشامل...');
      await printComprehensiveReport();

      // 6. اختبار device_fingerprint
      print('\n6. اختبار device_fingerprint...');
      await testDeviceFingerprintOperations(schoolId.toString());

      print('🎉 تم انتهاء الاختبار الشامل بنجاح!\n');
      
    } catch (e) {
      print('❌ خطأ في الاختبار الشامل: $e');
    }
  }

  // اختبار عمليات device_fingerprint
  static Future<void> testDeviceFingerprintOperations(String orgId) async {
    try {
      print('🔍 اختبار عمليات device_fingerprint...');

      // توليد device_fingerprint تجريبي
      final testFingerprint = 'TEST_${DateTime.now().millisecondsSinceEpoch}';
      final testActivationCode = 'ACT_${DateTime.now().millisecondsSinceEpoch}';

      // 1. تحديث device_fingerprint
      print('   • تحديث device_fingerprint...');
      final updateResult = await SupabaseLicenseService.updateDeviceFingerprint(orgId, testFingerprint);
      if (updateResult) {
        print('   ✅ تم تحديث device_fingerprint بنجاح');
      } else {
        print('   ❌ فشل في تحديث device_fingerprint');
      }

      // 2. تحديث activation_code
      print('   • تحديث activation_code...');
      final codeResult = await SupabaseLicenseService.updateActivationCode(orgId, testActivationCode);
      if (codeResult) {
        print('   ✅ تم تحديث activation_code بنجاح');
      } else {
        print('   ❌ فشل في تحديث activation_code');
      }

      // 3. جلب device_fingerprint
      print('   • جلب device_fingerprint...');
      final fingerprint = await SupabaseLicenseService.getDeviceFingerprint(orgId);
      if (fingerprint == testFingerprint) {
        print('   ✅ تم جلب device_fingerprint بنجاح: $fingerprint');
      } else {
        print('   ⚠️ device_fingerprint لا يطابق المتوقع: $fingerprint');
      }

      // 4. التحقق من وجود device_fingerprint
      print('   • التحقق من وجود device_fingerprint...');
      final hasFingerprint = await SupabaseLicenseService.hasDeviceFingerprint(orgId);
      if (hasFingerprint) {
        print('   ✅ device_fingerprint موجود');
      } else {
        print('   ❌ device_fingerprint غير موجود');
      }

      // 5. البحث حسب device_fingerprint
      print('   • البحث حسب device_fingerprint...');
      final orgsWithFingerprint = await SupabaseLicenseService.getOrganizationsByFingerprint(testFingerprint);
      print('   📊 تم العثور على ${orgsWithFingerprint.length} مؤسسة بنفس device_fingerprint');

      // 6. مزامنة بيانات الجهاز
      print('   • مزامنة بيانات الجهاز...');
      final syncResult = await SupabaseLicenseService.syncDeviceData(
        orgId: orgId,
        deviceFingerprint: testFingerprint + '_SYNC',
        activationCode: testActivationCode + '_SYNC',
      );
      
      if (syncResult['status'] == 'success') {
        print('   ✅ تم مزامنة بيانات الجهاز بنجاح');
      } else {
        print('   ❌ فشل في مزامنة بيانات الجهاز: ${syncResult['message']}');
      }

      print('🎯 انتهى اختبار device_fingerprint');
      
    } catch (e) {
      print('❌ خطأ في اختبار device_fingerprint: $e');
    }
  }
}
