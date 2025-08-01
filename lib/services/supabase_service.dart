import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../helpers/network_helper.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://hvqpucjmtwqtaqydpskv.supabase.co';
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2cXB1Y2ptdHdxdGFxeWRwc2t2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1Mjg3NjEsImV4cCI6MjA2OTEwNDc2MX0.trWf50z1EiUij7cwDUooo6jVFCjVIm2ya1Pf2Pmvg5c";
  static bool _isEnabled = supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  
  static SupabaseClient get client => Supabase.instance.client;
  static bool get isEnabled => _isEnabled;

  // دالة تشفير كلمة المرور
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // دالة مساعدة للتكرار مع التعامل مع مشاكل الشبكة
  static Future<T?> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        print('🔄 المحاولة $attempt من $maxRetries فشلت: $e');
        
        if (attempt == maxRetries) {
          print('❌ فشلت جميع المحاولات');
          rethrow;
        }
        
        // انتظار قبل المحاولة التالية
        await Future.delayed(delay * attempt);
      }
    }
    return null;
  }
  
  static Future<void> initialize() async {
    if (!_isEnabled) {
      print('⚠️ Supabase disabled - URLs not configured');
      return;
    }
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
      );
      _isEnabled = true;
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      _isEnabled = false;
    }
  }

  // جلب معلومات الجهاز
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'id': androidInfo.id,
          'fingerprint': androidInfo.fingerprint,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          'platform': 'ios',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceData = {
          'platform': 'windows',
          'computerName': windowsInfo.computerName,
          'userName': windowsInfo.userName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
        };
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
    
    return deviceData;
  }

  // إنشاء device fingerprint فريد
  static Future<String> generateDeviceFingerprint() async {
    final deviceInfo = await getDeviceInfo();
    final platform = deviceInfo['platform'] ?? 'unknown';
    
    String fingerprint = '';
    
    switch (platform) {
      case 'android':
        fingerprint = '${deviceInfo['manufacturer']}_${deviceInfo['model']}_${deviceInfo['id']}_${deviceInfo['fingerprint']}'.replaceAll(' ', '_');
        break;
      case 'ios':
        fingerprint = '${deviceInfo['model']}_${deviceInfo['identifierForVendor']}_${deviceInfo['systemVersion']}'.replaceAll(' ', '_');
        break;
      case 'windows':
        fingerprint = '${deviceInfo['computerName']}_${deviceInfo['userName']}_${deviceInfo['majorVersion']}'.replaceAll(' ', '_');
        break;
      default:
        fingerprint = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return fingerprint.toLowerCase();
  }

  // تطبيع نوع المدرسة للقيم المسموحة
  static String _normalizeSchoolType(String schoolType) {
    // تنظيف النص
    String normalized = schoolType.trim().toLowerCase();
    
    // خريطة التحويل
    Map<String, String> typeMapping = {
      'بنين': 'boys',
      'ذكور': 'boys',
      'أولاد': 'boys',
      'طلاب': 'boys',
      'بنات': 'girls', 
      'إناث': 'girls',
      'طالبات': 'girls',
      'مختلط': 'mixed',
      'مختلطة': 'mixed',
      'مشترك': 'mixed',
      'مشتركة': 'mixed',
      'boys': 'boys',
      'girls': 'girls',
      'mixed': 'mixed',
    };
    
    String result = typeMapping[normalized] ?? 'mixed';
    
    return result;
  }
  
  // إنشاء مؤسسة تعليمية جديدة
  static Future<Map<String, dynamic>?> createEducationalOrganization({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? logoUrl,
    String subscriptionPlan = 'basic',
    String subscriptionStatus = 'trial',
    int maxSchools = 1,
    int maxStudents = 100,
  }) async {
    if (!_isEnabled) {
      print('⚠️ Supabase غير مفعل - يعمل في وضع محلي فقط');
      return null;
    }
    
    try {
      print('🔄 إنشاء مؤسسة تعليمية جديدة...');
      
      // استخدام آلية retry للتعامل مع مشاكل الشبكة
      final response = await _retryOperation(() async {
        return await client.from('educational_organizations').insert({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'logo_url': logoUrl,
          'subscription_plan': subscriptionPlan,
          'subscription_status': subscriptionStatus,
          'trial_expires_at': DateTime.now().add(Duration(days: 7)).toIso8601String(),
          'max_schools': maxSchools,
          'max_students': maxStudents,
        }).select().single();
      });
      
      if (response != null) {
        print('✅ تم إنشاء المؤسسة بنجاح - ID: ${response['id']}');
        return response;
      } else {
        print('❌ فشل في إنشاء المؤسسة بعد جميع المحاولات');
        return null;
      }
      
    } catch (e) {
      print('❌ خطأ في إنشاء المؤسسة: $e');
      return null;
    }
  }

  // التحقق من حالة ترخيص المؤسسة
  static Future<Map<String, dynamic>?> checkLicenseStatus(String email) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client
          .from('license_status_view')
          .select('*')
          .eq('email', email)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('❌ خطأ في فحص حالة الترخيص: $e');
      return null;
    }
  }

  // تحديث معلومات الجهاز للمؤسسة
  static Future<bool> updateOrganizationDeviceInfo(int organizationId) async {
    if (!_isEnabled) return false;
    
    try {
      final deviceInfo = await getDeviceInfo();
      final deviceFingerprint = await generateDeviceFingerprint();
      
      // احصل على العدد الحالي أولاً
      final currentOrg = await client
          .from('educational_organizations')
          .select('activation_count')
          .eq('id', organizationId)
          .single();
      
      final currentCount = (currentOrg['activation_count'] as int?) ?? 0;
      
      await client.from('educational_organizations').update({
        'device_fingerprint': deviceFingerprint,
        'device_info': deviceInfo,
        'last_activation_at': DateTime.now().toIso8601String(),
        'activation_count': currentCount + 1,
      }).eq('id', organizationId);
      
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث معلومات الجهاز: $e');
      return false;
    }
  }

  // إنشاء مدرسة جديدة
  static Future<Map<String, dynamic>?> createSchool({
    required int organizationId,
    required String name,
    required String schoolType,
    List<int>? gradeLevels,
    String? email,
    String? phone,
    String? address,
    String? logoUrl,
    int maxStudentsCount = 100,
    int? establishedYear,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      // تطبيع نوع المدرسة للقيم المسموحة
      String normalizedSchoolType = _normalizeSchoolType(schoolType);
      
      // استخدام آلية retry للتعامل مع مشاكل الشبكة
      final response = await _retryOperation(() async {
        return await client.from('schools').insert({
          'organization_id': organizationId,
          'name': name,
          'school_type': normalizedSchoolType,
          'grade_levels': gradeLevels,
          'email': email,
          'phone': phone,
          'address': address,
          'logo_url': logoUrl,
          'max_students_count': maxStudentsCount,
          'is_active': true,
        }).select().single();
      });
      
      if (response != null) {
        print('✅ تم إنشاء المدرسة بنجاح - ID: ${response['id']}');
        return response;
      } else {
        print('❌ فشل في إنشاء المدرسة بعد جميع المحاولات');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في إنشاء المدرسة: $e');
      return null;
    }
  }

  // إنشاء مستخدم جديد
  static Future<Map<String, dynamic>?> createUser({
    required int organizationId,
    required int schoolId,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required String role,
    Map<String, dynamic>? permissions,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      // التحقق من اتصال الشبكة أولاً
      if (!await NetworkHelper.isConnected()) {
        print('⚠️ لا يوجد اتصال بالإنترنت');
        return null;
      }

      // تشفير كلمة المرور
      final passwordHash = hashPassword(password);

      // تحويل permissions إلى تنسيق JSON صحيح
      dynamic permissionsJson;
      if (permissions != null) {
        // تحويل Map إلى List من المفاتيح المفعلة
        permissionsJson = permissions.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList();
      }

      // استخدام آلية retry للتعامل مع مشاكل الشبكة
      final response = await _retryOperation(() async {
        return await client.from('users').insert({
          'organization_id': organizationId,
          'school_id': schoolId,
          'full_name': fullName,
          'email': email,
          'password_hash': passwordHash,
          'phone': phone,
          'role': role,
          'permissions': permissionsJson,
          'is_active': true,
        }).select().single();
      });
      
      return response;
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');
      return null;
    }
  }

  // إنشاء طالب جديد
  static Future<Map<String, dynamic>?> createStudent({
    required int organizationId,
    required int schoolId,
    required String studentId,
    required String fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? email,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? address,
    int? gradeLevel,
    String? section,
    String? notes,
    String? profilePhotoUrl,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client.from('students').insert({
        'organization_id': organizationId,
        'school_id': schoolId,
        'student_id': studentId,
        'full_name': fullName,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'phone': phone,
        'email': email,
        'parent_name': parentName,
        'parent_phone': parentPhone,
        'parent_email': parentEmail,
        'address': address,
        'grade_level': gradeLevel,
        'section': section,
        'status': 'active',
        'notes': notes,
        'profile_photo_url': profilePhotoUrl,
      }).select().single();
      
      return response;
    } catch (e) {
      print('❌ خطأ في إنشاء الطالب: $e');
      return null;
    }
  }

  // إنشاء مؤسسة تعليمية مع مدرسة ومدير في عملية واحدة
  static Future<Map<String, dynamic>?> createOrganizationWithSchool({
    // بيانات المؤسسة
    required String organizationName,
    required String organizationEmail,
    String? organizationPhone,
    String? organizationAddress,
    String? organizationLogo,
    
    // بيانات المدرسة
    required String schoolName,
    required String schoolType,
    List<int>? gradeLevels,
    String? schoolEmail,
    String? schoolPhone,
    String? schoolAddress,
    String? schoolLogo,
    
    // بيانات المدير
    required String adminName,
    required String adminEmail,
    required String adminPassword,
    String? adminPhone,
  }) async {
    if (!_isEnabled) {
      print('⚠️ Supabase غير مفعل - يعمل في وضع محلي فقط');
      return null;
    }
    
    try {
      print('🔄 بدء إنشاء مؤسسة تعليمية متكاملة...');
      print('📊 فحص حالة الشبكة...');
      
      // فحص الاتصال أولاً
      final networkStatus = await NetworkHelper.checkNetworkStatus();
      print('🌐 حالة الشبكة: ${networkStatus['message']}');
      
      if (!networkStatus['is_connected']) {
        throw Exception('لا يوجد اتصال بالإنترنت. تحقق من اتصالك بالشبكة.');
      }
      
      if (!networkStatus['can_reach_supabase']) {
        throw Exception('لا يمكن الوصول إلى خادم قاعدة البيانات. تحقق من اتصالك أو حاول لاحقاً.');
      }
      
      try {
        await client.from('educational_organizations').select('id').limit(1);
        print('✅ الاتصال مع Supabase يعمل بشكل صحيح');
      } catch (e) {
        print('❌ مشكلة في الاتصال مع Supabase: $e');
        throw Exception('لا يمكن الاتصال بخدمة قاعدة البيانات. تحقق من اتصالك بالإنترنت.');
      }
      
      // 1. إنشاء المؤسسة التعليمية
      print('📝 الخطوة 1: إنشاء المؤسسة التعليمية...');
      final organizationResult = await createEducationalOrganization(
        name: organizationName,
        email: organizationEmail,
        phone: organizationPhone,
        address: organizationAddress,
        logoUrl: organizationLogo,
        maxSchools: 10, // افتراضي
        maxStudents: 1000, // افتراضي
      );
      
      if (organizationResult == null) {
        throw Exception('فشل إنشاء المؤسسة التعليمية - لم يتم إرجاع استجابة من الخادم');
      }
      
      final organizationId = organizationResult['id'];
      print('✅ تم إنشاء المؤسسة - ID: $organizationId');
      
      // 2. إنشاء المدرسة
      print('📝 الخطوة 2: إنشاء المدرسة...');
      final schoolResult = await createSchool(
        organizationId: organizationId,
        name: schoolName,
        schoolType: schoolType,
        gradeLevels: gradeLevels ?? [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        email: schoolEmail,
        phone: schoolPhone,
        address: schoolAddress,
        logoUrl: schoolLogo,
      );
      
      if (schoolResult == null) {
        throw Exception('فشل إنشاء المدرسة - لم يتم إرجاع استجابة من الخادم');
      }
      
      final schoolId = schoolResult['id'];
      print('✅ تم إنشاء المدرسة - ID: $schoolId');
      
      // 3. إنشاء المدير
      print('📝 الخطوة 3: إنشاء حساب المدير...');
      final adminResult = await createUser(
        organizationId: organizationId,
        schoolId: schoolId,
        fullName: adminName,
        email: adminEmail,
        password: adminPassword,
        phone: adminPhone,
        role: 'admin',
        permissions: {
          'can_manage_users': true,
          'can_manage_students': true,
          'can_manage_financial': true,
          'can_generate_reports': true,
          'can_export_data': true,
        },
      );
      
      if (adminResult == null) {
        throw Exception('فشل إنشاء حساب المدير - لم يتم إرجاع استجابة من الخادم');
      }
      
      print('✅ تم إنشاء حساب المدير - ID: ${adminResult['id']}');
      print('🎉 تم إنشاء المؤسسة التعليمية المتكاملة بنجاح!');
      
      // إرجاع جميع المعلومات
      return {
        'organization_id': organizationId,
        'organization_name': organizationResult['name'],
        'school_id': schoolId,
        'school_name': schoolResult['name'], 
        'admin_id': adminResult['id'],
        'admin_email': adminResult['email'],
        'success': true,
      };
      
    } catch (e) {
      print('❌ خطأ في إنشاء المؤسسة المتكاملة: $e');
      return null;
    }
  }

  // التحقق من حالة اشتراك المؤسسة
  static Future<bool> checkOrganizationSubscriptionStatus(int organizationId) async {
    if (!_isEnabled) return false;
    
    try {
      return await _retryOperation(() async {
        // التحقق من اتصال الشبكة أولاً
        if (!await NetworkHelper.isConnected()) {
          print('⚠️ لا يوجد اتصال بالإنترنت');
          return false;
        }

        final response = await client
            .from('educational_organizations')
            .select('subscription_status, trial_expires_at')
            .eq('id', organizationId)
            .maybeSingle();
        
        if (response == null) {
          print('❌ لم يتم العثور على المؤسسة');
          return false;
        }
        
        final status = response['subscription_status'] as String?;
        final trialExpiresAt = response['trial_expires_at'] as String?;
        
        // التحقق من حالة الاشتراك
        switch (status?.toLowerCase()) {
          case 'active':
            return true;
          case 'trial':
            if (trialExpiresAt != null) {
              final expiryDate = DateTime.parse(trialExpiresAt);
              return DateTime.now().isBefore(expiryDate);
            }
            return false;
          case 'expired':
          case 'suspended':
          default:
            return false;
        }
      }) ?? false;
    } catch (e) {
      print('❌ خطأ في التحقق من حالة الاشتراك: $e');
      return false;
    }
  }

  // الحصول على إحصائيات المؤسسة
  static Future<Map<String, dynamic>?> getOrganizationStats(int organizationId) async {
    if (!_isEnabled) return null;
    
    try {
      return await _retryOperation<Map<String, dynamic>?>(() async {
        // التحقق من اتصال الشبكة أولاً
        if (!await NetworkHelper.isConnected()) {
          print('⚠️ لا يوجد اتصال بالإنترنت');
          return null;
        }

        final response = await client
            .from('license_stats_view')
            .select('*')
            .eq('organization_id', organizationId)
            .maybeSingle();
        
        return response;
      });
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات المؤسسة: $e');
      return null;
    }
  }

  // رفع تقرير المؤسسة
  static Future<bool> uploadOrganizationReport({
    required int organizationId,
    required int schoolId,
    required String reportType,
    required String reportTitle,
    required Map<String, dynamic> reportData,
    required String period,
    required String generatedBy,
  }) async {
    if (!_isEnabled) return false;
    
    try {
      return await _retryOperation(() async {
        // التحقق من اتصال الشبكة أولاً
        if (!await NetworkHelper.isConnected()) {
          print('⚠️ لا يوجد اتصال بالإنترنت');
          return false;
        }

        // إنشاء جدول التقارير إذا لم يكن موجوداً (للتوافق)
        await _ensureReportsTableExists();

        final reportRecord = {
          'organization_id': organizationId,
          'school_id': schoolId,
          'report_type': reportType,
          'report_title': reportTitle,
          'report_data': reportData,
          'period': period,
          'generated_by': generatedBy,
          'generated_at': DateTime.now().toIso8601String(),
          'status': 'uploaded',
        };

        final response = await client
            .from('reports')
            .insert(reportRecord)
            .select()
            .single();

        print('✅ تم رفع التقرير بنجاح - ID: ${response['id']}');
        return true;
      }) ?? false;
    } catch (e) {
      print('❌ خطأ في رفع التقرير: $e');
      return false;
    }
  }

  // التأكد من وجود جدول التقارير
  static Future<void> _ensureReportsTableExists() async {
    try {
      // محاولة إنشاء جدول التقارير إذا لم يكن موجوداً
      await client.rpc('create_reports_table_if_not_exists');
    } catch (e) {
      // تجاهل الخطأ إذا كان الجدول موجوداً بالفعل
      print('ℹ️ جدول التقارير موجود بالفعل أو حدث خطأ في الإنشاء: $e');
    }
  }
}