import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'services/reports_supabase_service.dart';
import 'tests/quick_reports_test.dart';

/// اختبار جلب التقارير من Supabase
class TestFetchReports extends StatefulWidget {
  const TestFetchReports({super.key});

  @override
  State<TestFetchReports> createState() => _TestFetchReportsState();
}

class _TestFetchReportsState extends State<TestFetchReports> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    testSupabaseConnection();
    // تشغيل اختبار سريع في وحدة التحكم
    quickReportsTest();
  }

  /// اختبار اتصال Supabase
  Future<void> testSupabaseConnection() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('🔄 اختبار اتصال Supabase...');
      
      // اختبار الاتصال بجدول المدارس
      final schools = await SupabaseService.client
          .from('schools')
          .select('id, name, organization_id')
          .limit(5);
      
      print('✅ عدد المدارس: ${schools.length}');
      
      if (schools.isNotEmpty) {
        // جلب التقارير للمدرسة الأولى
        final firstSchool = schools.first;
        print('🏫 اختبار مع المدرسة: ${firstSchool['name']}');
        
        final schoolReports = await ReportsSupabaseService.getSchoolReports(
          schoolId: firstSchool['id'],
        );
        
        print('📊 عدد تقارير المدرسة: ${schoolReports.length}');
        
        // جلب تقارير المؤسسة
        final orgReports = await ReportsSupabaseService.getOrganizationReports(
          organizationId: firstSchool['organization_id'],
        );
        
        print('🏢 عدد تقارير المؤسسة: ${orgReports.length}');
        
        setState(() {
          reports = orgReports;
        });
      }
      
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// اختبار رفع تقرير تجريبي
  Future<void> uploadTestReport() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // جلب أول مدرسة
      final schools = await SupabaseService.client
          .from('schools')
          .select('id, name, organization_id')
          .limit(1);
      
      if (schools.isNotEmpty) {
        final school = schools.first;
        
        final result = await ReportsSupabaseService.uploadGeneralReport(
          organizationId: school['organization_id'],
          schoolId: school['id'],
          academicYear: '2024-2025',
          totalStudents: 150,
          activeStudents: 140,
          inactiveStudents: 10,
          graduatedStudents: 0,
          withdrawnStudents: 0,
          totalAnnualFees: 15000000,
          totalPaid: 12000000,
          totalDue: 3000000,
          totalIncomes: 12000000,
          totalExpenses: 8000000,
          netBalance: 4000000,
          reportGeneratedBy: 'نظام الاختبار',
        );
        
        print('✅ تم رفع التقرير التجريبي: ${result?['id']}');
        
        // إعادة جلب التقارير
        testSupabaseConnection();
      }
      
    } catch (e) {
      print('❌ خطأ في رفع التقرير: $e');
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار جلب التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: testSupabaseConnection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أزرار الاختبار
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : testSupabaseConnection,
                  child: const Text('اختبار الاتصال'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : uploadTestReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('رفع تقرير تجريبي'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // حالة التحميل
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            
            // رسالة الخطأ
            if (error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  'خطأ: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            
            // قائمة التقارير
            const SizedBox(height: 16),
            Text(
              'التقارير المجلوبة (${reports.length}):',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: reports.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد تقارير',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Card(
                          child: ListTile(
                            title: Text(report['report_title'] ?? 'تقرير عام'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('السنة: ${report['academic_year'] ?? 'غير محدد'}'),
                                Text('المدرسة: ${report['schools']?['name'] ?? 'غير محدد'}'),
                                Text('الطلاب: ${report['total_students']}'),
                                Text('الرصيد الصافي: ${report['net_balance']} د.ع'),
                              ],
                            ),
                            trailing: Text(
                              'ID: ${report['id']}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
