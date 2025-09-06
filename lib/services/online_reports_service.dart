// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'package:school_app_flutter/services/supabase_service.dart';
// import 'package:school_app_flutter/localdatabase/school.dart';
// import '../main.dart';

// class OnlineReportsService {
//   // أنواع خطط الاشتراك
//   static const String FREE_PLAN = 'free';
//   static const String BASIC_PLAN = 'basic';  
//   static const String PREMIUM_PLAN = 'premium';
//   static const String ENTERPRISE_PLAN = 'enterprise';
  
//   // حالات الاشتراك
//   static const String ACTIVE_STATUS = 'active';
//   static const String TRIAL_STATUS = 'trial';
//   static const String EXPIRED_STATUS = 'expired';
//   static const String SUSPENDED_STATUS = 'suspended';

//   /// التحقق من إمكانية رفع التقارير الأونلاين - الدالة الرئيسية الجديدة
//   static Future<Map<String, dynamic>> checkOnlineReportsAccess() async {
//     try {
//       final schools = await isar.schools.where().findAll();
//       if (schools.isEmpty) {
//         return {
//           'has_access': false,
//           'reason': 'no_school',
//           'message': 'لم يتم العثور على بيانات المدرسة',
//         };
//       }
      
//       final school = schools.first;
//       final plan = school.subscriptionPlan ?? FREE_PLAN;
//       final status = school.subscriptionStatus;
      
//       // التحقق من الخطة
//       if (!_hasOnlineReportsFeature(plan)) {
//         return {
//           'has_access': false,
//           'reason': 'plan_limitation',
//           'message': 'ميزة التقارير الأونلاين غير متاحة في الخطة المجانية',
//           'current_plan': plan,
//           'upgrade_required': true,
//           'recommended_plan': BASIC_PLAN,
//         };
//       }
      
//       // التحقق من حالة الاشتراك
//       if (!_isSubscriptionActive(status)) {
//         return {
//           'has_access': false,
//           'reason': 'subscription_inactive',
//           'message': 'الاشتراك منتهي الصلاحية أو معطل',
//           'current_status': status,
//           'renewal_required': true,
//         };
//       }
      
//       // التحقق من المزامنة مع Supabase
//       if (school.supabaseId == null || school.organizationId == null) {
//         return {
//           'has_access': false,
//           'reason': 'not_synced',
//           'message': 'المدرسة غير مزامنة مع النظام السحابي',
//           'sync_required': true,
//         };
//       }
      
//       // التحقق من Supabase - التحديث المطلوب
//       if (SupabaseService.isEnabled) {
//         final subscriptionStatus = await SupabaseService.checkOrganizationSubscriptionStatus(school.organizationId!);
        
//         if (subscriptionStatus == null) {
//           return {
//             'has_access': false,
//             'reason': 'cloud_check_failed',
//             'message': 'فشل في التحقق من حالة الاشتراك السحابي',
//           };
//         }
        
//         // التحقق من نشاط الاشتراك السحابي
//         final isCloudActive = subscriptionStatus['is_active'] ?? false;
//         if (!isCloudActive) {
//           return {
//             'has_access': false,
//             'reason': 'cloud_subscription_inactive',
//             'message': 'الاشتراك السحابي غير نشط',
//             'cloud_status': subscriptionStatus['subscription_status'],
//             'cloud_plan': subscriptionStatus['subscription_plan'],
//           };
//         }
        
//         // التحقق من ميزة التقارير الأونلاين تحديداً
//         final hasOnlineReports = subscriptionStatus['has_online_reports'] ?? false;
//         if (!hasOnlineReports) {
//           return {
//             'has_access': false,
//             'reason': 'feature_not_available',
//             'message': 'ميزة التقارير الأونلاين غير مفعلة في اشتراكك السحابي',
//             'upgrade_required': true,
//             'current_plan': subscriptionStatus['subscription_plan'],
//             'feature_purchase_required': true,
//           };
//         }
//       }
      
//       return {
//         'has_access': true,
//         'message': 'ميزة التقارير الأونلاين متاحة',
//         'current_plan': plan,
//         'current_status': status,
//         'organization_name': school.organizationName,
//       };
      
//     } catch (e) {
//       return {
//         'has_access': false,
//         'reason': 'error',
//         'message': 'حدث خطأ في التحقق من الصلاحيات: $e',
//       };
//     }
//   }

