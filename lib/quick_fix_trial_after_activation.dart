// quick_fix_trial_after_activation.dart
// ملف إصلاح سريع لحذف الفترة التجريبية بعد التفعيل

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'license_manager.dart';

class QuickFixLicense {
  
  // إصلاح سريع لحذف الفترة التجريبية إذا كان التطبيق مُفعَّل
  static Future<void> fixTrialIssue() async {
    print('🔧 بدء إصلاح مشكلة الفترة التجريبية...');
    
    try {
      // التحقق من حالة الترخيص
      final status = await LicenseManager.getLicenseStatus();
      
      print('📊 حالة الترخيص الحالية:');
      status.forEach((key, value) {
        print('   $key: $value');
      });
      
      // إذا كان التطبيق مُفعَّل والفترة التجريبية موجودة
      if (status['isActivated'] == true && status['trialExists'] == true) {
        print('⚠️  تم اكتشاف مشكلة: التطبيق مُفعَّل لكن الفترة التجريبية ما زالت موجودة');
        
        final deleted = await LicenseManager.deleteTrialFile();
        if (deleted) {
          print('✅ تم حل المشكلة: حُذفت الفترة التجريبية بنجاح');
        } else {
          print('❌ فشل في حذف ملف الفترة التجريبية');
        }
        
        // التحقق مرة أخرى
        final newStatus = await LicenseManager.getLicenseStatus();
        print('📊 حالة الترخيص بعد الإصلاح:');
        newStatus.forEach((key, value) {
          print('   $key: $value');
        });
        
      } else if (status['isActivated'] == true) {
        print('✅ التطبيق مُفعَّل ولا توجد مشكلة في الفترة التجريبية');
      } else {
        print('ℹ️  التطبيق غير مُفعَّل - لا حاجة لإصلاح');
      }
      
    } catch (e) {
      print('❌ خطأ في الإصلاح: $e');
    }
  }
  
  // دالة للتحقق الشامل من النظام
  static Future<void> fullSystemCheck() async {
    print('🔍 فحص شامل لنظام الترخيص...');
    
    try {
      // فحص وجود الملفات
      final licenseExists = await _checkFileExists('license.key');
      final trialExists = await _checkFileExists('trial.key');
      
      print('📁 حالة الملفات:');
      print('   ملف الترخيص: ${licenseExists ? "موجود" : "غير موجود"}');
      print('   ملف الفترة التجريبية: ${trialExists ? "موجود" : "غير موجود"}');
      
      // فحص صحة الترخيص
      if (licenseExists) {
        final isValidLicense = await LicenseManager.verifyLicense();
        print('   صحة الترخيص: ${isValidLicense ? "صالح" : "غير صالح"}');
      }
      
      // فحص صحة الفترة التجريبية
      if (trialExists) {
        final isValidTrial = await LicenseManager.isTrialValid();
        final remainingDays = await LicenseManager.getRemainingTrialDays();
        print('   صحة الفترة التجريبية: ${isValidTrial ? "صالحة" : "منتهية"}');
        print('   الأيام المتبقية: $remainingDays');
      }
      
      // الحالة النهائية
      final status = await LicenseManager.getLicenseStatus();
      print('🎯 الحالة النهائية: ${status['status']}');
      
    } catch (e) {
      print('❌ خطأ في الفحص الشامل: $e');
    }
  }
  
  // دالة مساعدة للتحقق من وجود ملف
  static Future<bool> _checkFileExists(String fileName) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final path = '${dir.path}/$fileName';
      return File(path).exists();
    } catch (e) {
      return false;
    }
  }
}

// ملاحظة: لتشغيل الإصلاح السريع، استخدم:
// await QuickFixLicense.fixTrialIssue();

// للفحص الشامل، استخدم:
// await QuickFixLicense.fullSystemCheck();
