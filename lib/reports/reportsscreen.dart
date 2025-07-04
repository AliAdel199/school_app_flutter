import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pdf/pdf.dart';
import '/localdatabase/expense.dart';
import '/localdatabase/income.dart';
import '/localdatabase/student.dart';
import '/localdatabase/student_fee_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../main.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  int totalStudents = 0;
  int activeStudents = 0;
  int inactiveStudents = 0;
  int graduatedStudents = 0;
  int withdrawnStudents = 0;

  double totalAnnualFees = 0;
  double totalPaid = 0;
  double totalDue = 0;

  double totalIncomes = 0;
  double totalExpenses = 0;
  double netBalance = 0;

  DateTime? startDate;
  DateTime? endDate;

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    // افتراضياً يعرض جميع البيانات بدون فلترة، بإمكانك وضع فلترة أولية مثلاً شهر واحد سابق

    startDate=DateTime.now().subtract(Duration(days: 1));
    endDate = DateTime.now().add(Duration(days: 1));

        fetchReportData();
  }
  // استبدل fetchReportData للعمل مع Isar بدلاً من Supabase
  // تأكد من استيراد مكتبة isar المناسبة في أعلى الملف:
  // import 'package:isar/isar.dart';
  // import 'package:path_provider/path_provider.dart';
  // import 'your_isar_collections.dart'; // استبدلها بملف تعريف Collections الخاص بك




  Future<void> fetchReportData() async {
    setState(() => isLoading = true);
    try {
      totalStudents = 0;
      activeStudents = 0;
      inactiveStudents = 0;
      graduatedStudents = 0;
      withdrawnStudents = 0;
      totalAnnualFees = 0;
      totalPaid = 0;
      totalDue = 0;
      totalIncomes = 0;
      totalExpenses = 0;
      netBalance = 0;

      // جلب الطلاب
      final students = await isar.students.where().findAll();
      totalStudents = students.length;
      activeStudents = students.where((s) => s.status == 'active').length;
      inactiveStudents = students.where((s) => s.status == 'inactive').length;
      graduatedStudents = students.where((s) => s.status == 'graduated').length;
      withdrawnStudents = students.where((s) => s.status == 'منسحب').length;

      final studentIds = students.map((s) => s.id).toList();

      // جلب الأقساط
      final fees = await isar.studentFeeStatus
          .where().findAll();

      for (var fee in fees) {
        totalAnnualFees += (fee.annualFee ?? 0).toDouble();
        totalPaid += (fee.paidAmount ?? 0).toDouble();
        totalDue += (fee.dueAmount ?? 0).toDouble();
      }
// جلب الإيرادات بين تاريخين
final incomes = await isar.incomes
    .filter()
    .incomeDateBetween(startDate!, endDate!)
    .findAll();

totalIncomes = incomes.fold(0.0, (sum, i) => sum + (i.amount ?? 0));

// جلب المصروفات بين تاريخين
final expenses = await isar.expenses
    .filter()
    .expenseDateBetween(startDate!, endDate!)
    .findAll();

totalExpenses = expenses.fold(0.0, (sum, e) => sum + (e.amount ?? 0));

      netBalance = totalIncomes - totalExpenses;
    } catch (e) {
      debugPrint('خطأ في تحميل التقارير من Isar: \n$e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  // Future<void> fetchReportData() async {
  //   setState(() => isLoading = true);
  //   try {
  //     totalStudents = 0;
  //     activeStudents = 0;
  //     inactiveStudents = 0;
  //     graduatedStudents = 0;
  //     withdrawnStudents = 0;
  //     totalAnnualFees = 0;
  //     totalPaid = 0;
  //     totalDue = 0;
  //     totalIncomes = 0;
  //     totalExpenses = 0;
  //     netBalance = 0;

  //     final userId = supabase.auth.currentUser!.id;
  //     final profile = await supabase
  //         .from('profiles')
  //         .select('school_id')
  //         .eq('id', userId)
  //         .single();
  //     final schoolId = profile['school_id'];

  //     final studentsRes = await supabase
  //         .from('students')
  //         .select('id, status')
  //         .eq('school_id', schoolId);

  //     final students = List<Map<String, dynamic>>.from(studentsRes);
  //     totalStudents = students.length;
  //     activeStudents = students.where((s) => s['status'] == 'active').length;
  //     inactiveStudents = students.where((s) => s['status'] == 'inactive').length;
  //     graduatedStudents = students.where((s) => s['status'] == 'graduated').length;
  //     withdrawnStudents = students.where((s) => s['status'] == 'منسحب').length;

  //     final studentIds = students.map((s) => s['id']).toList();

  //     // الأقساط الدراسية غير مرتبطة مباشرة بفترة زمنية، تُعرض كلها
  //     final feeRes = await supabase
  //         .from('student_fee_status')
  //         .select('annual_fee, paid_amount, due_amount, student_id')
  //         .inFilter('student_id', studentIds);
  //     final fees = List<Map<String, dynamic>>.from(feeRes);

  //     for (var fee in fees) {
  //       totalAnnualFees += (fee['annual_fee'] ?? 0).toDouble();
  //       totalPaid += (fee['paid_amount'] ?? 0).toDouble();
  //       totalDue += (fee['due_amount'] ?? 0).toDouble();
  //     }

  //     // جلب الإيرادات والمصروفات حسب الفترة
  //     var incomeQuery = supabase
  //         .from('incomes')
  //         .select('amount, income_date')
  //         .eq('school_id', schoolId);

  //     var expenseQuery = supabase
  //         .from('expenses')
  //         .select('amount, expense_date')
  //         .eq('school_id', schoolId);

  //     if (startDate != null) {
  //       final from = DateFormat('yyyy-MM-dd').format(startDate!);
  //       incomeQuery = incomeQuery.gte('income_date', from);
  //       expenseQuery = expenseQuery.gte('expense_date', from);
  //     }
  //     if (endDate != null) {
  //       final to = DateFormat('yyyy-MM-dd').format(endDate!);
  //       incomeQuery = incomeQuery.lte('income_date', to);
  //       expenseQuery = expenseQuery.lte('expense_date', to);
  //     }

  //     final incomeRes = await incomeQuery;
  //     final expenseRes = await expenseQuery;

  //     totalIncomes = 0;
  //     for (var income in incomeRes) {
  //       totalIncomes += (income['amount'] ?? 0).toDouble();
  //     }
  //     totalExpenses = 0;
  //     for (var exp in expenseRes) {
  //       totalExpenses += (exp['amount'] ?? 0).toDouble();
  //     }
  //     netBalance = totalIncomes - totalExpenses;

  //   } catch (e) {
  //     debugPrint('خطأ في تحميل التقارير: \n$e');
  //   } finally {
  //     if (mounted) setState(() => isLoading = false);
  //   }
  // }

  Future<void> printReportPdf() async {
    final pdf = pw.Document();
    final formatter = NumberFormat('#,###');
    final arabicFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
    final boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Bold.ttf'));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'التقارير العامة',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                if (startDate != null || endDate != null)
                  pw.Text(
                    'الفترة: '
                    '${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '---'} '
                    'إلى '
                    '${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '---'}',
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                  ),
                pw.SizedBox(height: 16),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blueGrey, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Table(
                    border: pw.TableBorder.symmetric(
                      inside: const pw.BorderSide(color: PdfColors.blueGrey, width: 0.5),
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text('العنوان', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text('القيمة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                      _pdfTableRow('عدد الطلاب الكلي', '$totalStudents'),
                      _pdfTableRow('الطلاب الفعالين', '$activeStudents'),
                      _pdfTableRow('غير الفعالين', '$inactiveStudents'),
                      _pdfTableRow('الخريجين', '$graduatedStudents'),
                      _pdfTableRow('المنسحبين', '$withdrawnStudents'),
                      _pdfTableRow('مجموع الأقساط السنوية', '${formatter.format(totalAnnualFees)} د.ع'),
                      _pdfTableRow('المدفوع الكلي', '${formatter.format(totalPaid)} د.ع'),
                      _pdfTableRow('المتبقي الكلي', '${formatter.format(totalDue)} د.ع'),
                      _pdfTableRow('مجموع الإيرادات', '${formatter.format(totalIncomes)} د.ع'),
                      _pdfTableRow('مجموع المصروفات', '${formatter.format(totalExpenses)} د.ع'),
                      _pdfTableRow('الرصيد الصافي', '${formatter.format(netBalance)} د.ع'),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd – HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.TableRow _pdfTableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: pw.Text(title, style: const pw.TextStyle(fontSize: 13)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير العامة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'طباعة التقرير',
            onPressed: printReportPdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(startDate == null
                              ? 'من تاريخ'
                              : DateFormat('yyyy-MM-dd').format(startDate!)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => startDate = picked);
                          },
                        ),
                        const SizedBox(width: 10),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(endDate == null
                              ? 'إلى تاريخ'
                              : DateFormat('yyyy-MM-dd').format(endDate!)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => endDate = picked);
                          },
                        ),
                        const SizedBox(width: 12),
                        SizedBox(width: 150,
                          child: ElevatedButton(
                            onPressed: fetchReportData,
                            child: const Text('تطبيق الفلترة'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (startDate != null || endDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'إلغاء الفلترة',
                            onPressed: () {
                              setState(() {
                                startDate = null;
                                endDate = null;
                                fetchReportData();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Wrap(
                      spacing: 25,
                      runSpacing: 30,
                      children: [
                        _buildCard('عدد الطلاب الكلي', '$totalStudents', Colors.blue),
                        _buildCard('الطلاب الفعالين', '$activeStudents', Colors.green),
                        _buildCard('غير الفعالين', '$inactiveStudents', Colors.grey),
                        _buildCard('الخريجين', '$graduatedStudents', Colors.indigo),
                        _buildCard('المنسحبين', '$withdrawnStudents', Colors.orange),
                        _buildCard('مجموع الأقساط السنوية', '${formatter.format(totalAnnualFees)} د.ع', Colors.blue),
                        _buildCard('المدفوع الكلي', '${formatter.format(totalPaid)} د.ع', Colors.green),
                        _buildCard('المتبقي الكلي', '${formatter.format(totalDue)} د.ع', Colors.red),
                        _buildCard('مجموع الإيرادات', '${formatter.format(totalIncomes)} د.ع', Colors.teal),
                        _buildCard('مجموع المصروفات', '${formatter.format(totalExpenses)} د.ع', Colors.deepOrange),
                        _buildCard('الرصيد الصافي', '${formatter.format(netBalance)} د.ع',
                            netBalance >= 0 ? Colors.green : Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return SizedBox( 
      width: 200,
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
