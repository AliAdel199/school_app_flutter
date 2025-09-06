import '../services/database_service.dart';
import '../services/device_service.dart';
import '../services/organization_service.dart';
import '../services/subscription_service.dart';
import '../services/reports_service.dart';
import '../helpers/network_helper.dart';

/// الخدمة الرئيسية الموحدة
/// تجمع جميع الخدمات وتوفر واجهة موحدة للوصول إليها
class UnifiedService {
  static bool _isInitialized = false;
  
  /// تهيئة النظام بالكامل
  static Future<Map<String, dynamic>> initializeSystem() async {
    if (_isInitialized) {
      return {
        'success': true,
        'message': 'النظام مهيأ بالفعل',
        'services_status': await getServicesStatus(),
      };
    }
    
    print('🚀 بدء تهيئة النظام الشامل...');
    
    final Map<String, dynamic> initResults = {
      'database_service': false,
      'network_check': false,
      'device_info': false,
      'organization_check': false,
    };
    
    try {
      // 1. تهيئة قاعدة البيانات
      print('📊 تهيئة خدمة قاعدة البيانات...');
      initResults['database_service'] = await DatabaseService.initialize();
      
      // 2. فحص الشبكة
      print('🌐 فحص حالة الشبكة...');
      final networkStatus = await NetworkHelper.checkNetworkStatus();
      initResults['network_check'] = networkStatus['is_connected'];
      
      if (initResults['network_check']) {
        print('✅ الشبكة متصلة');
      } else {
        print('⚠️ لا يوجد اتصال بالإنترنت - سيعمل النظام في وضع محلي');
      }
      
      // 3. جمع معلومات الجهاز
      print('📱 جمع معلومات الجهاز...');
      try {
        final deviceInfo = await DeviceService.getDisplayInfo();
        initResults['device_info'] = deviceInfo.isNotEmpty;
        print('✅ تم جمع معلومات الجهاز: ${deviceInfo['النوع']}');
      } catch (e) {
        print('⚠️ خطأ في جمع معلومات الجهاز: $e');
        initResults['device_info'] = false;
      }
      
      // 4. التحقق من المؤسسة أو إنشاؤها
      if (DatabaseService.isEnabled && initResults['network_check']) {
        print('🏢 التحقق من المؤسسة...');
        try {
          final orgId = await OrganizationService.getOrCreateDefaultOrganization();
          initResults['organization_check'] = orgId != null;
          if (orgId != null) {
            print('✅ المؤسسة جاهزة - ID: $orgId');
          }
        } catch (e) {
          print('⚠️ خطأ في التحقق من المؤسسة: $e');
          initResults['organization_check'] = false;
        }
      }
      
      _isInitialized = true;
      
      final successCount = initResults.values.where((v) => v == true).length;
      final totalServices = initResults.length;
      
      print('🎉 تم إنهاء تهيئة النظام - نجح $successCount من $totalServices خدمات');
      
      return {
        'success': true,
        'initialized_services': successCount,
        'total_services': totalServices,
        'services_status': initResults,
        'message': 'تم تهيئة النظام بنجاح',
        'working_mode': DatabaseService.isEnabled ? 'online' : 'offline',
      };
      
    } catch (e) {
      print('❌ خطأ في تهيئة النظام: $e');
      return {
        'success': false,
        'error': e.toString(),
        'services_status': initResults,
        'message': 'فشل في تهيئة النظام',
      };
    }
  }

  /// فحص حالة جميع الخدمات
  static Future<Map<String, dynamic>> getServicesStatus() async {
    final Map<String, dynamic> status = {};
    
    try {
      // حالة قاعدة البيانات
      status['database'] = await DatabaseService.checkStatus();
      
      // حالة الشبكة
      status['network'] = await NetworkHelper.checkNetworkStatus();
      
      // معلومات الجهاز
      try {
        final deviceInfo = await DeviceService.getDisplayInfo();
        status['device'] = {
          'available': true,
          'info': deviceInfo,
          'is_physical': await DeviceService.isPhysicalDevice(),
        };
      } catch (e) {
        status['device'] = {
          'available': false,
          'error': e.toString(),
        };
      }
      
      // حالة المؤسسة
      if (DatabaseService.isEnabled) {
        try {
          final orgId = await NetworkHelper.getOrganizationId();
          if (orgId != null) {
            final orgStats = await OrganizationService.getOrganizationStats(int.parse(orgId));
            status['organization'] = {
              'available': true,
              'id': orgId,
              'stats': orgStats,
            };
            
            // حالة الاشتراك
            final subscriptionStatus = await SubscriptionService.checkOrganizationSubscriptionStatus(int.parse(orgId));
            status['subscription'] = {
              'available': true,
              'details': subscriptionStatus,
            };
          } else {
            status['organization'] = {
              'available': false,
              'error': 'لم يتم العثور على معرف المؤسسة',
            };
            status['subscription'] = {
              'available': false,
              'error': 'المؤسسة غير متاحة',
            };
          }
        } catch (e) {
          status['organization'] = {
            'available': false,
            'error': e.toString(),
          };
          status['subscription'] = {
            'available': false,
            'error': e.toString(),
          };
        }
      } else {
        status['organization'] = {
          'available': false,
          'error': 'قاعدة البيانات غير متاحة',
        };
        status['subscription'] = {
          'available': false,
          'error': 'قاعدة البيانات غير متاحة',
        };
      }
      
      return {
        'success': true,
        'services': status,
        'overall_health': _calculateOverallHealth(status),
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'services': status,
      };
    }
  }

