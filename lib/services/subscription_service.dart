import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../localdatabase/school.dart';
import '../main.dart';
import 'supabase_service.dart';

class SubscriptionService {
  static const String REPORTS_SYNC_FEATURE = 'reports_sync';
  static const double MONTHLY_REPORTS_PRICE = 50.0; //15000 د ع شهرياً
  
  /// فحص حالة اشتراك مزامنة التقارير
  static Future<SubscriptionStatus> getReportsSyncStatus() async {
    try {
      final school = await isar.schools.where().findFirst();
      if (school == null) {
        return SubscriptionStatus(
          isActive: false,
          feature: REPORTS_SYNC_FEATURE,
          message: 'لم يتم العثور على بيانات المدرسة',
        );
      }

      // فحص حالة الاشتراك من قاعدة البيانات المحلية
      final localStatus = _checkLocalSubscription(school);
      
      // مزامنة مع Supabase إذا كان متاحاً
      if (school.syncedWithSupabase == true && school.organizationId != null) {
        try {
          final onlineStatus = await _checkOnlineSubscription(school.organizationId!);
          if (onlineStatus != null) {
            // تحديث البيانات المحلية بناءً على البيانات الأونلاين
            await _updateLocalSubscription(school, onlineStatus);
            return onlineStatus;
          }
        } catch (e) {
          debugPrint('فشل في فحص الاشتراك الأونلاين: $e');
        }
      }

      return localStatus;
    } catch (e) {
      debugPrint('خطأ في فحص حالة الاشتراك: $e');
      return SubscriptionStatus(
        isActive: false,
        feature: REPORTS_SYNC_FEATURE,
        message: 'خطأ في فحص حالة الاشتراك: $e',
      );
    }
  }

  /// تفعيل اشتراك مزامنة التقارير
  static Future<SubscriptionResult> activateReportsSync({
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final school = await isar.schools.where().findFirst();
      if (school == null) {
        return SubscriptionResult(
          success: false,
          message: 'لم يتم العثور على بيانات المدرسة',
        );
      }

      final activationDate = DateTime.now();
      final expiryDate = DateTime.now().add(const Duration(days: 30));

      // إنشاء سجل اشتراك جديد
      final subscriptionData = {
        'feature': REPORTS_SYNC_FEATURE,
        'activation_date': activationDate.toIso8601String(),
        'expiry_date': expiryDate.toIso8601String(),
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'amount_paid': MONTHLY_REPORTS_PRICE,
        'status': 'active',
        'payment_details': paymentDetails != null ? jsonEncode(paymentDetails) : null,
      };

      // حفظ في Supabase إذا كان متاحاً
      if (school.syncedWithSupabase == true && school.organizationId != null) {
        try {
          await SupabaseService.createSubscription(
            organizationId: school.organizationId!,
            subscriptionData: subscriptionData,
          );
        } catch (e) {
          debugPrint('فشل في حفظ الاشتراك في Supabase: $e');
          // يمكن المتابعة والحفظ محلياً فقط
        }
      }

      // حفظ محلياً
      await isar.writeTxn(() async {
        school.reportsSyncSubscription = jsonEncode(subscriptionData);
        school.reportsSyncActive = true;
        school.reportsSyncExpiryDate = expiryDate;
        await isar.schools.put(school);
      });

      return SubscriptionResult(
        success: true,
        message: 'تم تفعيل اشتراك مزامنة التقارير بنجاح',
        subscriptionData: subscriptionData,
      );
    } catch (e) {
      debugPrint('خطأ في تفعيل الاشتراك: $e');
      return SubscriptionResult(
        success: false,
        message: 'فشل في تفعيل الاشتراك: $e',
      );
    }
  }

  /// إلغاء اشتراك مزامنة التقارير
  static Future<bool> cancelReportsSync() async {
    try {
      final school = await isar.schools.where().findFirst();
      if (school == null) return false;

      // إلغاء في Supabase إذا كان متاحاً
      if (school.syncedWithSupabase == true && school.organizationId != null) {
        try {
          await SupabaseService.cancelSubscription(
            organizationId: school.organizationId!,
            feature: REPORTS_SYNC_FEATURE,
          );
        } catch (e) {
          debugPrint('فشل في إلغاء الاشتراك في Supabase: $e');
        }
      }

      // إلغاء محلياً
      await isar.writeTxn(() async {
        school.reportsSyncSubscription = null;
        school.reportsSyncActive = false;
        school.reportsSyncExpiryDate = null;
        await isar.schools.put(school);
      });

      return true;
    } catch (e) {
      debugPrint('خطأ في إلغاء الاشتراك: $e');
      return false;
    }
  }

