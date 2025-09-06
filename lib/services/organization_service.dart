import '../services/database_service.dart';
import '../services/device_service.dart';
import '../helpers/network_helper.dart';

/// خدمة إدارة المؤسسات التعليمية
/// تدير جميع العمليات المتعلقة بالمؤسسات والمدارس والمستخدمين
class OrganizationService {
  
  /// تطبيع نوع المدرسة للقيم المسموحة في قاعدة البيانات
  static String _normalizeSchoolType(String schoolType) {
    String normalized = schoolType.trim().toLowerCase();
    
    const Map<String, String> typeMapping = {
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
    
    return typeMapping[normalized] ?? 'mixed';
  }

  /// إنشاء مؤسسة تعليمية جديدة
  static Future<Map<String, dynamic>?> createOrganization({
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
    if (!DatabaseService.isEnabled) {
      print('⚠️ قاعدة البيانات غير مفعلة');
      return null;
    }
    
    try {
      print('🔄 إنشاء مؤسسة تعليمية: $name');
      
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('educational_organizations')
              .insert({
                'name': name,
                'email': email,
                'phone': phone,
                'address': address,
                'logo_url': logoUrl,
                'subscription_plan': subscriptionPlan,
                'subscription_status': subscriptionStatus,
                'max_schools': maxSchools,
                'max_students': maxStudents,
                'trial_expires_at': DateTime.now()
                    .add(const Duration(days: 30))
                    .toIso8601String(),
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
        },
        operationName: 'إنشاء مؤسسة تعليمية',
      );
      
      if (result != null) {
        print('✅ تم إنشاء المؤسسة بنجاح - ID: ${result['id']}');
        
        // حفظ معرف المؤسسة محلياً
        await NetworkHelper.saveOrganizationId(result['id'].toString());
        
        return result;
      }
      
      return null;
    } catch (e) {
      print('❌ خطأ في إنشاء المؤسسة: $e');
      return null;
    }
  }

  /// إنشاء مدرسة جديدة
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
    if (!DatabaseService.isEnabled) return null;
    
    try {
      print('🔄 إنشاء مدرسة: $name');
      
      final normalizedSchoolType = _normalizeSchoolType(schoolType);
      
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('schools')
              .insert({
                'organization_id': organizationId,
                'name': name,
                'school_type': normalizedSchoolType,
                'grade_levels': gradeLevels ?? [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                'email': email,
                'phone': phone,
                'address': address,
                'logo_url': logoUrl,
                'max_students_count': maxStudentsCount,
                'established_year': establishedYear,
                'is_active': true,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
        },
        operationName: 'إنشاء مدرسة',
      );
      
      if (result != null) {
        print('✅ تم إنشاء المدرسة بنجاح - ID: ${result['id']}');
        return result;
      }
      
      return null;
    } catch (e) {
      print('❌ خطأ في إنشاء المدرسة: $e');
      return null;
    }
  }

  /// إنشاء مستخدم جديد
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
    if (!DatabaseService.isEnabled) return null;
    
    try {
      print('🔄 إنشاء مستخدم: $fullName');
      
      // التحقق من اتصال الشبكة
      if (!await NetworkHelper.isConnected()) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // تشفير كلمة المرور
      final passwordHash = DatabaseService.hashPassword(password);
      
      // إنشاء حساب المصادقة
      final authResponse = await DatabaseService.client.auth.signUp(
        email: email, 
        password: passwordHash,
      );
      
      if (authResponse.user == null) {
        throw Exception('فشل في إنشاء حساب المصادقة');
      }

      // تحويل الصلاحيات إلى قائمة
      List<String>? permissionsList;
      if (permissions != null) {
        permissionsList = permissions.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList();
      }

      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('users')
              .insert({
                'id': authResponse.user!.id,
                'organization_id': organizationId,
                'school_id': schoolId,
                'full_name': fullName,
                'email': email,
                'password_hash': passwordHash,
                'phone': phone,
                'role': role,
                'permissions': permissionsList,
                'is_active': true,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
        },
        operationName: 'إنشاء مستخدم',
      );
      
      if (result != null) {
        print('✅ تم إنشاء المستخدم بنجاح - ID: ${result['id']}');
        return result;
      }
      
      return null;
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');
      return null;
    }
  }

  /// إنشاء طالب جديد
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
    if (!DatabaseService.isEnabled) return null;
    
    try {
      print('🔄 إنشاء طالب: $fullName');
      
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('students')
              .insert({
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
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
        },
        operationName: 'إنشاء طالب',
      );
      
      if (result != null) {
        print('✅ تم إنشاء الطالب بنجاح - ID: ${result['id']}');
        return result;
      }
      
      return null;
    } catch (e) {
      print('❌ خطأ في إنشاء الطالب: $e');
      return null;
    }
  }

  /// تحديث معلومات الجهاز للمؤسسة
  static Future<bool> updateOrganizationDeviceInfo(int organizationId) async {
    if (!DatabaseService.isEnabled) return false;
    
    try {
      print('🔄 تحديث معلومات الجهاز للمؤسسة: $organizationId');
      
      final deviceInfo = await DeviceService.getDeviceInfo();
      final deviceFingerprint = await DeviceService.generateDeviceFingerprint();
      
      // الحصول على العدد الحالي للتفعيلات
      final currentOrg = await DatabaseService.client
          .from('educational_organizations')
          .select('activation_count')
          .eq('id', organizationId)
          .single();
      
      final currentCount = (currentOrg['activation_count'] as int?) ?? 0;
      
      await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('educational_organizations')
              .update({
                'device_fingerprint': deviceFingerprint,
                'device_info': deviceInfo,
                'last_activation_at': DateTime.now().toIso8601String(),
                'activation_count': currentCount + 1,
              })
              .eq('id', organizationId);
        },
        operationName: 'تحديث معلومات الجهاز',
      );
      
