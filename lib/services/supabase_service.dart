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
      final AuthResponse? authResponse = await client.auth.signUp(email: email, password: passwordHash);
  if (authResponse!.user == null) {
        throw Exception('فشل في إنشاء المستخدم');
      }
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
          'id': authResponse.user!.id, 
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

  // التحقق من حالة اشتراك المؤسسة مع ميزات مفصلة
  static Future<Map<String, dynamic>?> checkOrganizationSubscriptionStatus(int organizationId) async {
    if (!_isEnabled) return null;
    
    try {
      return await _retryOperation<Map<String, dynamic>?>(() async {
        if (!await NetworkHelper.isConnected()) {
          print('⚠️ لا يوجد اتصال بالإنترنت');
          return <String, dynamic>{};
        }
        print('🔄 جاري التحقق من حالة الاشتراك للمؤسسة: $organizationId');
        
        // أولاً، دعنا نتحقق من وجود أي مؤسسات في قاعدة البيانات
        final allOrgs = await client
            .from('educational_organizations')
            .select('id, name')
            .limit(5);
        
        print('📋 المؤسسات الموجودة في قاعدة البيانات: ${allOrgs.length}');
        for (final org in allOrgs) {
          print('   - ID: ${org['id']}, اسم: ${org['name']}');
        }
        
        final response = await client
            .from('educational_organizations')
            .select('subscription_status, subscription_plan, trial_expires_at, subscription_expires_at')
            .eq('id', 11)
            .maybeSingle();
        
        if (response == null) {
          print('❌ لم يتم العثور على المؤسسة بالمعرف: $organizationId');
          print('💡 تأكد من أن المؤسسة موجودة في قاعدة البيانات أو أن المعرف صحيح');
          
          // محاولة إنشاء مؤسسة افتراضية إذا كانت هذه هي المؤسسة الأولى
          if (organizationId == 1 && allOrgs.isEmpty) {
            print('🔄 إنشاء مؤسسة افتراضية...');
            final defaultOrg = await createEducationalOrganization(
              name: 'المؤسسة التعليمية الرئيسية',
              email: 'admin@school.local',
              phone: '07XX XXX XXXX',
              address: 'العراق',
              subscriptionPlan: 'basic',
              subscriptionStatus: 'active',
              maxSchools: 10,
              maxStudents: 1000,
            );
            
            if (defaultOrg != null) {
              print('✅ تم إنشاء المؤسسة الافتراضية بنجاح - ID: ${defaultOrg['id']}');
              // حفظ معرف المؤسسة الجديد
              await NetworkHelper.saveOrganizationId(defaultOrg['id'].toString());
              
              // إعادة التحقق من حالة الاشتراك للمؤسسة الجديدة
              return await checkOrganizationSubscriptionStatus(defaultOrg['id']);
            }
          }
          
          return <String, dynamic>{
            'is_active': false,
            'subscription_plan': null,
            'subscription_status': 'not_found',
            'has_online_reports': false,
            'error': 'المؤسسة غير موجودة',
            'organization_id': organizationId,
          };
        }
        
        final status = response['subscription_status'] as String?;
        final plan = response['subscription_plan'] as String?;
        final trialExpiresAt = response['trial_expires_at'] as String?;
        final subscriptionExpiresAt = response['subscription_expires_at'] as String?;
        
        bool isActive = false;
        bool hasOnlineReports = false;
        
        // التحقق من حالة الاشتراك
        switch (status?.toLowerCase()) {
          case 'active':
            if (subscriptionExpiresAt != null) {
              final expiryDate = DateTime.parse(subscriptionExpiresAt);
              isActive = DateTime.now().isBefore(expiryDate);
            } else {
              isActive = true; // اشتراك دائم
            }
            break;
          case 'trial':
            if (trialExpiresAt != null) {
              final expiryDate = DateTime.parse(trialExpiresAt);
              isActive = DateTime.now().isBefore(expiryDate);
            }
            break;
          default:
            isActive = false;
        }
        
        // التحقق من ميزة التقارير الأونلاين
        if (isActive && plan != null) {
          switch (plan.toLowerCase()) {
            case 'premium':
            case 'enterprise':
              hasOnlineReports = true;
              break;
            case 'basic':
            case 'trial':
            default:
              // التحقق من الميزات المشتراة منفصلاً
              hasOnlineReports = await _checkPurchasedFeature(organizationId, 'online_reports');
          }
        }
        
        return {
          'is_active': isActive,
          'subscription_plan': plan,
          'subscription_status': status,
          'has_online_reports': hasOnlineReports,
          'trial_expires_at': trialExpiresAt,
          'subscription_expires_at': subscriptionExpiresAt,
        };
      });
    } catch (e) {
      print('❌ خطأ في التحقق من حالة الاشتراك: $e');
      return null;
    }
  }

  // الحصول على معرف المؤسسة الافتراضي أو إنشاؤه
  static Future<int?> getOrCreateDefaultOrganization() async {
    if (!_isEnabled) return null;
    
    try {
      // أولاً، تحقق من وجود أي مؤسسة
      final existingOrgs = await client
          .from('educational_organizations')
          .select('id, name')
          .limit(1);
      
      if (existingOrgs.isNotEmpty) {
        final firstOrgId = existingOrgs.first['id'] as int;
        print('✅ استخدام المؤسسة الموجودة - ID: $firstOrgId');
        await NetworkHelper.saveOrganizationId(firstOrgId.toString());
        return firstOrgId;
      }
      
      // إذا لم توجد مؤسسة، أنشئ واحدة افتراضية
      print('🔄 إنشاء مؤسسة افتراضية...');
      final newOrg = await createEducationalOrganization(
        name: 'المؤسسة التعليمية الرئيسية',
        email: 'admin@school.local',
        phone: '07XX XXX XXXX',
        address: 'العراق',
        subscriptionPlan: 'basic',
        subscriptionStatus: 'active',
        maxSchools: 10,
        maxStudents: 1000,
      );
      
      if (newOrg != null) {
        final newOrgId = newOrg['id'] as int;
        print('✅ تم إنشاء المؤسسة الافتراضية - ID: $newOrgId');
        await NetworkHelper.saveOrganizationId(newOrgId.toString());
        return newOrgId;
      }
      
      return null;
    } catch (e) {
      print('❌ خطأ في الحصول على المؤسسة الافتراضية: $e');
      return null;
    }
  }

  // التحقق من ميزة مشتراة منفصلة
  static Future<bool> _checkPurchasedFeature(int organizationId, String featureName) async {
    try {
      final response = await client
          .from('feature_purchases')
          .select('expires_at, status')
          .eq('organization_id', organizationId)
          .eq('feature_name', featureName)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .maybeSingle();

      if (response == null) return false;

      final expiresAt = response['expires_at'] as String?;
      if (expiresAt != null) {
        final expiryDate = DateTime.parse(expiresAt);
        return DateTime.now().isBefore(expiryDate);
      }

      return true; // إذا لم يكن هناك تاريخ انتهاء، فالميزة نشطة
    } catch (e) {
      print('❌ خطأ في فحص الميزة المشتراة: $e');
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

  // رفع تقرير المؤسسة (مع التحقق من الصلاحيات)
  static Future<Map<String, dynamic>> uploadOrganizationReport({
    required int organizationId,
    required int schoolId,
    required String reportType,
    required String reportTitle,
    required Map<String, dynamic> reportData,
    required String period,
    required String generatedBy,
  }) async {
    if (!_isEnabled) {
      return {
        'success': false,
        'error': 'الخدمة غير متاحة حالياً',
        'error_code': 'SERVICE_UNAVAILABLE'
      };
    }
    
    try {
      // التحقق من صلاحيات التقارير الأونلاين
      final subscriptionStatus = await checkOrganizationSubscriptionStatus(organizationId);
      
      if (subscriptionStatus == null) {
        return {
          'success': false,
          'error': 'لا يمكن التحقق من حالة الاشتراك',
          'error_code': 'SUBSCRIPTION_CHECK_FAILED'
        };
      }
      
      if (!subscriptionStatus['is_active']) {
        return {
          'success': false,
          'error': 'انتهت صلاحية الاشتراك',
          'error_code': 'SUBSCRIPTION_EXPIRED'
        };
      }
      
      if (!subscriptionStatus['has_online_reports']) {
        return {
          'success': false,
          'error': 'ميزة التقارير الأونلاين غير مفعلة في باقتك الحالية',
          'error_code': 'FEATURE_NOT_AVAILABLE',
          'upgrade_required': true,
          'current_plan': subscriptionStatus['subscription_plan']
        };
      }
      
      return await _retryOperation(() async {
        if (!await NetworkHelper.isConnected()) {
          throw Exception('لا يوجد اتصال بالإنترنت');
        }

        // التأكد من وجود جدول التقارير
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
        return {
          'success': true,
          'report_id': response['id'],
          'message': 'تم رفع التقرير بنجاح'
        };
      }) ?? {
        'success': false,
        'error': 'فشل في رفع التقرير بعد عدة محاولات',
        'error_code': 'UPLOAD_FAILED'
      };
    } catch (e) {
      print('❌ خطأ في رفع التقرير: $e');
      return {
        'success': false,
        'error': 'حدث خطأ أثناء رفع التقرير: $e',
        'error_code': 'UPLOAD_ERROR'
      };
    }
  }

  // شراء ميزة التقارير الأونلاين كإضافة
  static Future<Map<String, dynamic>> purchaseOnlineReportsFeature({
    required int organizationId,
    required String paymentMethod,
    required double amount,
    required String duration, // 'monthly' أو 'yearly'
  }) async {
    if (!_isEnabled) {
      return {
        'success': false,
        'error': 'الخدمة غير متاحة حالياً'
      };
    }
    
    try {
      return await _retryOperation<Map<String, dynamic>>(() async {
        if (!await NetworkHelper.isConnected()) {
          throw Exception('لا يوجد اتصال بالإنترنت');
        }

        // حساب تاريخ الانتهاء
        final expiresAt = duration == 'yearly' 
            ? DateTime.now().add(Duration(days: 365))
            : DateTime.now().add(Duration(days: 30));

        // تسجيل عملية الشراء
        final purchaseRecord = {
          'organization_id': organizationId,
          'feature_name': 'online_reports',
          'payment_method': paymentMethod,
          'amount': amount,
          'currency': 'IQD',
          'purchase_date': DateTime.now().toIso8601String(),
          'expires_at': expiresAt.toIso8601String(),
          'status': 'active',
        };

        await client.from('feature_purchases').insert(purchaseRecord);

        return {
          'success': true,
          'message': 'تم تفعيل ميزة التقارير الأونلاين بنجاح',
          'expires_at': expiresAt.toIso8601String(),
        };
      }) ?? {
        'success': false,
        'error': 'فشل في تفعيل الميزة'
      };
    } catch (e) {
      print('❌ خطأ في شراء الميزة: $e');
      return {
        'success': false,
        'error': 'حدث خطأ أثناء تفعيل الميزة: $e'
      };
    }
  }

  // الحصول على قائمة بالميزات المشتراة للمؤسسة
  static Future<List<Map<String, dynamic>>?> getOrganizationPurchasedFeatures(int organizationId) async {
    if (!_isEnabled) return null;
    
    try {
      return await _retryOperation<List<Map<String, dynamic>>?>(() async {
        if (!await NetworkHelper.isConnected()) {
          return null;
        }

        final response = await client
            .from('feature_purchases')
            .select('*')
            .eq('organization_id', organizationId)
            .eq('status', 'active')
            .order('created_at', ascending: false);

        return List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('❌ خطأ في جلب الميزات المشتراة: $e');
      return null;
    }
  }

  // إرسال طلب شراء خدمة
  static Future<Map<String, dynamic>> submitServicePurchaseRequest({
    required int organizationId,
    required String schoolName,
    required String contactEmail,
    String? contactPhone,
    required String requestedService,
    required String planDuration,
    required double requestedAmount,
    String? requestMessage,
  }) async {
    if (!_isEnabled) {
      return {
        'success': false,
        'error': 'الخدمة غير متاحة حالياً'
      };
    }
    
    try {
      return await _retryOperation(() async {
        if (!await NetworkHelper.isConnected()) {
          throw Exception('لا يوجد اتصال بالإنترنت');
        }

        final requestRecord = {
          'organization_id': organizationId,
          'school_name': schoolName,
          'contact_email': contactEmail,
          'contact_phone': contactPhone,
          'requested_service': requestedService,
          'plan_duration': planDuration,
          'requested_amount': requestedAmount,
          'currency': 'IQD',
          'request_message': requestMessage,
          'request_status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };

        final response = await client
            .from('service_purchase_requests')
            .insert(requestRecord)
            .select()
            .single();

        print('✅ تم إرسال طلب الشراء - ID: ${response['id']}');
        return {
          'success': true,
          'request_id': response['id'],
          'message': 'تم إرسال طلب الشراء بنجاح'
        };
      }) ?? {
        'success': false,
        'error': 'فشل في إرسال الطلب'
      };
    } catch (e) {
      print('❌ خطأ في إرسال طلب الشراء: $e');
      return {
        'success': false,
        'error': 'حدث خطأ أثناء إرسال الطلب: $e'
      };
    }
  }

  // جلب جميع طلبات الشراء (للمدير)
  static Future<List<Map<String, dynamic>>?> getAllServicePurchaseRequests({
    String? status,
    String? service,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      return await _retryOperation(() async {
        if (!await NetworkHelper.isConnected()) {
          return <Map<String, dynamic>>[];
        }

        var queryBuilder = client
            .from('service_purchase_requests')
            .select('*');

        if (status != null && status.isNotEmpty && status != 'all') {
          queryBuilder = queryBuilder.eq('request_status', status);
        }

        if (service != null && service.isNotEmpty && service != 'all') {
          queryBuilder = queryBuilder.eq('requested_service', service);
        }

        final response = await queryBuilder.order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('❌ خطأ في جلب طلبات الشراء: $e');
      return null;
    }
  }

  // تحديث حالة طلب الشراء (للمدير)
  static Future<Map<String, dynamic>> updateServicePurchaseRequest({
    required int requestId,
    required String newStatus,
    String? adminNotes,
    String? processedBy,
  }) async {
    if (!_isEnabled) {
      return {
        'success': false,
        'error': 'الخدمة غير متاحة حالياً'
      };
    }
    
    try {
      return await _retryOperation(() async {
        if (!await NetworkHelper.isConnected()) {
          throw Exception('لا يوجد اتصال بالإنترنت');
        }

        final updateData = {
          'request_status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (adminNotes != null) {
          updateData['admin_notes'] = adminNotes;
        }

        if (processedBy != null) {
          updateData['processed_by'] = processedBy;
          updateData['processed_at'] = DateTime.now().toIso8601String();
        }

        await client
            .from('service_purchase_requests')
            .update(updateData)
            .eq('id', requestId);

        return {
          'success': true,
          'message': 'تم تحديث حالة الطلب بنجاح'
        };
      }) ?? {
        'success': false,
        'error': 'فشل في تحديث الطلب'
      };
    } catch (e) {
      print('❌ خطأ في تحديث طلب الشراء: $e');
      return {
        'success': false,
        'error': 'حدث خطأ أثناء تحديث الطلب: $e'
      };
    }
  }

  // موافقة على طلب وتفعيل الخدمة
  static Future<Map<String, dynamic>> approveAndActivateService({
    required int requestId,
    required int organizationId,
    required String service,
    required String duration,
    String? processedBy,
  }) async {
    if (!_isEnabled) {
      return {
        'success': false,
        'error': 'الخدمة غير متاحة حالياً'
      };
    }
    
    try {
      return await _retryOperation(() async {
        if (!await NetworkHelper.isConnected()) {
          throw Exception('لا يوجد اتصال بالإنترنت');
        }

        // 1. تحديث حالة الطلب
        await updateServicePurchaseRequest(
          requestId: requestId,
          newStatus: 'approved',
          adminNotes: 'تم الموافقة وتفعيل الخدمة',
          processedBy: processedBy ?? 'system',
        );

        // 2. تفعيل الخدمة
        if (service == 'online_reports') {
          final amount = duration == 'yearly' ? 250000.0 : 25000.0;
          
          final activationResult = await purchaseOnlineReportsFeature(
            organizationId: organizationId,
            paymentMethod: 'admin_approval',
            amount: amount,
            duration: duration,
          );

          if (!activationResult['success']) {
            throw Exception('فشل في تفعيل الخدمة: ${activationResult['error']}');
          }
        }

        return {
          'success': true,
          'message': 'تم الموافقة على الطلب وتفعيل الخدمة بنجاح'
        };
      }) ?? {
        'success': false,
        'error': 'فشل في معالجة الطلب'
      };
    } catch (e) {
      print('❌ خطأ في موافقة الطلب: $e');
      return {
        'success': false,
        'error': 'حدث خطأ أثناء معالجة الطلب: $e'
      };
    }
  }

  // الحصول على جميع الاشتراكات
  static Future<Map<String, dynamic>> getAllSubscriptions() async {
    if (!_isEnabled) {
      return {
        'success': false,
        'message': 'Supabase غير مفعل',
        'data': []
      };
    }

    try {
      final response = await _retryOperation(() async {
        return await client
            .from('feature_purchases')
            .select('''
              *,
              organizations!inner(
                organization_name,
                license_key
              )
            ''')
            .order('created_at', ascending: false);
      });

      if (response == null) {
        return {
          'success': false,
          'message': 'فشل في الاتصال بقاعدة البيانات',
          'data': []
        };
      }

      // تحويل البيانات لتسهيل العرض
      final subscriptions = response.map((item) {
        return {
          'organization_id': item['organization_id'],
          'organization_name': item['organizations']['organization_name'],
          'license_key': item['organizations']['license_key'],
          'feature_name': item['feature_name'],
          'amount': item['amount'],
          'is_active': item['status'] == 'active',
          'expires_at': item['expires_at'],
          'created_at': item['created_at'],
          'payment_method': item['payment_method'],
          'duration': item['duration'],
        };
      }).toList();

      return {
        'success': true,
        'message': 'تم جلب البيانات بنجاح',
        'data': subscriptions
      };

    } catch (e) {
      print('❌ خطأ في جلب جميع الاشتراكات: $e');
      return {
        'success': false,
        'message': 'حدث خطأ أثناء جلب البيانات: $e',
        'data': []
      };
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

  // التحقق من اشتراك التقارير الأونلاين
  static Future<bool> checkOnlineReportsSubscription() async {
    if (!_isEnabled) return false;
    
    try {
      final organizationId = await NetworkHelper.getOrganizationId();
      if (organizationId == null) return false;

      final purchasedFeatures = await getOrganizationPurchasedFeatures(int.parse(organizationId));
      if (purchasedFeatures != null && purchasedFeatures.isNotEmpty) {
        return purchasedFeatures.any((feature) => 
          feature['feature_name'] == 'online_reports' && feature['status'] == 'active'
        );
      }
      return false;
    } catch (e) {
      print('❌ خطأ في التحقق من اشتراك التقارير: $e');
      return false;
    }
  }

  // رفع تقرير إلى قاعدة البيانات
  static Future<bool> uploadReport(Map<String, dynamic> reportData) async {
    if (!_isEnabled) return false;
    
    try {
      final organizationId = await NetworkHelper.getOrganizationId();
      if (organizationId == null) {
        throw Exception('لم يتم العثور على معرف المؤسسة');
      }

      // التأكد من وجود جدول التقارير
      await _ensureReportsTableExists();

      // إعداد بيانات التقرير للرفع
      final reportToUpload = {
        'organization_id': int.parse(organizationId),
        'report_type': reportData['type'] ?? 'general',
        'report_data': reportData,
        'generated_at': reportData['generated_at'] ?? DateTime.now().toIso8601String(),
        'uploaded_at': DateTime.now().toIso8601String(),
        'file_size': reportData['file_size'] ?? 0,
        'status': 'uploaded'
      };

      final response = await _retryOperation(() async {
        return await client
            .from('reports')
            .insert(reportToUpload)
            .select();
      });

      if (response != null && response.isNotEmpty) {
        print('✅ تم رفع التقرير بنجاح');
        return true;
      } else {
        print('❌ فشل في رفع التقرير');
        return false;
      }

    } catch (e) {
      print('❌ خطأ في رفع التقرير: $e');
      return false;
    }
  }

  // جلب التقارير المرفوعة للمؤسسة
  static Future<Map<String, dynamic>> getUploadedReports({
    int? limit = 50,
    String? reportType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (!_isEnabled) {
      return {
        'success': false,
        'message': 'الخدمة غير متاحة',
        'data': []
      };
    }

    try {
      final organizationId = await NetworkHelper.getOrganizationId();
      if (organizationId == null) {
        return {
          'success': false,
          'message': 'لم يتم العثور على معرف المؤسسة',
          'data': []
        };
      }

      final response = await _retryOperation(() async {
        var queryBuilder = client
            .from('reports')
            .select()
            .eq('organization_id', int.parse(organizationId))
            .order('uploaded_at', ascending: false);

        if (limit != null) {
          queryBuilder = queryBuilder.limit(limit);
        }

        return queryBuilder;
      });

      // تطبيق الفلاتر على البيانات بعد الجلب
      var filteredData = response ?? [];
      
      if (reportType != null) {
        filteredData = filteredData.where((report) => 
          report['report_type'] == reportType).toList();
      }

      if (fromDate != null) {
        filteredData = filteredData.where((report) {
          final uploadDate = DateTime.parse(report['uploaded_at']);
          return uploadDate.isAfter(fromDate) || uploadDate.isAtSameMomentAs(fromDate);
        }).toList();
      }

      if (toDate != null) {
        filteredData = filteredData.where((report) {
          final uploadDate = DateTime.parse(report['uploaded_at']);
          return uploadDate.isBefore(toDate) || uploadDate.isAtSameMomentAs(toDate);
        }).toList();
      }

      return {
        'success': true,
        'message': 'تم جلب التقارير بنجاح',
        'data': filteredData
      };

    } catch (e) {
      print('❌ خطأ في جلب التقارير: $e');
      return {
        'success': false,
        'message': 'حدث خطأ أثناء جلب التقارير: $e',
        'data': []
      };
    }
  }

  // حذف تقرير مرفوع
  static Future<bool> deleteUploadedReport(String reportId) async {
    if (!_isEnabled) return false;
    
    try {
      final organizationId = await NetworkHelper.getOrganizationId();
      if (organizationId == null) return false;

      final response = await _retryOperation(() async {
        return await client
            .from('reports')
            .delete()
            .eq('id', reportId)
            .eq('organization_id', int.parse(organizationId));
      });

      return response != null;
    } catch (e) {
      print('❌ خطأ في حذف التقرير: $e');
      return false;
    }
  }

  // الحصول على إحصائيات التقارير
  static Future<Map<String, dynamic>> getReportsStatistics() async {
    if (!_isEnabled) {
      return {
        'success': false,
        'message': 'الخدمة غير متاحة',
        'stats': {}
      };
    }

    try {
      final organizationId = await NetworkHelper.getOrganizationId();
      if (organizationId == null) {
        return {
          'success': false,
          'message': 'لم يتم العثور على معرف المؤسسة',
          'stats': {}
        };
      }

      final response = await _retryOperation(() async {
        return await client
            .from('reports')
            .select('report_type, file_size, uploaded_at')
            .eq('organization_id', int.parse(organizationId));
      });

      final reports = response ?? [];
      final totalReports = reports.length;
      final totalSize = reports.fold<int>(0, (sum, report) => 
        sum + (report['file_size'] as int? ?? 0));
      
      final reportsByType = <String, int>{};
      for (final report in reports) {
        final type = report['report_type'] ?? 'general';
        reportsByType[type] = (reportsByType[type] ?? 0) + 1;
      }

      return {
        'success': true,
        'message': 'تم جلب الإحصائيات بنجاح',
        'stats': {
          'total_reports': totalReports,
          'total_size_bytes': totalSize,
          'reports_by_type': reportsByType,
          'last_upload': reports.isNotEmpty ? reports.first['uploaded_at'] : null,
        }
      };

    } catch (e) {
      print('❌ خطأ في جلب إحصائيات التقارير: $e');
      return {
        'success': false,
        'message': 'حدث خطأ أثناء جلب الإحصائيات: $e',
        'stats': {}
      };
    }
  }
}