  /// حساب الحالة العامة للنظام
  static String _calculateOverallHealth(Map<String, dynamic> servicesStatus) {
    int healthyServices = 0;
    int totalServices = 0;
    
    for (final service in servicesStatus.values) {
      totalServices++;
      if (service is Map && service['available'] == true) {
        healthyServices++;
      }
    }
    
    final healthPercentage = (healthyServices / totalServices) * 100;
    
    if (healthPercentage >= 90) return 'ممتاز';
    if (healthPercentage >= 70) return 'جيد';
    if (healthPercentage >= 50) return 'متوسط';
    return 'ضعيف';
  }

  /// تشخيص شامل للنظام
  static Future<Map<String, dynamic>> performSystemDiagnostic() async {
    print('🔍 بدء التشخيص الشامل للنظام...');
    
    final Map<String, dynamic> diagnosticResults = {
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
      'recommendations': <String>[],
      'critical_issues': <String>[],
      'warnings': <String>[],
    };
    
    try {
      // اختبار قاعدة البيانات
      print('🧪 اختبار قاعدة البيانات...');
      final dbStatus = await DatabaseService.checkStatus();
      diagnosticResults['tests']['database'] = dbStatus;
      
      if (!dbStatus['is_enabled']) {
        diagnosticResults['critical_issues'].add('قاعدة البيانات غير مفعلة');
        diagnosticResults['recommendations'].add('تحقق من إعدادات قاعدة البيانات');
      }
      
      // اختبار الشبكة
      print('🧪 اختبار الشبكة...');
      final networkStatus = await NetworkHelper.checkNetworkStatus();
      diagnosticResults['tests']['network'] = networkStatus;
      
      if (!networkStatus['is_connected']) {
        diagnosticResults['warnings'].add('لا يوجد اتصال بالإنترنت');
        diagnosticResults['recommendations'].add('تحقق من اتصال الإنترنت للحصول على جميع الميزات');
      }
      
      // اختبار الجهاز
      print('🧪 اختبار الجهاز...');
      try {
        final deviceInfo = await DeviceService.getDisplayInfo();
        final fingerprint = await DeviceService.generateDeviceFingerprint();
        final isPhysical = await DeviceService.isPhysicalDevice();
        
        diagnosticResults['tests']['device'] = {
          'info_available': deviceInfo.isNotEmpty,
          'fingerprint_generated': fingerprint.isNotEmpty,
          'is_physical_device': isPhysical,
          'device_info': deviceInfo,
        };
        
        if (!isPhysical) {
          diagnosticResults['warnings'].add('الجهاز قد يكون محاكي');
        }
      } catch (e) {
        diagnosticResults['tests']['device'] = {
          'error': e.toString(),
          'info_available': false,
        };
        diagnosticResults['warnings'].add('فشل في جمع معلومات الجهاز');
      }
      
      // اختبار المؤسسة والاشتراك
      if (DatabaseService.isEnabled && networkStatus['is_connected']) {
        print('🧪 اختبار المؤسسة والاشتراك...');
        try {
          final orgId = await NetworkHelper.getOrganizationId();
          if (orgId != null) {
            final orgStats = await OrganizationService.getOrganizationStats(int.parse(orgId));
            final subscriptionStatus = await SubscriptionService.checkOrganizationSubscriptionStatus(int.parse(orgId));
            
            diagnosticResults['tests']['organization'] = {
              'id': orgId,
              'stats_available': orgStats != null,
              'subscription_active': subscriptionStatus?['is_active'] ?? false,
              'subscription_plan': subscriptionStatus?['subscription_plan'],
              'features': subscriptionStatus?['features'],
            };
            
            // التحقق من انتهاء الاشتراك
            final daysRemaining = subscriptionStatus?['days_remaining'] as int?;
            if (daysRemaining != null && daysRemaining <= 7) {
              if (daysRemaining <= 0) {
                diagnosticResults['critical_issues'].add('انتهى الاشتراك');
              } else {
                diagnosticResults['warnings'].add('الاشتراك سينتهي خلال $daysRemaining أيام');
              }
              diagnosticResults['recommendations'].add('جدد الاشتراك للحصول على جميع الميزات');
            }
          } else {
            diagnosticResults['tests']['organization'] = {
              'error': 'لم يتم العثور على معرف المؤسسة',
            };
            diagnosticResults['critical_issues'].add('لم يتم تسجيل المؤسسة');
            diagnosticResults['recommendations'].add('قم بتسجيل المؤسسة أولاً');
          }
        } catch (e) {
          diagnosticResults['tests']['organization'] = {
            'error': e.toString(),
          };
          diagnosticResults['warnings'].add('فشل في التحقق من بيانات المؤسسة');
        }
      }
      
      // اختبار التقارير
      if (DatabaseService.isEnabled) {
        print('🧪 اختبار خدمة التقارير...');
        try {
          final reportsStats = await ReportsService.getReportsStatistics();
          diagnosticResults['tests']['reports'] = reportsStats;
          
          if (!reportsStats['success']) {
            diagnosticResults['warnings'].add('مشكلة في خدمة التقارير');
          }
        } catch (e) {
          diagnosticResults['tests']['reports'] = {
            'error': e.toString(),
          };
          diagnosticResults['warnings'].add('فشل في اختبار خدمة التقارير');
        }
      }
      
      // تحديد مستوى الصحة العام
      final criticalIssuesCount = diagnosticResults['critical_issues'].length;
      final warningsCount = diagnosticResults['warnings'].length;
      
      String healthLevel;
      if (criticalIssuesCount > 0) {
        healthLevel = 'خطير';
      } else if (warningsCount > 2) {
        healthLevel = 'يحتاج انتباه';
      } else if (warningsCount > 0) {
        healthLevel = 'جيد مع تحذيرات';
      } else {
        healthLevel = 'ممتاز';
      }
      
      diagnosticResults['health_level'] = healthLevel;
      diagnosticResults['success'] = true;
      
      print('✅ تم إنهاء التشخيص الشامل - الحالة: $healthLevel');
      
      return diagnosticResults;
      
    } catch (e) {
      print('❌ خطأ في التشخيص الشامل: $e');
      diagnosticResults['success'] = false;
      diagnosticResults['error'] = e.toString();
      return diagnosticResults;
    }
  }