      print('✅ تم تحديث معلومات الجهاز بنجاح');
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث معلومات الجهاز: $e');
      return false;
    }
  }

  /// إنشاء مؤسسة تعليمية متكاملة (مؤسسة + مدرسة + مدير)
  static Future<Map<String, dynamic>?> createCompleteOrganization({
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
    if (!DatabaseService.isEnabled) {
      print('⚠️ قاعدة البيانات غير مفعلة');
      return null;
    }
    
    try {
      print('🚀 بدء إنشاء مؤسسة تعليمية متكاملة...');
      
      // فحص حالة الشبكة
      final networkStatus = await NetworkHelper.checkNetworkStatus();
      print('🌐 حالة الشبكة: ${networkStatus['message']}');
      
      if (!networkStatus['is_connected']) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
      
      if (!networkStatus['can_reach_supabase']) {
        throw Exception('لا يمكن الوصول إلى خادم قاعدة البيانات');
      }
      
      // اختبار الاتصال مع قاعدة البيانات
      try {
        await DatabaseService.client
            .from('educational_organizations')
            .select('id')
            .limit(1);
        print('✅ الاتصال مع قاعدة البيانات يعمل بشكل صحيح');
      } catch (e) {
        throw Exception('لا يمكن الاتصال بقاعدة البيانات: $e');
      }
      
      // الخطوة 1: إنشاء المؤسسة التعليمية
      print('📝 الخطوة 1: إنشاء المؤسسة التعليمية...');
      final organizationResult = await createOrganization(
        name: organizationName,
        email: organizationEmail,
        phone: organizationPhone,
        address: organizationAddress,
        logoUrl: organizationLogo,
        maxSchools: 10,
        maxStudents: 1000,
      );
      
      if (organizationResult == null) {
        throw Exception('فشل إنشاء المؤسسة التعليمية');
      }
      
      final organizationId = organizationResult['id'] as int;
      print('✅ تم إنشاء المؤسسة - ID: $organizationId');
      
      // الخطوة 2: إنشاء المدرسة
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
        throw Exception('فشل إنشاء المدرسة');
      }
      
      final schoolId = schoolResult['id'] as int;
      print('✅ تم إنشاء المدرسة - ID: $schoolId');
      
      // الخطوة 3: إنشاء المدير
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
          'can_export_data': true,
          'can_view_reports': true,
          'can_manage_settings': true,
        },
      );
      
      if (adminResult == null) {
        throw Exception('فشل إنشاء حساب المدير');
      }
      
      print('✅ تم إنشاء حساب المدير - ID: ${adminResult['id']}');
      
      // الخطوة 4: تحديث معلومات الجهاز
      print('📝 الخطوة 4: تسجيل معلومات الجهاز...');
      await updateOrganizationDeviceInfo(organizationId);
      
      print('🎉 تم إنشاء المؤسسة التعليمية المتكاملة بنجاح!');
      
      return {
        'success': true,
        'organization_id': organizationId,
        'organization_name': organizationResult['name'],
        'school_id': schoolId,
        'school_name': schoolResult['name'],
        'admin_id': adminResult['id'],
        'admin_email': adminResult['email'],
        'message': 'تم إنشاء المؤسسة التعليمية بنجاح',
      };
      
    } catch (e) {
      print('❌ خطأ في إنشاء المؤسسة المتكاملة: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'فشل في إنشاء المؤسسة التعليمية',
      };
    }
  }

  /// الحصول على معرف المؤسسة الافتراضي أو إنشاؤه
  static Future<int?> getOrCreateDefaultOrganization() async {
    if (!DatabaseService.isEnabled) return null;
    
    try {
      // البحث عن مؤسسة موجودة
      final existingOrgs = await DatabaseService.client
          .from('educational_organizations')
          .select('id, name')
          .limit(1);
      
      if (existingOrgs.isNotEmpty) {
        final firstOrgId = existingOrgs.first['id'] as int;
        print('✅ استخدام المؤسسة الموجودة - ID: $firstOrgId');
        await NetworkHelper.saveOrganizationId(firstOrgId.toString());
        return firstOrgId;
      }
      
      // إنشاء مؤسسة افتراضية إذا لم توجد
      print('🔄 إنشاء مؤسسة افتراضية...');
      final newOrg = await createOrganization(
        name: 'المؤسسة التعليمية الرئيسية',
        email: 'admin@school.local',
        phone: '07XX XXX XXXX',
        address: 'العراق',
      );
      
      if (newOrg != null) {
        final orgId = newOrg['id'] as int;
        print('✅ تم إنشاء المؤسسة الافتراضية - ID: $orgId');
        await NetworkHelper.saveOrganizationId(orgId.toString());
        return orgId;
      }
      
      return null;
    } catch (e) {
      print('❌ خطأ في الحصول على المؤسسة الافتراضية: $e');
      return null;
    }
  }

  /// الحصول على إحصائيات المؤسسة
  static Future<Map<String, dynamic>?> getOrganizationStats(int organizationId) async {
    if (!DatabaseService.isEnabled) return null;
    
    try {
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('license_stats_view')
              .select('*')
              .eq('organization_id', organizationId)
              .single();
        },
        operationName: 'جلب إحصائيات المؤسسة',
      );
      
      return result;
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات المؤسسة: $e');
      return null;
    }
  }
}
