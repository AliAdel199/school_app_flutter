import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/reports_supabase_service.dart';

/// شاشة عرض التقارير المرفوعة إلى Supabase
/// تُستخدم لعرض وإدارة التقارير المحفوظة في السحابة
class UploadedReportsScreen extends StatefulWidget {
  final int organizationId;
  final int? schoolId; // اختياري - إذا لم يتم تمريره، سيتم عرض تقارير جميع المدارس

  const UploadedReportsScreen({
    super.key,
    required this.organizationId,
    this.schoolId,
  });

  @override
  State<UploadedReportsScreen> createState() => _UploadedReportsScreenState();
}

class _UploadedReportsScreenState extends State<UploadedReportsScreen> {
  List<Map<String, dynamic>> reports = [];
  List<String> academicYears = [];
  String? selectedAcademicYear;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
    loadAcademicYears();
  }

  /// تحميل التقارير من Supabase
  Future<void> loadReports() async {
    setState(() => isLoading = true);
    try {
      List<Map<String, dynamic>> fetchedReports;
      
      print('🔄 جلب التقارير - organizationId: ${widget.organizationId}, schoolId: ${widget.schoolId}');
      
      if (widget.schoolId != null) {
        // تقارير مدرسة واحدة
        print('📊 جلب تقارير المدرسة ${widget.schoolId}...');
        print(widget.organizationId);
        fetchedReports = await ReportsSupabaseService.getSchoolReports(
          schoolId: widget.schoolId!,
          academicYear: selectedAcademicYear,
        );
        print('✅ تم جلب ${fetchedReports.length} تقرير للمدرسة');
      } else {
        // تقارير جميع مدارس المؤسسة
        print('📊 جلب تقارير المؤسسة ${widget.organizationId}...');
        fetchedReports = await ReportsSupabaseService.getOrganizationReports(
          organizationId: widget.organizationId,
          academicYear: selectedAcademicYear,
        );
        print('✅ تم جلب ${fetchedReports.length} تقرير للمؤسسة');
      }
      
      setState(() {
        reports = fetchedReports;
      });
      
      if (fetchedReports.isEmpty) {
        print('⚠️ لا توجد تقارير متوفرة');
      }
      
    } catch (e) {
      print('❌ خطأ في تحميل التقارير: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل التقارير: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: loadReports,
          ),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// تحميل السنوات الدراسية المتوفرة
  Future<void> loadAcademicYears() async {
    try {
      final years = await ReportsSupabaseService.getAvailableAcademicYears(
        widget.organizationId,
      );
      setState(() {
        academicYears = years;
      });
    } catch (e) {
      debugPrint('خطأ في تحميل السنوات الدراسية: $e');
    }
  }

  /// حذف تقرير
  Future<void> deleteReport(int reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا التقرير؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReportsSupabaseService.deleteReport(reportId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التقرير بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        loadReports(); // إعادة تحميل القائمة
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف التقرير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schoolId != null 
            ? 'التقارير المرفوعة للمدرسة' 
            : 'التقارير المرفوعة للمؤسسة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadReports,
          ),
        ],
      ),
      body: Column(
        children: [
          // فلتر السنة الدراسية
          if (academicYears.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('السنة الدراسية: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedAcademicYear,
                      hint: const Text('جميع السنوات'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('جميع السنوات'),
                        ),
                        ...academicYears.map((year) => DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedAcademicYear = value;
                        });
                        loadReports();
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // قائمة التقارير
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : reports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assessment, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد تقارير مرفوعة',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.schoolId != null 
                                  ? 'لم يتم رفع أي تقارير لهذه المدرسة بعد'
                                  : 'لم يتم رفع أي تقارير لهذه المؤسسة بعد',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(width: 200,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/reportsscreen');
                                },
                                icon: const Icon(Icons.add_chart),
                                label: const Text('إنشاء تقرير جديد'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              title: Text(
                                report['report_title'] ?? 'تقرير عام',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('السنة الدراسية: ${report['academic_year'] ?? 'غير محدد'}'),
                                  Text('تاريخ الإنشاء: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(report['generated_at']))}'),
                                  if (widget.schoolId == null && report['schools'] != null)
                                    Text('المدرسة: ${report['schools']['name']}'),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      // إحصائيات الطلاب
                                      _buildStatsSection('إحصائيات الطلاب', [
                                        _buildStatRow('إجمالي الطلاب', '${report['total_students']}'),
                                        _buildStatRow('الفعالين', '${report['active_students']}'),
                                        _buildStatRow('غير الفعالين', '${report['inactive_students']}'),
                                        _buildStatRow('الخريجين', '${report['graduated_students']}'),
                                        _buildStatRow('المنسحبين', '${report['withdrawn_students']}'),
                                      ]),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // الإحصائيات المالية
                                      _buildStatsSection('الإحصائيات المالية', [
                                        _buildStatRow('إجمالي الأقساط', '${formatter.format(report['total_annual_fees'])} د.ع'),
                                        _buildStatRow('المدفوع', '${formatter.format(report['total_paid'])} د.ع'),
                                        _buildStatRow('المتبقي', '${formatter.format(report['total_due'])} د.ع'),
                                        _buildStatRow('الإيرادات', '${formatter.format(report['total_incomes'])} د.ع'),
                                        _buildStatRow('المصروفات', '${formatter.format(report['total_expenses'])} د.ع'),
                                        _buildStatRow('الرصيد الصافي', '${formatter.format(report['net_balance'])} د.ع',
                                            color: (report['net_balance'] as num) >= 0 ? Colors.green : Colors.red),
                                      ]),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // أزرار الإجراءات
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(width: 200,
                                            child: ElevatedButton.icon(
                                              onPressed: () => deleteReport(report['id']),
                                              icon: const Icon(Icons.delete, size: 16),
                                              label: const Text('حذف'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