//   /// الدالة القديمة للتوافق مع الكود الموجود
//   static Future<bool> isOnlineReportsAvailable() async {
//     final result = await checkOnlineReportsAccess();
//     return result['has_access'] ?? false;
//   }
  
//   /// التحقق من ميزات الخطة
//   static bool _hasOnlineReportsFeature(String plan) {
//     switch (plan.toLowerCase()) {
//       case FREE_PLAN:
//         return false; // الخطة المجانية لا تدعم التقارير الأونلاين
//       case BASIC_PLAN:
//       case PREMIUM_PLAN:
//       case ENTERPRISE_PLAN:
//         return true;
//       default:
//         return false;
//     }
//   }
  
//   /// التحقق من حالة الاشتراك
//   static bool _isSubscriptionActive(String? status) {
//     if (status == null) return false;
//     switch (status.toLowerCase()) {
//       case ACTIVE_STATUS:
//       case TRIAL_STATUS:
//         return true;
//       case EXPIRED_STATUS:
//       case SUSPENDED_STATUS:
//         return false;
//       default:
//         return false;
//     }
//   }
  
//   /// رفع التقرير المالي مع فحص الصلاحيات
//   static Future<Map<String, dynamic>> uploadFinancialReportWithAuth({
//     required Map<String, dynamic> reportData,
//     String? reportTitle,
//     String? period,
//   }) async {
//     // التحقق من الصلاحيات أولاً
//     final accessCheck = await checkOnlineReportsAccess();
//     if (!(accessCheck['has_access'] ?? false)) {
//       return {
//         'success': false,
//         'message': accessCheck['message'],
//         'reason': accessCheck['reason'],
//         'upgrade_required': accessCheck['upgrade_required'] ?? false,
//         'feature_purchase_required': accessCheck['feature_purchase_required'] ?? false,
//         'recommended_plan': accessCheck['recommended_plan'],
//       };
//     }
    
//     try {
//       final schools = await isar.schools.where().findAll();
//       if (schools.isEmpty || schools.first.supabaseId == null) {
//         return {
//           'success': false,
//           'message': 'بيانات المدرسة غير مكتملة',
//         };
//       }
      
//       final school = schools.first;
      
//       print('📊 رفع التقرير المالي للمدرسة: ${school.name}');
//       final result = await SupabaseService.uploadOrganizationReport(
//         organizationId: school.organizationId ?? 0,
//         schoolId: school.supabaseId!,
//         reportType: 'financial',
//         reportTitle: reportTitle ?? 'التقرير المالي - ${school.name}',
//         reportData: reportData,
//         period: period ?? DateTime.now().toString().substring(0, 7),
//         generatedBy: 'نظام إدارة المدرسة',
//       );
      
//       if (result['success'] == true) {
//         return {
//           'success': true,
//           'message': 'تم رفع التقرير المالي بنجاح',
//           'report_id': result['report_id'],
//         };
//       } else {
//         return {
//           'success': false,
//           'message': result['error'] ?? 'فشل في رفع التقرير المالي',
//           'error_code': result['error_code'],
//           'upgrade_required': result['upgrade_required'] ?? false,
//           'feature_purchase_required': result['upgrade_required'] ?? false,
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'حدث خطأ أثناء رفع التقرير: $e',
//       };
//     }
//   }
  
//   /// رفع تقرير الطلاب مع فحص الصلاحيات
//   static Future<Map<String, dynamic>> uploadStudentReportWithAuth({
//     required Map<String, dynamic> reportData,
//     String? reportTitle,
//     String? period,
//   }) async {
//     // التحقق من الصلاحيات أولاً
//     final accessCheck = await checkOnlineReportsAccess();
//     if (!(accessCheck['has_access'] ?? false)) {
//       return {
//         'success': false,
//         'message': accessCheck['message'],
//         'reason': accessCheck['reason'],
//         'upgrade_required': accessCheck['upgrade_required'] ?? false,
//         'feature_purchase_required': accessCheck['feature_purchase_required'] ?? false,
//         'recommended_plan': accessCheck['recommended_plan'],
//       };
//     }
    
