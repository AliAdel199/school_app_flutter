import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
    import 'dart:io';
    import 'package:excel/excel.dart';
    import 'package:path_provider/path_provider.dart';
      import 'package:file_picker/file_picker.dart';

import '../main.dart';

class SalaryReportScreen extends StatefulWidget {
  const SalaryReportScreen({super.key});

  @override
  State<SalaryReportScreen> createState() => _SalaryReportScreenState();
}

class _SalaryReportScreenState extends State<SalaryReportScreen> {
  final supabase = Supabase.instance.client;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Map<String, dynamic>> salaries = [];
  bool isLoading = false;
  double totalNetSalary = 0;

  Future<void> fetchSalaries() async {
    setState(() {
      isLoading = true;
      totalNetSalary = 0;
    });

    final salaryMonth = DateFormat('yyyy-MM-01').format(selectedMonth);

    try {
      final data = await supabase
          .from('employee_salaries')
          .select('*, employees(full_name)')
          .eq('salary_month', salaryMonth);

      salaries = List<Map<String, dynamic>>.from(data);

      totalNetSalary = salaries.fold(0.0, (sum, item) {
        final net = (item['net_salary'] ?? 0) as num;
        return sum + net.toDouble();
      });

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل الرواتب: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    fetchSalaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الرواتب')),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
        Row(
          children: [
          const Text('الشهر:'),
          const SizedBox(width: 10),
          DropdownButton<DateTime>(
            value: selectedMonth,
            items: List.generate(12, (index) {
            final date = DateTime(DateTime.now().year, index + 1);
            return DropdownMenuItem(
              value: date,
              child: Text(DateFormat('MMMM yyyy', 'ar').format(date)),
            );
            }),
            onChanged: (val) {
            if (val != null) {
              setState(() => selectedMonth = val);
              fetchSalaries();
            }
            },
          ),
          Spacer(),
        
          SizedBox(width: 150,
            child: ElevatedButton.icon(
              onPressed: exportToExcel,
              icon: const Icon(Icons.file_download),
              label: const Text('تصدير إلى Excel'),
            ),
          ),

          ],
        ),
        const SizedBox(height: 16),
        if (isLoading) const CircularProgressIndicator(),
        if (!isLoading && salaries.isEmpty)
          const Text('لا توجد بيانات لهذا الشهر'),
        if (!isLoading && salaries.isNotEmpty)
          Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
            columns: const [
              DataColumn(label: Text('الموظف', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الراتب الاسمي', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('المخصصات', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الاستقطاعات', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الخصم الإضافي', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('المكافأة', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الصافي', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ملاحظات', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: salaries.map((s) {
              return DataRow(
              cells: [
                DataCell(Text(s['employees']['full_name'] ?? '')),
                DataCell(Text('${s['base_salary'] ?? ''}')),
                DataCell(Text('${s['total_allowances'] ?? ''}')),
                DataCell(Text('${s['total_deductions'] ?? ''}')),
                DataCell(Text('${s['extra_deduction'] ?? ''}')),
                DataCell(Text('${s['extra_allowance'] ?? ''}')),
                DataCell(Text('${s['net_salary'] ?? ''} د.ع')),
                DataCell(Text(s['notes'] ?? '---')),
              ],
              );
            }).toList(),
            ),
          ),
          ),
        const SizedBox(height: 8),
        if (!isLoading)
          Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'إجمالي الرواتب الصافية: ${totalNetSalary.toStringAsFixed(2)} د.ع',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ),
        ],
      ),
      ),
    );
  }
  Future<void> exportToExcel() async {
    // Add these dependencies in pubspec.yaml:
    // excel: ^2.0.6
    // path_provider: ^2.0.15
    // permission_handler: ^11.3.1



    final excel = Excel.createExcel();
    final sheet = excel['رواتب'];

    // Add header row
    sheet.appendRow([
     TextCellValue('الموظف'),
      TextCellValue('الراتب الاسمي'),
      TextCellValue('المخصصات'),
      TextCellValue('الاستقطاعات'),
      TextCellValue('الخصم الإضافي'),
      TextCellValue('المكافأة'),
      TextCellValue('الصافي'),
      TextCellValue('ملاحظات')
    ]);

    // Add data rows
    for (var s in salaries) {
      sheet.appendRow([
        TextCellValue(s['employees']['full_name'] ?? ''),
        TextCellValue('${s['base_salary'] ?? ''}'),
        TextCellValue('${s['total_allowances'] ?? ''}'),
        TextCellValue('${s['total_deductions'] ?? ''}'),
        TextCellValue('${s['extra_deduction'] ?? ''}'),
        TextCellValue('${s['extra_allowance'] ?? ''}'),
        TextCellValue('${s['net_salary'] ?? ''} د.ع'),
        TextCellValue(s['notes'] ?? '---'),
      ]);
    }

    // Request storage permission
      // اختيار مكان الحفظ باستخدام FilePicker
      // أضف dependency: file_picker: ^6.1.1 في pubspec.yaml

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'اختر مكان حفظ ملف Excel',
        fileName: 'salary_report_${DateFormat('yyyy_MM').format(selectedMonth)}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(excel.encode()!);
      } else {
        // المستخدم ألغى الاختيار
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تصدير التقرير إلى ملف Excel بنجاح')),
        );
      }
 
  }
}
