import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/reports_supabase_service.dart';

/// شاشة تشخيص مشاكل جلب التقارير
class ReportsDiagnosticScreen extends StatefulWidget {
  const ReportsDiagnosticScreen({super.key});

  @override
  State<ReportsDiagnosticScreen> createState() => _ReportsDiagnosticScreenState();
}

class _ReportsDiagnosticScreenState extends State<ReportsDiagnosticScreen> {
  List<String> diagnosticLogs = [];
  bool isRunning = false;

  void addLog(String message) {
    setState(() {
      diagnosticLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> runDiagnostic() async {
    setState(() {
      isRunning = true;
      diagnosticLogs.clear();
    });

    addLog('🔄 بدء تشخيص نظام التقارير...');

    try {
      // 1. اختبار اتصال Supabase الأساسي
      addLog('1️⃣ اختبار اتصال Supabase...');
      await SupabaseService.client
          .from('school_reports')
          .select('count')
          .limit(1);
      addLog('✅ اتصال Supabase يعمل');

      // 2. فحص جدول school_reports
      addLog('2️⃣ فحص جدول school_reports...');
      final reportsCount = await SupabaseService.client
          .from('school_reports')
          .select('id')
          .count();
      addLog('📊 عدد التقارير في قاعدة البيانات: ${reportsCount.count}');

      // 3. فحص جدول schools
      addLog('3️⃣ فحص جدول schools...');
      final schoolsData = await SupabaseService.client
          .from('schools')
          .select('id, name, organization_id')
          .limit(5);
      addLog('🏫 عدد المدارس المتوفرة: ${schoolsData.length}');
      
      if (schoolsData.isNotEmpty) {
        for (var school in schoolsData) {
          addLog('   - مدرسة: ${school['name']} (ID: ${school['id']}, Org: ${school['organization_id']})');
        }

        // 4. اختبار جلب التقارير لأول مدرسة
        final firstSchool = schoolsData.first;
        addLog('4️⃣ اختبار جلب تقارير المدرسة: ${firstSchool['name']}...');
        
        try {
          final schoolReports = await ReportsSupabaseService.getSchoolReports(
            schoolId: firstSchool['id'],
          );
          addLog('📄 عدد تقارير المدرسة: ${schoolReports.length}');
          
          if (schoolReports.isNotEmpty) {
            final report = schoolReports.first;
            addLog('   - آخر تقرير: ${report['report_title']} (${report['academic_year']})');
          }
        } catch (e) {
          addLog('❌ خطأ في جلب تقارير المدرسة: $e');
        }

        // 5. اختبار جلب تقارير المؤسسة
        addLog('5️⃣ اختبار جلب تقارير المؤسسة ${firstSchool['organization_id']}...');
        
        try {
          final orgReports = await ReportsSupabaseService.getOrganizationReports(
            organizationId: firstSchool['organization_id'],
          );
          addLog('🏢 عدد تقارير المؤسسة: ${orgReports.length}');
          
          if (orgReports.isNotEmpty) {
            final report = orgReports.first;
            addLog('   - آخر تقرير: ${report['report_title']}');
            addLog('   - المدرسة: ${report['schools']?['name'] ?? 'غير محدد'}');
          }
        } catch (e) {
          addLog('❌ خطأ في جلب تقارير المؤسسة: $e');
        }

        // 6. اختبار رفع تقرير تجريبي
        addLog('6️⃣ اختبار رفع تقرير تجريبي...');
        
        try {
          final testReport = await ReportsSupabaseService.uploadGeneralReport(
            organizationId: firstSchool['organization_id'],
            schoolId: firstSchool['id'],
            academicYear: '2024-2025',
            totalStudents: 100,
            activeStudents: 95,
            inactiveStudents: 5,
            graduatedStudents: 0,
            withdrawnStudents: 0,
            totalAnnualFees: 10000000,
            totalPaid: 8000000,
            totalDue: 2000000,
            totalIncomes: 8000000,
            totalExpenses: 6000000,
            netBalance: 2000000,
            reportGeneratedBy: 'تشخيص النظام',
          );
          
          if (testReport != null) {
            addLog('✅ تم رفع التقرير التجريبي بنجاح: ${testReport['id']}');
          }
        } catch (e) {
          addLog('❌ خطأ في رفع التقرير التجريبي: $e');
        }

      } else {
        addLog('❌ لا توجد مدارس في قاعدة البيانات');
      }

      // 7. فحص جدول educational_organizations
      addLog('7️⃣ فحص جدول educational_organizations...');
      try {
        final orgsData = await SupabaseService.client
            .from('educational_organizations')
            .select('id, name')
            .limit(3);
        addLog('🏢 عدد المؤسسات التعليمية: ${orgsData.length}');
        
        for (var org in orgsData) {
          addLog('   - مؤسسة: ${org['name']} (ID: ${org['id']})');
        }
      } catch (e) {
        addLog('❌ خطأ في جلب المؤسسات: $e');
      }

      addLog('✅ انتهى التشخيص بنجاح');

    } catch (e) {
      addLog('❌ خطأ عام في التشخيص: $e');
    } finally {
      setState(() {
        isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تشخيص نظام التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isRunning ? null : runDiagnostic,
          ),
        ],
      ),
      body: Column(
        children: [
          // زر التشخيص
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isRunning ? null : runDiagnostic,
                icon: isRunning 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bug_report),
                label: Text(isRunning ? 'جاري التشخيص...' : 'بدء التشخيص'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          
          // سجل التشخيص
          Expanded(
            child: diagnosticLogs.isEmpty
                ? const Center(
                    child: Text(
                      'اضغط "بدء التشخيص" لفحص النظام',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: diagnosticLogs.length,
                    itemBuilder: (context, index) {
                      final log = diagnosticLogs[index];
                      Color textColor = Colors.black;
                      
                      if (log.contains('❌')) {
                        textColor = Colors.red;
                      } else if (log.contains('✅')) {
                        textColor = Colors.green;
                      } else if (log.contains('🔄') || log.contains('️⃣')) {
                        textColor = Colors.blue;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: textColor == Colors.red 
                              ? Colors.red.withOpacity(0.1)
                              : textColor == Colors.green
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