  /// تجديد اشتراك مزامنة التقارير
  static Future<SubscriptionResult> renewReportsSync({
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    // إلغاء الاشتراك الحالي أولاً
    await cancelReportsSync();
    
    // تفعيل اشتراك جديد
    return await activateReportsSync(
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paymentDetails: paymentDetails,
    );
  }

  /// فحص انتهاء الاشتراكات وإلغاء المنتهية
  static Future<void> checkExpiredSubscriptions() async {
    try {
      final school = await isar.schools.where().findFirst();
      if (school == null) return;

      final now = DateTime.now();
      bool needsUpdate = false;

      // فحص اشتراك مزامنة التقارير
      if (school.reportsSyncActive == true && 
          school.reportsSyncExpiryDate != null &&
          school.reportsSyncExpiryDate!.isBefore(now)) {
        
        debugPrint('انتهى اشتراك مزامنة التقارير');
        school.reportsSyncActive = false;
        needsUpdate = true;
      }

      if (needsUpdate) {
        await isar.writeTxn(() async {
          await isar.schools.put(school);
        });
      }
    } catch (e) {
      debugPrint('خطأ في فحص الاشتراكات المنتهية: $e');
    }
  }

  /// الحصول على معلومات تفصيلية عن جميع الاشتراكات
  static Future<Map<String, dynamic>> getSubscriptionsInfo() async {
    try {
      final school = await isar.schools.where().findFirst();
      if (school == null) {
        return {'error': 'لم يتم العثور على بيانات المدرسة'};
      }

      final reportsStatus = await getReportsSyncStatus();
      
      return {
        'school_name': school.name,
        'organization_id': school.organizationId,
        'reports_sync': {
          'active': reportsStatus.isActive,
          'expiry_date': school.reportsSyncExpiryDate?.toIso8601String(),
          'days_remaining': reportsStatus.daysRemaining,
          'price_per_month': MONTHLY_REPORTS_PRICE,
          'status_message': reportsStatus.message,
        },
        'basic_features': {
          'active': true,
          'included': [
            'إدارة الطلاب والمعلمين',
            'الدرجات والحضور',
            'التقارير المحلية',
            'النسخ الاحتياطي المحلي',
          ]
        }
      };
    } catch (e) {
      return {'error': 'خطأ في الحصول على معلومات الاشتراكات: $e'};
    }
  }

  // دوال مساعدة خاصة
  static SubscriptionStatus _checkLocalSubscription(School school) {
    if (school.reportsSyncActive != true) {
      return SubscriptionStatus(
        isActive: false,
        feature: REPORTS_SYNC_FEATURE,
        message: 'اشتراك مزامنة التقارير غير مفعل',
      );
    }

    if (school.reportsSyncExpiryDate == null) {
      return SubscriptionStatus(
        isActive: false,
        feature: REPORTS_SYNC_FEATURE,
        message: 'تاريخ انتهاء الاشتراك غير محدد',
      );
    }

    final now = DateTime.now();
    final expiryDate = school.reportsSyncExpiryDate!;
    final daysRemaining = expiryDate.difference(now).inDays;

    if (expiryDate.isBefore(now)) {
      return SubscriptionStatus(
        isActive: false,
        feature: REPORTS_SYNC_FEATURE,
        message: 'انتهى اشتراك مزامنة التقارير',
        expiryDate: expiryDate,
      );
    }

    return SubscriptionStatus(
      isActive: true,
      feature: REPORTS_SYNC_FEATURE,
      message: daysRemaining > 7 
          ? 'اشتراك مزامنة التقارير نشط'
          : 'سينتهي اشتراك مزامنة التقارير خلال $daysRemaining أيام',
      expiryDate: expiryDate,
      daysRemaining: daysRemaining,
    );
  }

  static Future<SubscriptionStatus?> _checkOnlineSubscription(int organizationId) async {
    try {
      final result = await SupabaseService.getSubscriptionStatus(
        organizationId: organizationId,
        feature: REPORTS_SYNC_FEATURE,
      );
      
      if (result == null) return null;
      
      return SubscriptionStatus(
        isActive: result['is_active'] ?? false,
        feature: REPORTS_SYNC_FEATURE,
        message: result['message'] ?? '',
        expiryDate: result['expiry_date'] != null 
            ? DateTime.parse(result['expiry_date'])
            : null,
        daysRemaining: result['days_remaining'],
      );
    } catch (e) {
      debugPrint('خطأ في فحص الاشتراك الأونلاين: $e');
      return null;
    }
  }

  static Future<void> _updateLocalSubscription(School school, SubscriptionStatus status) async {
    await isar.writeTxn(() async {
      school.reportsSyncActive = status.isActive;
      school.reportsSyncExpiryDate = status.expiryDate;
      await isar.schools.put(school);
    });
  }
}

// نماذج البيانات
class SubscriptionStatus {
  final bool isActive;
  final String feature;
  final String message;
  final DateTime? expiryDate;
  final int? daysRemaining;

  SubscriptionStatus({
    required this.isActive,
    required this.feature,
    required this.message,
    this.expiryDate,
    this.daysRemaining,
  });
}

class SubscriptionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? subscriptionData;

  SubscriptionResult({
    required this.success,
    required this.message,
    this.subscriptionData,
  });
}
