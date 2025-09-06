import 'package:isar/isar.dart';
import '../localdatabase/license_status_view.dart';
import '../localdatabase/license_stats_view.dart';
import '../localdatabase/student.dart';
import '../localdatabase/class.dart';
import '../localdatabase/user.dart';
import '../main.dart';
import '../license_manager.dart';
import 'supabase_license_service.dart';

class LicenseDatabaseService {
  
  // تحديث جدول حالة الترخيص
  static Future<void> updateLicenseStatus() async {
    try {
      final licenseStatus = await LicenseManager.getLicenseStatus();
      
      // حذف البيانات القديمة
      await isar.writeTxn(() async {
        await isar.licenseStatusViews.clear();
      });
      
      // إضافة البيانات الجديدة
      final statusView = LicenseStatusView(
        status: licenseStatus['status'] ?? 'unknown',
        isActivated: licenseStatus['isActivated'] ?? false,
        isTrialActive: licenseStatus['isTrialActive'] ?? false,
        remainingDays: licenseStatus['remainingDays'] ?? 0,
        lastUpdated: DateTime.now(),
        licenseKey: licenseStatus['licenseKey'],
        activationDate: licenseStatus['activationDate'],
        
        expiryDate: licenseStatus['expiryDate'],
      );
      
      await isar.writeTxn(() async {
        await isar.licenseStatusViews.put(statusView);
      });
      
      print('✅ تم تحديث جدول license_status_view بنجاح');
      
    } catch (e) {
      print('❌ خطأ في تحديث license_status_view: $e');
    }
  }
  
  // تحديث جدول إحصائيات الترخيص
  static Future<void> updateLicenseStats() async {
    try {
      // جلب الإحصائيات الحالية
      final students = await isar.students.where().findAll();
      final classes = await isar.schoolClass.where().findAll();
      final users = await isar.users.where().findAll();
      
      // تحديد نوع الترخيص
      final licenseStatus = await LicenseManager.getLicenseStatus();
      String licenseType = 'trial';
      if (licenseStatus['isActivated'] == true) {
        licenseType = 'premium';
      } else if (licenseStatus['isTrialActive'] == false) {
        licenseType = 'expired';
      }
      
      // حذف البيانات القديمة
      await isar.writeTxn(() async {
        await isar.licenseStatsViews.clear();
      });
      
      // إضافة البيانات الجديدة
      final statsView = LicenseStatsView(
        totalStudents: students.length,
        totalClasses: classes.length,
        totalUsers: users.length,
        totalPayments: 0, // يمكنك إضافة منطق حساب المدفوعات هنا
        lastCalculated: DateTime.now(),
        licenseType: licenseType,
      );
      
      await isar.writeTxn(() async {
        await isar.licenseStatsViews.put(statsView);
      });
      
      print('✅ تم تحديث جدول license_stats_view بنجاح');
      
    } catch (e) {
      print('❌ خطأ في تحديث license_stats_view: $e');
    }
  }
  
  // تحديث كلا الجدولين معاً
  static Future<void> updateAllLicenseViews() async {
    await updateLicenseStatus();
    await updateLicenseStats();
    
    // محاولة المزامنة مع Supabase إذا كان الإنترنت متاحاً
    await _syncWithSupabaseIfPossible();
  }
  
  // المزامنة مع Supabase إذا كان الإنترنت متاحاً
  static Future<void> _syncWithSupabaseIfPossible() async {
    try {
      final schoolId = await SupabaseLicenseService.getCurrentSchoolId();
      if (schoolId == null) {
        print('⚠️ لم يتم العثور على معرف المدرسة للمزامنة مع Supabase');
        return;
      }

      // فحص الاتصال
      final isConnected = await SupabaseLicenseService.syncWithSupabase(schoolId);
      if (!isConnected) {
        print('⚠️ لا يوجد اتصال بالإنترنت - تم تخطي المزامنة مع Supabase');
        return;
      }

      // جلب البيانات المحلية
      final licenseStatus = await LicenseManager.getLicenseStatus();
      final students = await isar.students.where().findAll();
      final classes = await isar.schoolClass.where().findAll();
      final users = await isar.users.where().findAll();

      // المزامنة مع Supabase
      await SupabaseLicenseService.updateAllLicenseDataInSupabase(
        schoolId: schoolId,
        licenseStatus: licenseStatus,
        totalStudents: students.length,
        totalClasses: classes.length,
        totalUsers: users.length,
        totalPayments: 0, // يمكن إضافة منطق حساب المدفوعات
      );

      print('✅ تمت المزامنة مع Supabase بنجاح');
    } catch (e) {
      print('❌ خطأ في المزامنة مع Supabase: $e');
      // لا نرمي خطأ هنا لأن الفشل في المزامنة لا يجب أن يوقف التطبيق
    }
  }
  
  // جلب حالة الترخيص من قاعدة البيانات
  static Future<LicenseStatusView?> getLicenseStatusFromDB() async {
    return await isar.licenseStatusViews.where().findFirst();
  }
  
  // جلب إحصائيات الترخيص من قاعدة البيانات
  static Future<LicenseStatsView?> getLicenseStatsFromDB() async {
    return await isar.licenseStatsViews.where().findFirst();
  }
}