//     try {
//       final schools = await isar.schools.where().findAll();
//       if (schools.isEmpty || schools.first.supabaseId == null) {
//         return {
//           'success': false,
//           'message': 'بيانات المدرسة غير مكتملة',
//         };
//       }
      
//       final school = schools.first;
      
//       print('👥 رفع تقرير الطلاب للمدرسة: ${school.name}');
//       final result = await SupabaseService.uploadOrganizationReport(
//         organizationId: school.organizationId ?? 0,
//         schoolId: school.supabaseId!,
//         reportType: 'students',
//         reportTitle: reportTitle ?? 'تقرير الطلاب - ${school.name}',
//         reportData: reportData,
//         period: period ?? DateTime.now().toString().substring(0, 7),
//         generatedBy: 'نظام إدارة المدرسة',
//       );
      
//       if (result['success'] == true) {
//         return {
//           'success': true,
//           'message': 'تم رفع تقرير الطلاب بنجاح',
//           'report_id': result['report_id'],
//         };
//       } else {
//         return {
//           'success': false,
//           'message': result['error'] ?? 'فشل في رفع تقرير الطلاب',
//           'error_code': result['error_code'],
//           'upgrade_required': result['upgrade_required'] ?? false,
//           'feature_purchase_required': result['upgrade_required'] ?? false,
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'حدث خطأ أثناء رفع التقرير: $e',
//       };
//     }
//   }

//   /// الدوال القديمة للتوافق مع الكود الموجود
//   static Future<bool> uploadFinancialReport({
//     required Map<String, dynamic> reportData,
//     String? reportTitle,
//     String? period,
//   }) async {
//     final result = await uploadFinancialReportWithAuth(
//       reportData: reportData,
//       reportTitle: reportTitle,
//       period: period,
//     );
//     return result['success'] ?? false;
//   }
  
//   static Future<bool> uploadStudentReport({
//     required Map<String, dynamic> reportData,
//     String? reportTitle,
//     String? period,
//   }) async {
//     final result = await uploadStudentReportWithAuth(
//       reportData: reportData,
//       reportTitle: reportTitle,
//       period: period,
//     );
//     return result['success'] ?? false;
//   }
  
//   /// عرض نافذة ترقية الاشتراك أو شراء الميزة
//   static void showUpgradeDialog(BuildContext context, {bool featurePurchaseRequired = false}) {
//     if (featurePurchaseRequired) {
//       _showFeaturePurchaseDialog(context);
//     } else {
//       _showPlanUpgradeDialog(context);
//     }
//   }
  
