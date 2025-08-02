import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// خدمة إدارة التقارير في Supabase
/// تُستخدم لرفع وإدارة التقارير العامة للمدارس
class ReportsSupabaseService {
  static final SupabaseClient _supabase = SupabaseService.client;

  /// رفع تقرير عام للمدرسة إلى Supabase
  static Future<Map<String, dynamic>?> uploadGeneralReport({
    required int organizationId,
    required int schoolId,
    String? academicYear,
    DateTime? periodStart,
    DateTime? periodEnd,
    required int totalStudents,
    required int activeStudents,
    required int inactiveStudents,
    required int graduatedStudents,
    required int withdrawnStudents,
    required double totalAnnualFees,
    required double totalPaid,
    required double totalDue,
    required double totalIncomes,
    required double totalExpenses,
    required double netBalance,
    Map<String, dynamic>? additionalData,
    String? reportGeneratedBy,
  }) async {
    try {
      final reportData = {
        'organization_id': organizationId,
        'school_id': schoolId,
        'report_title': 'التقرير العام${academicYear != null ? ' - $academicYear' : ''}',
        'report_type': 'general',
        'academic_year': academicYear,
        'period_start': periodStart?.toIso8601String(),
        'period_end': periodEnd?.toIso8601String(),
        'total_students': totalStudents,
        'active_students': activeStudents,
        'inactive_students': inactiveStudents,
        'graduated_students': graduatedStudents,
        'withdrawn_students': withdrawnStudents,
        'total_annual_fees': totalAnnualFees,
        'total_paid': totalPaid,
        'total_due': totalDue,
        'total_incomes': totalIncomes,
        'total_expenses': totalExpenses,
        'net_balance': netBalance,
        'additional_data': additionalData,
        'report_generated_by': reportGeneratedBy,
        'generated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('school_reports')
          .insert(reportData)
          .select()
          .single();

      print('✅ تم رفع التقرير بنجاح: ${response['id']}');
      return response;
    } catch (e) {
      print('❌ خطأ في رفع التقرير: $e');
      rethrow;
    }
  }

  /// جلب التقارير الخاصة بمدرسة معينة
  static Future<List<Map<String, dynamic>>> getSchoolReports({
    required int schoolId,
    String? academicYear,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('school_reports')
          .select()
          .eq('school_id', schoolId);

      if (academicYear != null) {
        query = query.eq('academic_year', academicYear);
      }

      final response = await query
          .order('generated_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب التقارير: $e');
      rethrow;
    }
  }

  /// جلب التقارير الخاصة بمؤسسة معينة (جميع المدارس)
  static Future<List<Map<String, dynamic>>> getOrganizationReports({
    required int organizationId,
    String? academicYear,
    int limit = 100,
  }) async {
    try {
      var query = _supabase
          .from('school_reports')
          .select('''
            *,
            schools!inner(name, school_type)
          ''')
          .eq('organization_id', organizationId);

      if (academicYear != null) {
        query = query.eq('academic_year', academicYear);
      }

      final response = await query
          .order('generated_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ خطأ في جلب تقارير المؤسسة: $e');
      rethrow;
    }
  }

  /// حذف تقرير معين
  static Future<void> deleteReport(int reportId) async {
    try {
      await _supabase
          .from('school_reports')
          .delete()
          .eq('id', reportId);

      print('✅ تم حذف التقرير بنجاح: $reportId');
    } catch (e) {
      print('❌ خطأ في حذف التقرير: $e');
      rethrow;
    }
  }

  /// تحديث تقرير موجود
  static Future<Map<String, dynamic>?> updateReport({
    required int reportId,
    Map<String, dynamic>? updateData,
  }) async {
    try {
      final response = await _supabase
          .from('school_reports')
          .update({
            ...?updateData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId)
          .select()
          .single();

      print('✅ تم تحديث التقرير بنجاح: $reportId');
      return response;
    } catch (e) {
      print('❌ خطأ في تحديث التقرير: $e');
      rethrow;
    }
  }

  /// الحصول على إحصائيات سريعة للمؤسسة
  static Future<Map<String, dynamic>> getOrganizationStats(int organizationId) async {
    try {
      final reports = await _supabase
          .from('school_reports')
          .select()
          .eq('organization_id', organizationId)
          .order('generated_at', ascending: false);

      if (reports.isEmpty) {
        return {
          'total_reports': 0,
          'total_schools': 0,
          'latest_report_date': null,
          'total_students_across_schools': 0,
          'total_balance_across_schools': 0.0,
        };
      }

      // حساب الإحصائيات
      final totalReports = reports.length;
      final schoolIds = reports.map((r) => r['school_id']).toSet();
      final totalSchools = schoolIds.length;
      final latestReportDate = reports.first['generated_at'];
      
      // جمع الطلاب والأرصدة من آخر تقرير لكل مدرسة
      Map<int, Map<String, dynamic>> latestBySchool = {};
      for (var report in reports) {
        final schoolId = report['school_id'] as int;
        if (!latestBySchool.containsKey(schoolId)) {
          latestBySchool[schoolId] = report;
        }
      }

      int totalStudents = 0;
      double totalBalance = 0.0;
      
      for (var report in latestBySchool.values) {
        totalStudents += (report['total_students'] as int? ?? 0);
        totalBalance += (report['net_balance'] as num? ?? 0).toDouble();
      }

      return {
        'total_reports': totalReports,
        'total_schools': totalSchools,
        'latest_report_date': latestReportDate,
        'total_students_across_schools': totalStudents,
        'total_balance_across_schools': totalBalance,
      };
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات المؤسسة: $e');
      rethrow;
    }
  }

  /// جلب السنوات الدراسية المتوفرة في التقارير
  static Future<List<String>> getAvailableAcademicYears(int organizationId) async {
    try {
      final response = await _supabase
          .from('school_reports')
          .select('academic_year')
          .eq('organization_id', organizationId)
          .not('academic_year', 'is', null);

      final years = response
          .map((r) => r['academic_year'] as String)
          .where((year) => year.isNotEmpty)
          .toSet()
          .toList();

      years.sort((a, b) => b.compareTo(a)); // ترتيب تنازلي
      return years;
    } catch (e) {
      print('❌ خطأ في جلب السنوات الدراسية: $e');
      rethrow;
    }
  }
}
