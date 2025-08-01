import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

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
        fingerprint = '${deviceInfo['manufacturer']}_${deviceInfo['model']}_${deviceInfo['androidId']}_${deviceInfo['fingerprint']}'.replaceAll(' ', '_');
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
      
      // جلب معلومات الجهاز وإنشاء fingerprint
      final deviceInfo = await getDeviceInfo();
      final deviceFingerprint = await generateDeviceFingerprint();
      
      final response = await client.from('educational_organizations').insert({
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
        'device_fingerprint': deviceFingerprint,
        'device_info': deviceInfo,
        'last_activation_at': DateTime.now().toIso8601String(),
        'activation_count': 1,
      }).select().single();
      
      print('✅ تم إنشاء المؤسسة بنجاح - ID: ${response['id']}');
      return response;
      
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
      final response = await client.from('schools').insert({
        'organization_id': organizationId,
        'name': name,
        'school_type': schoolType,
        // 'grade_levels': gradeLevels,
        'email': email,
        'phone': phone,
        'address': address,
        'logo_url': logoUrl,
        // 'max_students_count': maxStudentsCount,
        // 'established_year': establishedYear ?? DateTime.now().year,
        'is_active': true,
      }).select().single();
      
      print('✅ تم إنشاء المدرسة بنجاح - ID: ${response['id']}');
      return response;
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
    String? phone,
    required String role,
    Map<String, dynamic>? permissions,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client.from('users').insert({
        'organization_id': organizationId,
        'school_id': schoolId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'permissions': permissions,
        'is_active': true,
      }).select().single();
      
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

  // إنشاء صف جديد
  static Future<Map<String, dynamic>?> createClass({
    required int organizationId,
    required int schoolId,
    required String className,
    required int gradeLevel,
    String? section,
    String? teacherId,
    int maxStudents = 30,
    String? subject,
    String? roomNumber,
    Map<String, dynamic>? schedule,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client.from('classes').insert({
        'organization_id': organizationId,
        'school_id': schoolId,
        'class_name': className,
        'grade_level': gradeLevel,
        'section': section,
        'teacher_id': teacherId,
        'max_students': maxStudents,
        'subject': subject,
        'room_number': roomNumber,
        'schedule': schedule,
        'is_active': true,
      }).select().single();
      
      return response;
    } catch (e) {
      print('❌ خطأ في إنشاء الصف: $e');
      return null;
    }
  }

  // إضافة طالب إلى صف
  static Future<bool> addStudentToClass({
    required int organizationId,
    required int schoolId,
    required int studentId,
    required int classId,
    String status = 'active',
  }) async {
    if (!_isEnabled) return false;
    
    try {
      await client.from('student_classes').insert({
        'organization_id': organizationId,
        'school_id': schoolId,
        'student_id': studentId,
        'class_id': classId,
        'status': status,
      });
      
      return true;
    } catch (e) {
      print('❌ خطأ في إضافة الطالب للصف: $e');
      return false;
    }
  }

  // إنشاء دفعة مالية
  static Future<Map<String, dynamic>?> createPayment({
    required int organizationId,
    required int schoolId,
    required int studentId,
    required double amount,
    required String paymentType,
    String? paymentMethod,
    DateTime? paymentDate,
    DateTime? dueDate,
    String status = 'pending',
    String? receiptNumber,
    String? notes,
    String? academicYear,
    String? term,
    double discountAmount = 0,
    String? createdBy,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client.from('payments').insert({
        'organization_id': organizationId,
        'school_id': schoolId,
        'student_id': studentId,
        'amount': amount,
        'payment_type': paymentType,
        'payment_method': paymentMethod,
        'payment_date': (paymentDate ?? DateTime.now()).toIso8601String().split('T')[0],
        'due_date': dueDate?.toIso8601String().split('T')[0],
        'status': status,
        'receipt_number': receiptNumber,
        'notes': notes,
        'academic_year': academicYear,
        'term': term,
        'discount_amount': discountAmount,
        'created_by': createdBy,
      }).select().single();
      
      return response;
    } catch (e) {
      print('❌ خطأ في إنشاء الدفعة: $e');
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
      print('❌ خطأ في جلب المدارس: $e');
      return [];
    }
  }

  // جلب جميع طلاب المدرسة
  static Future<List<Map<String, dynamic>>> getSchoolStudents(int schoolId) async {
    if (!_isEnabled) return [];
    
    try {
      final response = await client
          .from('students')
          .select('*')
          .eq('school_id', schoolId)
          .eq('status', 'active')
          .order('full_name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب الطلاب: $e');
      return [];
    }
  }

  // جلب جميع صفوف المدرسة
  static Future<List<Map<String, dynamic>>> getSchoolClasses(int schoolId) async {
    if (!_isEnabled) return [];
    
    try {
      final response = await client
          .from('classes')
          .select('*')
          .eq('school_id', schoolId)
          .eq('is_active', true)
          .order('grade_level, class_name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب الصفوف: $e');
      return [];
    }
  }

  // جلب طلاب صف معين
  static Future<List<Map<String, dynamic>>> getClassStudents(int classId) async {
    if (!_isEnabled) return [];
    
    try {
      final response = await client
          .from('student_classes')
          .select('*, students(*)')
          .eq('class_id', classId)
          .eq('status', 'active');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب طلاب الصف: $e');
      return [];
    }
  }

  // جلب مدفوعات الطالب
  static Future<List<Map<String, dynamic>>> getStudentPayments(int studentId) async {
    if (!_isEnabled) return [];
    
    try {
      final response = await client
          .from('payments')
          .select('*')
          .eq('student_id', studentId)
          .order('payment_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب مدفوعات الطالب: $e');
      return [];
    }
  }

  // جلب إحصائيات المؤسسة
  static Future<Map<String, dynamic>?> getOrganizationStats(int organizationId) async {
    if (!_isEnabled) return null;
    
    try {
      final response = await client
          .from('license_stats_view')
          .select('*')
          .eq('organization_id', organizationId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات المؤسسة: $e');
      return null;
    }
  }

  // تحديث حالة الطالب
  static Future<bool> updateStudentStatus(int studentId, String status) async {
    if (!_isEnabled) return false;
    
    try {
      await client
          .from('students')
          .update({'status': status})
          .eq('id', studentId);
      
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث حالة الطالب: $e');
      return false;
    }
  }

  // تحديث حالة الدفعة
  static Future<bool> updatePaymentStatus(int paymentId, String status) async {
    if (!_isEnabled) return false;
    
    try {
      await client
          .from('payments')
          .update({'status': status})
          .eq('id', paymentId);
      
      return true;
    } catch (e) {
      print('❌ خطأ في تحديث حالة الدفعة: $e');
      return false;
    }
  }

  // حذف طالب (تعطيل)
  static Future<bool> deleteStudent(int studentId) async {
    if (!_isEnabled) return false;
    
    try {
      await client
          .from('students')
          .update({'status': 'inactive'})
          .eq('id', studentId);
      
      return true;
    } catch (e) {
      print('❌ خطأ في حذف الطالب: $e');
      return false;
    }
  }

  // حذف صف (تعطيل)
  static Future<bool> deleteClass(int classId) async {
    if (!_isEnabled) return false;
    
    try {
      await client
          .from('classes')
          .update({'is_active': false})
          .eq('id', classId);
      
      return true;
    } catch (e) {
      print('❌ خطأ في حذف الصف: $e');
      return false;
    }
  }

  // البحث عن الطلاب
  static Future<List<Map<String, dynamic>>> searchStudents({
    required int organizationId,
    int? schoolId,
    String? searchQuery,
    int? gradeLevel,
    String? section,
    String? status,
  }) async {
    if (!_isEnabled) return [];
    
    try {
      var query = client
          .from('students')
          .select('*')
          .eq('organization_id', organizationId);
      
      if (schoolId != null) {
        query = query.eq('school_id', schoolId);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('full_name.ilike.%$searchQuery%,student_id.ilike.%$searchQuery%,parent_name.ilike.%$searchQuery%');
      }
      
      if (gradeLevel != null) {
        query = query.eq('grade_level', gradeLevel);
      }
      
      if (section != null && section.isNotEmpty) {
        query = query.eq('section', section);
      }
      
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      } else {
        query = query.eq('status', 'active');
      }
      
      final response = await query.order('full_name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في البحث عن الطلاب: $e');
      return [];
    }
  }

  // إحصائيات مالية للمدرسة
  static Future<Map<String, dynamic>?> getSchoolFinancialStats({
    required int schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      var query = client
          .from('payments')
          .select('amount, status, payment_type')
          .eq('school_id', schoolId);
      
      if (startDate != null) {
        query = query.gte('payment_date', startDate.toIso8601String().split('T')[0]);
      }
      
      if (endDate != null) {
        query = query.lte('payment_date', endDate.toIso8601String().split('T')[0]);
      }
      
      final response = await query;
      
      double totalAmount = 0;
      double paidAmount = 0;
      double pendingAmount = 0;
      int totalPayments = response.length;
      int paidPayments = 0;
      int pendingPayments = 0;
      
      for (final payment in response) {
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
        final status = payment['status'] as String?;
        
        totalAmount += amount;
        
        if (status == 'paid') {
          paidAmount += amount;
          paidPayments++;
        } else if (status == 'pending') {
          pendingAmount += amount;
          pendingPayments++;
        }
      }
      
      return {
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'pending_amount': pendingAmount,
        'total_payments': totalPayments,
        'paid_payments': paidPayments,
        'pending_payments': pendingPayments,
        'collection_rate': totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0,
      };
    } catch (e) {
      print('❌ خطأ في جلب الإحصائيات المالية: $e');
      return null;
    }
  }

  // تقرير حضور الطلاب
  static Future<Map<String, dynamic>?> getAttendanceReport({
    required int classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isEnabled) return null;
    
    try {
      // هذه دالة مؤقتة - ستحتاج لإضافة جدول الحضور لاحقاً
      final students = await getClassStudents(classId);
      
      return {
        'total_students': students.length,
        'attendance_data': students.map((student) => {
          'student_id': student['student_id'],
          'student_name': student['students']['full_name'],
          'attendance_percentage': 95.0, // مؤقت
        }).toList(),
      };
    } catch (e) {
      print('❌ خطأ في تقرير الحضور: $e');
      return null;
    }
  }
}