//   /// عرض نافذة شراء ميزة التقارير الأونلاين
//   static void _showFeaturePurchaseDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.cloud_upload, color: Colors.blue, size: 28),
//             SizedBox(width: 8),
//             Text('شراء ميزة التقارير الأونلاين'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('يمكنك شراء ميزة التقارير الأونلاين كإضافة منفصلة لباقتك الحالية.'),
//             SizedBox(height: 16),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('✨ ميزة التقارير الأونلاين:',
//                        style: TextStyle(fontWeight: FontWeight.bold)),
//                   SizedBox(height: 8),
//                   Text('• ☁️ رفع التقارير على السحابة'),
//                   Text('• 🔒 نسخ احتياطي آمن'),
//                   Text('• 📱 الوصول من أي جهاز'),
//                   Text('• 📊 مشاركة التقارير'),
//                   Text('• 💾 تخزين غير محدود'),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.green.shade200),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.price_check, color: Colors.green.shade700, size: 20),
//                       SizedBox(width: 8),
//                       Text('25,000 د.ع شهرياً',
//                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
//                     ],
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.star, color: Colors.amber, size: 20),
//                       SizedBox(width: 8),
//                       Text('250,000 د.ع سنوياً (وفر شهرين!)',
//                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('لاحقاً'),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//               _showContactInfo(context, isPurchase: true);
//             },
//             icon: Icon(Icons.shopping_cart),
//             label: Text('شراء الآن'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade600,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   /// عرض نافذة ترقية الباقة
//   static void _showPlanUpgradeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.star, color: Colors.amber, size: 28),
//             SizedBox(width: 8),
//             Text('ترقية الاشتراك'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('للاستفادة من ميزة التقارير الأونلاين، تحتاج إلى ترقية اشتراكك.'),
//             SizedBox(height: 16),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('✨ ميزات الخطة الأساسية:',
//                        style: TextStyle(fontWeight: FontWeight.bold)),
//                   SizedBox(height: 8),
//                   Text('• 📊 التقارير الأونلاين'),
//                   Text('• ☁️ نسخ احتياطية سحابية'),
//                   Text('• 🔄 مزامنة البيانات'),
//                   Text('• 📱 تطبيق الهاتف للمدراء'),
//                   Text('• 📈 إحصائيات متقدمة'),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.green.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.price_check, color: Colors.green.shade700, size: 20),
//                   SizedBox(width: 8),
//                   Text('سعر الخطة الأساسية: 99 ريال/شهر',
//                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('لاحقاً'),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//               _showContactInfo(context, isPurchase: false);
//             },
//             icon: Icon(Icons.upgrade),
//             label: Text('ترقية الآن'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade600,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   /// عرض معلومات التواصل للترقية أو الشراء
//   static void _showContactInfo(BuildContext context, {bool isPurchase = false}) {
//     final title = isPurchase ? 'شراء الميزة' : 'ترقية الباقة';
//     final message = isPurchase 
//         ? 'لشراء ميزة التقارير الأونلاين، يرجى التواصل معنا:'
//         : 'للترقية أو الاستفسار، يرجى التواصل معنا:';
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('معلومات التواصل - $title'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(message),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Icon(Icons.phone, color: Colors.green.shade600),
//                 SizedBox(width: 8),
//                 Text('الهاتف: +964 XX XXX XXXX'),
//               ],
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(Icons.email, color: Colors.blue.shade600),
//                 SizedBox(width: 8),
//                 Text('البريد: support@schoolapp.iq'),
//               ],
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(Icons.chat, color: Colors.green.shade600),
//                 SizedBox(width: 8),
//                 Text('واتساب: +964 XX XXX XXXX'),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('حسناً'),
//           ),
//         ],
//       ),
//     );
//   }
  
//   /// الحصول على معلومات خطة الاشتراك الحالية
//   static Future<Map<String, dynamic>> getSubscriptionInfo() async {
//     try {
//       final schools = await isar.schools.where().findAll();
//       if (schools.isEmpty) {
//         return {
//           'plan': FREE_PLAN,
//           'status': EXPIRED_STATUS,
//           'features': <String>[],
//           'online_reports': false,
//         };
//       }
      
//       final school = schools.first;
//       final plan = school.subscriptionPlan ?? FREE_PLAN;
//       final status = school.subscriptionStatus;
      
//       return {
//         'plan': plan,
//         'status': status,
//         'features': _getPlanFeatures(plan),
//         'online_reports': _hasOnlineReportsFeature(plan) && _isSubscriptionActive(status),
//         'organization_name': school.organizationName,
//         'synced_with_cloud': school.syncedWithSupabase,
//       };
//     } catch (e) {
//       return {
//         'plan': FREE_PLAN,
//         'status': EXPIRED_STATUS,
//         'features': <String>[],
//         'online_reports': false,
//         'error': e.toString(),
//       };
//     }
//   }
  
//   /// الحصول على ميزات الخطة
//   static List<String> _getPlanFeatures(String plan) {
//     switch (plan.toLowerCase()) {
//       case FREE_PLAN:
//         return [
//           'إدارة الطلاب محلياً',
//           'تقارير محلية فقط',
//           'دعم محدود',
//         ];
//       case BASIC_PLAN:
//         return [
//           'جميع ميزات الخطة المجانية',
//           '📊 التقارير الأونلاين',
//           '☁️ نسخ احتياطية سحابية',
//           'دعم فني أساسي',
//         ];
//       case PREMIUM_PLAN:
//         return [
//           'جميع ميزات الخطة الأساسية',
//           '📈 تحليلات متقدمة',
//           '🏢 إدارة متعددة المدارس',
//           '📱 تطبيق الهاتف للمدراء',
//           'دعم فني متقدم',
//         ];
//       case ENTERPRISE_PLAN:
//         return [
//           'جميع الميزات المتاحة',
//           '🔧 تخصيصات خاصة',
//           '🔒 أمان متقدم',
//           '📞 دعم فني مخصص 24/7',
//           '🎓 تدريب الفريق',
//         ];
//       default:
//         return [];
//     }
//   }
// }