  /// إعادة تعيين النظام
  static Future<Map<String, dynamic>> resetSystem() async {
    print('🔄 بدء إعادة تعيين النظام...');
    
    try {
      // تنظيف موارد قاعدة البيانات
      await DatabaseService.dispose();
      
      // إعادة تعيين حالة التهيئة
      _isInitialized = false;
      
      print('✅ تم إعادة تعيين النظام بنجاح');
      
      return {
        'success': true,
        'message': 'تم إعادة تعيين النظام بنجاح',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      print('❌ خطأ في إعادة تعيين النظام: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'فشل في إعادة تعيين النظام',
      };
    }
  }

  /// تحديث النظام (إعادة تهيئة)
  static Future<Map<String, dynamic>> updateSystem() async {
    print('🔄 بدء تحديث النظام...');
    
    try {
      // إعادة تعيين النظام أولاً
      await resetSystem();
      
      // إعادة تهيئة النظام
      final initResult = await initializeSystem();
      
      if (initResult['success']) {
        print('✅ تم تحديث النظام بنجاح');
        return {
          'success': true,
          'message': 'تم تحديث النظام بنجاح',
          'init_result': initResult,
        };
      } else {
        return {
          'success': false,
          'message': 'فشل في تحديث النظام',
          'init_result': initResult,
        };
      }
      
    } catch (e) {
      print('❌ خطأ في تحديث النظام: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'خطأ في تحديث النظام',
      };
    }
  }

  /// الحصول على ملخص شامل للنظام
  static Future<Map<String, dynamic>> getSystemSummary() async {
    try {
      final servicesStatus = await getServicesStatus();
      final deviceInfo = await DeviceService.getDisplayInfo();
      
      String organizationName = 'غير متاح';
      String subscriptionPlan = 'غير متاح';
      String subscriptionStatus = 'غير متاح';
      int daysRemaining = 0;
      
      if (DatabaseService.isEnabled) {
        final orgId = await NetworkHelper.getOrganizationId();
        if (orgId != null) {
          final subscriptionInfo = await SubscriptionService.checkOrganizationSubscriptionStatus(int.parse(orgId));
          if (subscriptionInfo != null) {
            subscriptionPlan = subscriptionInfo['subscription_plan'] ?? 'غير متاح';
            subscriptionStatus = subscriptionInfo['subscription_status'] ?? 'غير متاح';
            daysRemaining = subscriptionInfo['days_remaining'] ?? 0;
          }
        }
      }
      
      return {
        'system_health': servicesStatus['overall_health'],
        'database_status': DatabaseService.isEnabled ? 'متصل' : 'غير متصل',
        'network_status': servicesStatus['services']['network']['is_connected'] ? 'متصل' : 'غير متصل',
        'device_type': deviceInfo['النوع'] ?? 'غير معروف',
        'organization_name': organizationName,
        'subscription_plan': subscriptionPlan,
        'subscription_status': subscriptionStatus,
        'days_remaining': daysRemaining,
        'working_mode': DatabaseService.isEnabled ? 'أونلاين' : 'محلي',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'فشل في جمع ملخص النظام: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
