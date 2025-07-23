/// مثال على كيفية استخدام خدمة مزامنة الترخيص مع Supabase
/// 
/// هذا الملف يحتوي على أمثلة عملية لاستخدام LicenseSyncService
/// في أجزاء مختلفة من التطبيق

import 'package:flutter/material.dart';
import 'license_sync_service.dart';
import '../license_manager.dart';

class LicenseSyncExamples {
  
  /// مثال 1: مزامنة الترخيص عند بدء التطبيق
  /// يجب استدعاؤها في main.dart بعد تهيئة قاعدة البيانات
  static Future<void> initializeAppLicenseSync() async {
    print('🚀 بدء مزامنة الترخيص عند تشغيل التطبيق...');
    
    try {
      // مزامنة دورية عند بدء التطبيق
      await LicenseSyncService.periodicLicenseSync();
      
      // الحصول على تقرير المزامنة
      final report = await LicenseSyncService.getLicenseSyncReport();
      print('📊 تقرير المزامنة: ${report['message']}');
      
    } catch (e) {
      print('❌ خطأ في مزامنة الترخيص عند بدء التطبيق: $e');
    }
  }
  
  /// مثال 2: مزامنة الترخيص بعد تفعيل التطبيق
  /// يجب استدعاؤها في ActivationScreen بعد تفعيل التطبيق بنجاح
  static Future<void> syncAfterActivation() async {
    print('🔑 مزامنة الترخيص بعد التفعيل...');
    
    try {
      // التحقق من نجاح التفعيل محلياً
      final isActivated = await LicenseManager.verifyLicense();
      if (!isActivated) {
        print('⚠️ التفعيل المحلي غير مؤكد');
        return;
      }
      
      // مزامنة معلومات التفعيل مع السحابة
      await LicenseSyncService.syncLicenseWithSupabase();
      
      print('✅ تم مزامنة التفعيل مع السحابة');
      
    } catch (e) {
      print('❌ خطأ في مزامنة التفعيل: $e');
    }
  }
  
  /// مثال 3: فحص حالة المزامنة في شاشة الإعدادات
  /// يمكن استخدامها في شاشة الإعدادات لإظهار حالة الترخيص
  static Future<Widget> buildLicenseStatusWidget() async {
    try {
      final report = await LicenseSyncService.getLicenseSyncReport();
      
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(report['status']),
                    color: _getStatusColor(report['status']),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'حالة مزامنة الترخيص',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                report['message'] ?? 'غير محدد',
                style: TextStyle(fontSize: 14),
              ),
              if (report['cloud_subscription_status'] != null) ...[
                SizedBox(height: 8),
                Text(
                  'حالة الاشتراك في السحابة: ${report['cloud_subscription_status']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              if (report['local_license_status'] != null) ...[
                SizedBox(height: 4),
                Text(
                  'حالة الترخيص المحلية: ${report['local_license_status']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              if (report['status'] == 'device_mismatch' || report['needs_sync']) ...[
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await LicenseSyncService.syncLicenseWithSupabase();
                  },
                  icon: Icon(Icons.sync),
                  label: Text('مزامنة الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
      
    } catch (e) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(height: 8),
              Text('خطأ في الحصول على حالة المزامنة'),
              Text(
                e.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  /// مثال 4: مزامنة دورية في الخلفية
  /// يمكن استدعاؤها كل فترة معينة للتأكد من المزامنة
  static Future<void> scheduledLicenseSync() async {
    print('⏰ مزامنة دورية مجدولة...');
    
    try {
      // التحقق من الحاجة للمزامنة أولاً
      final report = await LicenseSyncService.getLicenseSyncReport();
      
      if (report['status'] == 'synced') {
        print('✅ الترخيص متزامن - لا حاجة لمزامنة');
        return;
      }
      
      // إجراء المزامنة إذا احتاج الأمر
      await LicenseSyncService.syncLicenseWithSupabase();
      
    } catch (e) {
      print('❌ خطأ في المزامنة المجدولة: $e');
    }
  }
  
  /// دوال مساعدة للواجهة
  static IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'synced':
        return Icons.check_circle;
      case 'needs_sync':
        return Icons.sync_problem;
      case 'device_mismatch':
        return Icons.warning;
      case 'no_organization':
        return Icons.cloud_off;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
  
  static Color _getStatusColor(String? status) {
    switch (status) {
      case 'synced':
        return Colors.green;
      case 'needs_sync':
        return Colors.orange;
      case 'device_mismatch':
        return Colors.amber;
      case 'no_organization':
        return Colors.grey;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// مثال للاستخدام في main.dart:
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // تهيئة قاعدة البيانات
///   await initializeDatabase();
///   
///   // مزامنة الترخيص عند بدء التطبيق
///   await LicenseSyncExamples.initializeAppLicenseSync();
///   
///   runApp(MyApp());
/// }

/// مثال للاستخدام في ActivationScreen:
/// 
/// Future<void> activateWithCode(String code) async {
///   final success = await LicenseManager.activateWithCode(code);
///   if (success) {
///     // مزامنة التفعيل مع السحابة
///     await LicenseSyncExamples.syncAfterActivation();
///     
///     // الانتقال للشاشة الرئيسية
///     Navigator.pushReplacement(context, ...);
///   }
/// }

/// مثال للاستخدام في شاشة الإعدادات:
/// 
/// class SettingsScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('الإعدادات')),
///       body: Column(
///         children: [
///           // ... باقي عناصر الإعدادات
///           
///           FutureBuilder<Widget>(
///             future: LicenseSyncExamples.buildLicenseStatusWidget(),
///             builder: (context, snapshot) {
///               if (snapshot.hasData) {
///                 return snapshot.data!;
///               }
///               return CircularProgressIndicator();
///             },
///           ),
///         ],
///       ),
///     );
///   }
/// }
