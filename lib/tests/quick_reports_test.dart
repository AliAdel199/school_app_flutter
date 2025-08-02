import 'package:isar/isar.dart';

import '../services/supabase_service.dart';
import '../services/reports_supabase_service.dart';

/// اختبار سريع لرفع وجلب التقارير
Future<void> quickReportsTest() async {
  print('🔄 بدء اختبار التقارير...');
  
  try {
    // 1. التحقق من اتصال Supabase أولاً
    try {
      final supabaseSchools = await SupabaseService.client
          .from('schools')
          .select('id, name, organization_id')
          .limit(3);
      
      print('☁️ عدد المدارس في Supabase: ${supabaseSchools.length}');
      
      if (supabaseSchools.isNotEmpty) {
        final supabaseSchool = supabaseSchools.first;
        print('☁️ أول مدرسة في Supabase: ${supabaseSchool['name']}');
        
        // 2. جلب التقارير الموجودة
        final existingReports = await ReportsSupabaseService.getSchoolReports(
          schoolId: supabaseSchool['id'],
        );
        
        print('📊 عدد التقارير الموجودة: ${existingReports.length}');
        
        // 3. طباعة تفاصيل التقارير الموجودة
        for (int i = 0; i < existingReports.length && i < 3; i++) {
          final report = existingReports[i];
          print('📄 تقرير ${i + 1}: ${report['report_title']}');
          print('   - السنة: ${report['academic_year']}');
          print('   - عدد الطلاب: ${report['total_students']}');
          print('   - الرصيد الصافي: ${report['net_balance']} د.ع');
        }
        
        // 4. رفع تقرير تجريبي جديد
        print('🔄 رفع تقرير تجريبي...');
        final uploadResult = await ReportsSupabaseService.uploadGeneralReport(
          organizationId: supabaseSchool['organization_id'],
          schoolId: supabaseSchool['id'],
          academicYear: '2024-2025',
          totalStudents: 125,
          activeStudents: 120,
          inactiveStudents: 5,
          graduatedStudents: 0,
          withdrawnStudents: 0,
          totalAnnualFees: 12500000,
          totalPaid: 10000000,
          totalDue: 2500000,
          totalIncomes: 10000000,
          totalExpenses: 7000000,
          netBalance: 3000000,
          reportGeneratedBy: 'اختبار سريع',
        );
        
        if (uploadResult != null) {
          print('✅ تم رفع التقرير التجريبي بنجاح: ${uploadResult['id']}');
          
          // 5. جلب التقارير المحدثة
          final updatedReports = await ReportsSupabaseService.getSchoolReports(
            schoolId: supabaseSchool['id'],
          );
          
          print('📊 عدد التقارير بعد الرفع: ${updatedReports.length}');
        } else {
          print('❌ فشل في رفع التقرير التجريبي');
        }
        
      } else {
        print('❌ لا توجد مدارس في Supabase');
      }
      
    } catch (e) {
      print('❌ خطأ في اتصال Supabase: $e');
    }
    
  } catch (e) {
    print('❌ خطأ عام في الاختبار: $e');
  }
  
  print('✅ انتهى اختبار التقارير');
}
