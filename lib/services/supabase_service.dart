import 'package:supabase_flutter/supabase_flutter.dart';
import '../device_info_service.dart';
import '../license_manager.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://xuwlqukmwaytbzncupnk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1d2xxdWttd2F5dGJ6bmN1cG5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNzI5MzUsImV4cCI6MjA2ODc0ODkzNX0.ZS-JybaGYsVVYiBKftZCR5ZGAYlO6JRObleEaCasx5U';
  static bool _isEnabled = supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  
  static SupabaseClient get client => Supabase.instance.client;
  static bool get isEnabled => _isEnabled;
  
  static Future<void> initialize() async {
    if (!_isEnabled) {
      print('⚠️ Supabase disabled - URLs not configured');
      return;
    }
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isEnabled = true;
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      _isEnabled = false;
    }
  }
  
  // إنشاء مؤسسة تعليمية جديدة مع المدرسة الأولى
  static Future<Map<String, dynamic>?> createOrganizationWithSchool({
    required String organizationName,
    required String organizationEmail,
    String? organizationPhone,
    String? organizationAddress,
    String? organizationLogo,
    required String schoolName,
    required String schoolType,
    List<int>? gradeLevels,
    String? schoolEmail,
    String? schoolPhone,
    String? schoolAddress,
    String? schoolLogo,
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
      print('🔄 بدء إنشاء المؤسسة التعليمية...');
      
      // اختبار الاتصال أولاً
      await client.from('educational_organizations').select('id').limit(1);
      print('✅ الاتصال بـ Supabase سليم');
      
      // الحصول على بصمة الجهاز وحالة الترخيص
      String deviceFingerprint = '';
      String activationCode = '';
      String subscriptionStatus = 'trial';
      
      try {
        deviceFingerprint = await DeviceInfoService.getDeviceFingerprint();
        activationCode = LicenseManager.generateActivationCodeForDevice(deviceFingerprint);
        
        // التحقق من حالة الترخيص الحالية
        final licenseStatus = await LicenseManager.getLicenseStatus();
        if (licenseStatus['isActivated']) {
          subscriptionStatus = 'active';
        } else if (licenseStatus['isTrialActive']) {
          subscriptionStatus = 'trial';
        } else {
          subscriptionStatus = 'expired';
        }
        
        print('🔑 بصمة الجهاز: ${deviceFingerprint.substring(0, 20)}...');
        print('🗝️ كود التفعيل تم إنشاؤه');
        print('📋 حالة الاشتراك: $subscriptionStatus');
      } catch (e) {
        print('⚠️ خطأ في الحصول على معلومات الجهاز: $e');
        // المتابعة بدون هذه المعلومات إذا حدث خطأ
      }
      
      // 1. إنشاء المؤسسة التعليمية
      print('📋 إنشاء المؤسسة: $organizationName');
      final orgResponse = await client.from('educational_organizations').insert({
        'name': organizationName,
        'email': organizationEmail,
        'phone': organizationPhone,
        'address': organizationAddress,
        'logo_url': organizationLogo,
        'subscription_plan': 'basic',
        'subscription_status': subscriptionStatus,
        'trial_expires_at': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'device_fingerprint': deviceFingerprint,
        'activation_code': activationCode,
      }).select().single();
      
      final organizationId = orgResponse['id'];
      print('✅ تم إنشاء المؤسسة - ID: $organizationId');
      
      // 2. إنشاء المدرسة الأولى
      print('🏫 إنشاء المدرسة: $schoolName');
      final schoolResponse = await client.from('schools').insert({
        'organization_id': organizationId,
        'name': schoolName,
        'school_type': schoolType,
        'grade_levels': gradeLevels,
        'email': schoolEmail ?? organizationEmail,
        'phone': schoolPhone ?? organizationPhone,
        'address': schoolAddress ?? organizationAddress,
        'logo_url': schoolLogo ?? organizationLogo,
        'current_students_count': 0,
        // 'established_year': DateTime.now().year,
        'is_active': true,
      }).select().single();
      
      final schoolId = schoolResponse['id'];
      print('✅ تم إنشاء المدرسة - ID: $schoolId');
      
      // 3. إنشاء حساب المدير
      print('👤 إنشاء حساب المدير: $adminEmail');
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(adminEmail)) {
        throw Exception('البريد الإلكتروني للمدير غير صالح: $adminEmail');
      }
      final authResponse = await client.auth.signUp(
        email: adminEmail,
        password: adminPassword,
        data: {
          'full_name': adminName,
          'role': 'organization_admin',
          'organization_id': organizationId,
        },
      );
      
      if (authResponse.user == null) {
        throw Exception('فشل في إنشاء حساب المدير');
      }
      
      final userId = authResponse.user!.id;
      print('✅ تم إنشاء حساب المدير - ID: $userId');
      
      // 4. إضافة المدير في جدول organization_admins
      print('🔐 إضافة صلاحيات المدير...');
      await client.from('organization_admins').insert({
        'organization_id': organizationId,
        'user_id': userId,
        'full_name': adminName,
        'email': adminEmail,
        'phone': adminPhone,
        'role': 'super_admin',  // الدور في المؤسسة
        'permissions': {
          // صلاحيات المدارس
          'all_schools': true,        // الوصول لجميع المدارس
          'manage_schools': true,     // إدارة المدارس (إضافة/حذف/تعديل)
          'view_school_data': true,   // رؤية بيانات المدارس
          
          // صلاحيات التقارير
          'reports': true,            // رؤية التقارير
          'analytics': true,          // رؤية الإحصائيات والتحليلات
          'export_reports': true,     // تصدير التقارير
          'financial_reports': true,  // التقارير المالية
          'student_reports': true,    // تقارير الطلاب
          
          // صلاحيات إدارة المستخدمين
          'manage_admins': true,      // إدارة المدراء الآخرين
          'manage_teachers': true,    // إدارة المعلمين
          'manage_students': true,    // إدارة الطلاب
          
          // صلاحيات النظام
          'system_settings': true,   // إعدادات النظام
          'backup_data': true,       // نسخ احتياطية
          'audit_logs': true,        // سجلات المراجعة
          
          // صلاحيات مالية
          'view_finances': true,     // رؤية المالية
          'manage_finances': true,   // إدارة المالية
          'approve_payments': true,  // الموافقة على المدفوعات
        },
        'school_access': 'all',       // 'all' أو ['school_id1', 'school_id2']
        'is_active': true,
      });
      
      print('✅ تم إنشاء ملف المدير بنجاح');
      print('🎉 إنشاء المؤسسة التعليمية مكتمل!');
      
      return {
        'organization_id': organizationId,
        'school_id': schoolId,
        'user_id': userId,
        'admin_email': adminEmail,
        'organization_name': organizationName,
        'school_name': schoolName,
      };
      
    } catch (e) {
      print('❌ خطأ في إنشاء المؤسسة: $e');
      
      if (e.toString().contains('row-level security policy')) {
        print('🔒 مشكلة أمان Supabase (RLS) - يرجى تنفيذ fix_supabase_rls.sql');
      } else if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        print('📋 الجداول غير موجودة - يرجى تنفيذ SQL لإنشاء الجداول');
      } else if (e.toString().contains('host lookup') || e.toString().contains('network')) {
        print('🌐 مشكلة اتصال بالإنترنت');
      }
      
      return null;
    }
  }
  
  // تحديث معلومات الترخيص للمؤسسة
  static Future<bool> updateOrganizationLicense({
    required int organizationId,
    String? newSubscriptionStatus,
    bool? updateDeviceInfo,
  }) async {
    if (!_isEnabled) return false;
    
    try {
      Map<String, dynamic> updateData = {};
      
      // تحديث حالة الاشتراك
      if (newSubscriptionStatus != null) {
        updateData['subscription_status'] = newSubscriptionStatus;
        print('🔄 تحديث حالة الاشتراك إلى: $newSubscriptionStatus');
      }
      
      // تحديث معلومات الجهاز إذا طُلب
      if (updateDeviceInfo == true) {
        try {
          final deviceFingerprint = await DeviceInfoService.getDeviceFingerprint();
          final activationCode = LicenseManager.generateActivationCodeForDevice(deviceFingerprint);
          
          updateData['device_fingerprint'] = deviceFingerprint;
          updateData['activation_code'] = activationCode;
          updateData['last_device_sync'] = DateTime.now().toIso8601String();
          
          print('🔑 تحديث بصمة الجهاز: ${deviceFingerprint.substring(0, 20)}...');
          print('🗝️ تحديث كود التفعيل');
        } catch (e) {
          print('⚠️ خطأ في تحديث معلومات الجهاز: $e');
        }
      }
      
      if (updateData.isNotEmpty) {
        await client
            .from('educational_organizations')
            .update(updateData)
            .eq('id', organizationId);
        
        print('✅ تم تحديث معلومات الترخيص للمؤسسة');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ خطأ في تحديث معلومات الترخيص: $e');
      return false;
    }
  }
  
  // الحصول على معلومات المؤسسة ومقارنة الترخيص
  static Future<Map<String, dynamic>?> getOrganizationLicenseInfo(int organizationId) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client
          .from('educational_organizations')
          .select('id, name, subscription_status, device_fingerprint, activation_code, trial_expires_at, last_device_sync')
          .eq('id', organizationId)
          .single();
      
      // الحصول على المعلومات المحلية للمقارنة
      final currentDeviceFingerprint = await DeviceInfoService.getDeviceFingerprint();
      final storedDeviceFingerprint = response['device_fingerprint'] as String?;
      
      final licenseStatus = await LicenseManager.getLicenseStatus();
      
      return {
        'organization_info': response,
        'current_device_fingerprint': currentDeviceFingerprint,
        'device_matches': storedDeviceFingerprint == currentDeviceFingerprint,
        'local_license_status': licenseStatus,
        'needs_sync': storedDeviceFingerprint != currentDeviceFingerprint,
      };
    } catch (e) {
      print('❌ خطأ في الحصول على معلومات الترخيص: $e');
      return null;
    }
  }
  
  // إضافة مدرسة جديدة للمؤسسة
  static Future<Map<String, dynamic>?> addSchoolToOrganization({
    required int organizationId,
    required String schoolName,
    required String schoolType,
    List<int>? gradeLevels,
    String? email,
    String? phone,
    String? address,
    String? logoUrl,
    int? capacity,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client.from('schools').insert({
        'organization_id': organizationId,
        'name': schoolName,
        'school_type': schoolType,
        'grade_levels': gradeLevels,
        'email': email,
        'phone': phone,
        'address': address,
        'logo_url': logoUrl,
        'capacity': capacity ?? 0,
        'current_students_count': 0,
        'is_active': true,
      }).select().single();
      
      print('✅ New school added: ${response['id']}');
      return response;
    } catch (e) {
      print('❌ Error adding school: $e');
      return null;
    }
  }
  
  // رفع تقرير مدرسة مع ربطه بالمؤسسة
  static Future<bool> uploadOrganizationReport({
    required int organizationId,
    required int schoolId,
    required String reportType,
    required String reportTitle,
    required Map<String, dynamic> reportData,
    required String period,
    String? generatedBy,
  }) async {
    if (!_isEnabled) return false;
    
    try {
      // استخراج ملخص من البيانات
      Map<String, dynamic> summary = _extractReportSummary(reportType, reportData);
      
      await client.from('reports').insert({
        'organization_id': organizationId,
        'school_id': schoolId,
        'report_type': reportType,
        'report_title': reportTitle,
        'report_data': reportData,
        'report_summary': summary,
        'period_start': _getPeriodStart(period),
        'period_end': _getPeriodEnd(period),
        'generated_by': generatedBy ?? 'نظام إدارة المدرسة',
        'is_public': false,
      });
      
      // تحديث الإحصائيات المجمعة للمؤسسة
      await _updateOrganizationAnalytics(organizationId, period);
      
      print('✅ Organization report uploaded');
      return true;
    } catch (e) {
      print('❌ Organization report upload failed: $e');
      return false;
    }
  }
  
  // تحديث إحصائيات المؤسسة المجمعة
  static Future<void> _updateOrganizationAnalytics(int organizationId, String period) async {
    try {
      final periodStart = _getPeriodStart(period);
      final periodEnd = _getPeriodEnd(period);
      
      if (periodStart == null || periodEnd == null) return;
      
      // جمع إحصائيات من كل مدارس المؤسسة
      final reports = await client
          .from('reports')
          .select('school_id, report_summary')
          .eq('organization_id', organizationId)
          .gte('period_start', periodStart.toIso8601String())
          .lte('period_end', periodEnd.toIso8601String());
      
      // حساب المجاميع
      int totalStudents = 0;
      double totalIncome = 0;
      double totalExpenses = 0;
      Set<int> schoolIds = {};
      
      for (final report in reports) {
        schoolIds.add(report['school_id']);
        final summary = report['report_summary'] as Map<String, dynamic>? ?? {};
        
        totalStudents += (summary['total_students'] as int?) ?? 0;
        totalIncome += (summary['total_income'] as num?)?.toDouble() ?? 0;
        totalExpenses += (summary['total_expenses'] as num?)?.toDouble() ?? 0;
      }
      
      // حفظ أو تحديث الإحصائيات المجمعة
      await client.from('organization_analytics').upsert({
        'organization_id': organizationId,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'analytics_data': {
          'schools_performance': schoolIds.map((id) => {'school_id': id}).toList(),
          'summary_generated_at': DateTime.now().toIso8601String(),
        },
        'total_students': totalStudents,
        'total_income': totalIncome,
        'total_expenses': totalExpenses,
        'schools_count': schoolIds.length,
      }, onConflict: 'organization_id,period_start,period_end');
      
    } catch (e) {
      print('Error updating organization analytics: $e');
    }
  }
  
  // جلب إحصائيات المؤسسة
  static Future<Map<String, dynamic>?> getOrganizationAnalytics(int organizationId, String period) async {
    if (!_isEnabled) return null;
    
    try {
      final periodStart = _getPeriodStart(period);
      final periodEnd = _getPeriodEnd(period);
      
      if (periodStart == null || periodEnd == null) return null;
      
      final response = await client
          .from('organization_analytics')
          .select('*')
          .eq('organization_id', organizationId)
          .eq('period_start', periodStart.toIso8601String())
          .eq('period_end', periodEnd.toIso8601String())
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error getting organization analytics: $e');
      return null;
    }
  }
  
  // جلب جميع مدارس المؤسسة
  static Future<List<Map<String, dynamic>>> getOrganizationSchools(int organizationId) async {
    if (!_isEnabled) return [];
    
    try {
      final response = await client
          .from('schools')
          .select('*')
          .eq('organization_id', organizationId)
          .eq('is_active', true)
          .order('created_at');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting organization schools: $e');
      return [];
    }
  }
  
  // باقي الدوال المساعدة...
  static Map<String, dynamic> _extractReportSummary(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'financial':
        return {
          'total_income': data['total_income'] ?? 0,
          'total_expenses': data['total_expenses'] ?? 0,
          'net_profit': data['net_profit'] ?? 0,
          'student_count': data['student_count'] ?? 0,
        };
      case 'students':
        return {
          'total_students': data['total_students'] ?? 0,
          'new_enrollments': data['new_enrollments'] ?? 0,
          'attendance_rate': data['attendance_rate'] ?? 0,
        };
      default:
        return {'summary': 'تقرير عام'};
    }
  }
  
  static DateTime? _getPeriodStart(String period) {
    try {
      if (period.contains('-') && period.length == 7) {
        return DateTime.parse('$period-01');
      }
    } catch (e) {}
    return null;
  }
  
  static DateTime? _getPeriodEnd(String period) {
    try {
      if (period.contains('-') && period.length == 7) {
        final date = DateTime.parse('$period-01');
        return DateTime(date.year, date.month + 1, 0);
      }
    } catch (e) {}
    return null;
  }

  // التحقق من حالة اشتراك المؤسسة
  static Future<bool> checkOrganizationSubscriptionStatus(int organizationId) async {
    if (!_isEnabled) return false;
    
    try {
      final response = await client
          .from('educational_organizations')
          .select('subscription_status, trial_expires_at')
          .eq('id', organizationId)
          .single();
      
      if (response['subscription_status'] == 'trial') {
        final trialExpiry = DateTime.parse(response['trial_expires_at']);
        return DateTime.now().isBefore(trialExpiry);
      }
      
      return response['subscription_status'] == 'active';
    } catch (e) {
      print('Error checking organization subscription: $e');
      return false;
    }
  }

  // التحقق من حالة الاشتراك للمدرسة (الدالة القديمة للتوافق)
  static Future<bool> checkSubscriptionStatus(int schoolId) async {
    if (!_isEnabled) return false;
    
    try {
      // الحصول على معرف المؤسسة من المدرسة
      final schoolResponse = await client
          .from('schools')
          .select('organization_id')
          .eq('id', schoolId)
          .single();
      
      final organizationId = schoolResponse['organization_id'];
      if (organizationId == null) return false;
      
      return await checkOrganizationSubscriptionStatus(organizationId);
    } catch (e) {
      print('Error checking school subscription: $e');
      return false;
    }
  }

  // رفع التقرير (الدالة القديمة للتوافق)
  static Future<bool> uploadReport({
    required int schoolId,
    required String reportType,
    required Map<String, dynamic> reportData,
  }) async {
    if (!_isEnabled) return false;
    
    try {
      // الحصول على معرف المؤسسة من المدرسة
      final schoolResponse = await client
          .from('schools')
          .select('organization_id, name')
          .eq('id', schoolId)
          .single();
      
      final organizationId = schoolResponse['organization_id'];
      final schoolName = schoolResponse['name'];
      
      if (organizationId == null) return false;
      
      return await uploadOrganizationReport(
        organizationId: organizationId,
        schoolId: schoolId,
        reportType: reportType,
        reportTitle: 'تقرير $reportType - $schoolName',
        reportData: reportData,
        period: DateTime.now().toString().substring(0, 7), // YYYY-MM
      );
    } catch (e) {
      print('Error uploading report: $e');
      return false;
    }
  }

  // دوال إدارة الاشتراكات

  /// إنشاء اشتراك جديد
  static Future<Map<String, dynamic>?> createSubscription({
    required int organizationId,
    required Map<String, dynamic> subscriptionData,
  }) async {
    if (!_isEnabled) return null;

    try {
      final response = await client
          .from('organization_subscriptions')
          .insert({
        'organization_id': organizationId,
        'feature': subscriptionData['feature'],
        'activation_date': subscriptionData['activation_date'],
        'expiry_date': subscriptionData['expiry_date'],
        'payment_method': subscriptionData['payment_method'],
        'transaction_id': subscriptionData['transaction_id'],
        'amount_paid': subscriptionData['amount_paid'],
        'status': subscriptionData['status'],
        'payment_details': subscriptionData['payment_details'],
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response;
    } catch (e) {
      print('خطأ في إنشاء الاشتراك: $e');
      rethrow;
    }
  }

  /// الحصول على حالة الاشتراك
  static Future<Map<String, dynamic>?> getSubscriptionStatus({
    required int organizationId,
    required String feature,
  }) async {
    if (!_isEnabled) return null;

    try {
      final response = await client
          .from('organization_subscriptions')
          .select('*')
          .eq('organization_id', organizationId)
          .eq('feature', feature)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return {
          'is_active': false,
          'message': 'لا يوجد اشتراك نشط',
        };
      }

      final expiryDate = DateTime.parse(response['expiry_date']);
      final now = DateTime.now();
      final isActive = expiryDate.isAfter(now);
      final daysRemaining = expiryDate.difference(now).inDays;

      return {
        'is_active': isActive,
        'expiry_date': response['expiry_date'],
        'days_remaining': daysRemaining,
        'message': isActive 
            ? (daysRemaining > 7 
                ? 'اشتراك نشط'
                : 'سينتهي خلال $daysRemaining أيام')
            : 'انتهى الاشتراك',
        'subscription_data': response,
      };
    } catch (e) {
      print('خطأ في الحصول على حالة الاشتراك: $e');
      return null;
    }
  }

  /// إلغاء الاشتراك
  static Future<bool> cancelSubscription({
    required int organizationId,
    required String feature,
  }) async {
    if (!_isEnabled) return false;

    try {
      await client
          .from('organization_subscriptions')
          .update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
      }).eq('organization_id', organizationId)
        .eq('feature', feature)
        .eq('status', 'active');

      return true;
    } catch (e) {
      print('خطأ في إلغاء الاشتراك: $e');
      return false;
    }
  }

  /// الحصول على جميع اشتراكات المؤسسة
  static Future<List<Map<String, dynamic>>> getOrganizationSubscriptions(
      int organizationId) async {
    if (!_isEnabled) return [];

    try {
      final response = await client
          .from('organization_subscriptions')
          .select('*')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('خطأ في الحصول على اشتراكات المؤسسة: $e');
      return [];
    }
  }

  /// الحصول على التقارير من السحابة
  static Future<List<Map<String, dynamic>>> getOrganizationReports({
    required int organizationId,
    String? reportType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (!_isEnabled) return [];

    try {
      var query = client
          .from('reports')
          .select('*')
          .eq('organization_id', organizationId);

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      if (fromDate != null) {
        query = query.gte('period_start', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('period_end', toDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('خطأ في الحصول على التقارير: $e');
      return [];
    }
  }

  /// رفع تقرير للسحابة
  static Future<bool> uploadReportToCloud({
    required int organizationId,
    required Map<String, dynamic> reportData,
  }) async {
    if (!_isEnabled) return false;

    try {
      await client.from('reports').insert({
        'organization_id': organizationId,
        'school_id': reportData['school_id'],
        'report_type': reportData['report_type'],
        'report_title': reportData['report_title'],
        'report_data': reportData['report_data'],
        'report_summary': reportData['report_summary'],
        'period_start': reportData['period_start'],
        'period_end': reportData['period_end'],
        'generated_by': reportData['generated_by'] ?? 'نظام إدارة المدرسة',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('خطأ في رفع التقرير: $e');
      return false;
    }
  }
}