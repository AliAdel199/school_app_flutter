import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pdf/pdf.dart';
import '/localdatabase/expense.dart';
import '/localdatabase/income.dart';
import '/localdatabase/student.dart';
import '/localdatabase/student_fee_status.dart';
import '/localdatabase/student_payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../main.dart';

/*
 * ملاحظة مهمة للمطورين:
 * 
 * للتأكد من عمل فلترة الإيرادات والمصروفات بالسنة الدراسية بشكل صحيح،
 * يجب ضمان ما يلي عند إضافة إيراد أو مصروف جديد:
 * 
 * 1. تعيين قيمة academicYear عند إنشاء الإيراد/المصروف:
 *    income.academicYear = academicYear; // المتغير العام للسنة الحالية
 *    expense.academicYear = academicYear;
 * 
 * 2. يجب أن تكون قيمة academicYear متطابقة في:
 *    - جدول students
 *    - جدول student_fee_status  
 *    - جدول student_payments
 *    - جدول incomes
 *    - جدول expenses
 * 
 * 3. تنسيق السنة الدراسية يجب أن يكون موحد (مثل: "2023-2024")
 * 
 * 4. تحديث المتغير العام academicYear في main.dart عند تغيير السنة
 */

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
  
  List<String> academicYears = [];
  String? selectedAcademicYear;

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    loadAcademicYears();
    // تعيين فترة زمنية افتراضية (العام الحالي) - ستظهر فقط إذا لم يتم اختيار سنة دراسية
    final now = DateTime.now();
    startDate = DateTime(now.year, 1, 1); // بداية السنة الحالية
    endDate = DateTime(now.year, 12, 31); // نهاية السنة الحالية

    fetchReportData();
  }
  
  Future<void> loadAcademicYears() async {
    try {
      // جلب السنوات من جدول student_fee_status
      final feeStatusYears = await isar.studentFeeStatus
          .where()
          .distinctByAcademicYear()
          .findAll();
      
      // جلب السنوات من جدول student_payments
      final allPayments = await isar.studentPayments.where().findAll();
      final paymentYears = allPayments.where((p) => p.academicYear != null && p.academicYear!.isNotEmpty).map((p) => p.academicYear!).toSet();
      
      // جلب السنوات من جدول الإيرادات
      final allIncomes = await isar.incomes.where().findAll();
      final incomeYears = allIncomes.where((i) => i.academicYear.isNotEmpty).map((i) => i.academicYear).toSet();
      
      // جلب السنوات من جدول المصروفات
      final allExpenses = await isar.expenses.where().findAll();
      final expenseYears = allExpenses.where((e) => e.academicYear.isNotEmpty).map((e) => e.academicYear).toSet();
      
      Set<String> yearsSet = {};
      yearsSet.addAll(feeStatusYears.map((f) => f.academicYear).where((year) => year.isNotEmpty));
      yearsSet.addAll(paymentYears);
      yearsSet.addAll(incomeYears);
      yearsSet.addAll(expenseYears);
      
      // إضافة السنة الدراسية الحالية من الإعدادات إذا لم تكن موجودة
      if (academicYear.isNotEmpty) {
        yearsSet.add(academicYear);
      }
      
      setState(() {
        academicYears = yearsSet.toList();
        academicYears.sort((a, b) => b.compareTo(a)); // ترتيب تنازلي (الأحدث أولاً)
        
        // إذا لم تكن هناك سنة مختارة، لا نختار أي سنة افتراضياً
        // بل نترك المستخدم يختار أو يستخدم فلتر التاريخ
        // if (selectedAcademicYear == null) {
        //   if (academicYears.contains(academicYear)) {
        //     selectedAcademicYear = academicYear; // السنة الحالية من الإعدادات
        //   } else if (academicYears.isNotEmpty) {
        //     selectedAcademicYear = academicYears.first; // أحدث سنة متوفرة
        //   }
        // }
      });
      
      debugPrint('تم تحميل ${academicYears.length} سنة دراسية: $academicYears');
      debugPrint('السنة المختارة: $selectedAcademicYear');
    } catch (e) {
      debugPrint('خطأ في تحميل السنوات الدراسية: $e');
    }
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

      // جلب الأقساط مع فلتر السنة الدراسية إذا كانت محددة
      List<StudentFeeStatus> fees;
      if (selectedAcademicYear != null) {
        fees = await isar.studentFeeStatus
            .filter()
            .academicYearEqualTo(selectedAcademicYear!)
            .findAll();
      } else {
        fees = await isar.studentFeeStatus.where().findAll();
      }

      for (var fee in fees) {
        totalAnnualFees += fee.annualFee.toDouble();
        totalPaid += fee.paidAmount.toDouble();
        totalDue += (fee.dueAmount ?? 0).toDouble();
      }
// جلب الإيرادات والمصروفات
// إذا تم اختيار سنة دراسية، استخدم التواريخ المحددة لها
// وإلا استخدم التواريخ المحددة يدوياً أو الافتراضية
DateTime searchStartDate = startDate ?? DateTime.now().subtract(Duration(days: 365));
DateTime searchEndDate = endDate ?? DateTime.now();

debugPrint('البحث عن الإيرادات والمصروفات من ${DateFormat('yyyy-MM-dd').format(searchStartDate)} إلى ${DateFormat('yyyy-MM-dd').format(searchEndDate)}');

// جلب الإيرادات
List<Income> incomes;
if (selectedAcademicYear != null) {
  // البحث بالسنة الدراسية مباشرة (أسرع وأدق)
  incomes = await isar.incomes
      .filter()
      .academicYearEqualTo(selectedAcademicYear!)
      .findAll();
  debugPrint('البحث في الإيرادات بالسنة الدراسية: $selectedAcademicYear');
} else {
  // البحث بالتاريخ عند عدم اختيار سنة دراسية
  incomes = await isar.incomes
      .filter()
      .incomeDateBetween(searchStartDate, searchEndDate)
      .findAll();
  debugPrint('البحث في الإيرادات بالتاريخ من ${DateFormat('yyyy-MM-dd').format(searchStartDate)} إلى ${DateFormat('yyyy-MM-dd').format(searchEndDate)}');
}

totalIncomes = incomes.fold(0.0, (sum, i) => sum + i.amount.toDouble());

// جلب المصروفات
List<Expense> expenses;
if (selectedAcademicYear != null) {
  // البحث بالسنة الدراسية مباشرة (أسرع وأدق)
  expenses = await isar.expenses
      .filter()
      .academicYearEqualTo(selectedAcademicYear!)
      .findAll();
  debugPrint('البحث في المصروفات بالسنة الدراسية: $selectedAcademicYear');
} else {
  // البحث بالتاريخ عند عدم اختيار سنة دراسية
  expenses = await isar.expenses
      .filter()
      .expenseDateBetween(searchStartDate, searchEndDate)
      .findAll();
  debugPrint('البحث في المصروفات بالتاريخ من ${DateFormat('yyyy-MM-dd').format(searchStartDate)} إلى ${DateFormat('yyyy-MM-dd').format(searchEndDate)}');
}

totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount.toDouble());

debugPrint('تم العثور على ${incomes.length} إيراد بإجمالي ${totalIncomes.toStringAsFixed(2)} د.ع');
debugPrint('تم العثور على ${expenses.length} مصروف بإجمالي ${totalExpenses.toStringAsFixed(2)} د.ع');
debugPrint('الرصيد الصافي: ${netBalance.toStringAsFixed(2)} د.ع');

      netBalance = totalIncomes - totalExpenses;
    } catch (e) {
      debugPrint('خطأ في تحميل التقارير من Isar: \n$e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
 
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
                if (startDate != null || endDate != null || selectedAcademicYear != null)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (selectedAcademicYear != null)
                        pw.Text(
                          'السنة الدراسية: $selectedAcademicYear',
                          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                        ),
                      if (startDate != null || endDate != null)
                        pw.Text(
                          'الفترة: '
                          '${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '---'} '
                          'إلى '
                          '${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '---'}',
                          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                        ),
                    ],
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // فلتر السنة الدراسية المحسن
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade300, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            color: selectedAcademicYear != null ? Colors.blue.shade50 : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.school,
                                    color: Colors.blue.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'السنة الدراسية:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButton<String>(
                                    value: selectedAcademicYear,
                                    hint: Text(
                                      'اختر السنة الدراسية',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    underline: Container(),
                                    style: TextStyle(
                                      color: selectedAcademicYear != null ? Colors.blue.shade700 : Colors.black,
                                      fontWeight: selectedAcademicYear != null ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Row(
                                          children: [
                                            Icon(Icons.all_inclusive, size: 16, color: Colors.grey),
                                            SizedBox(width: 8),
                                            Text('جميع السنوات'),
                                          ],
                                        ),
                                      ),
                                      ...academicYears.map((year) => DropdownMenuItem<String>(
                                        value: year,
                                        child: Row(
                                          children: [
                                            Icon(
                                              year == academicYear ? Icons.schedule : Icons.history,
                                              size: 16,
                                              color: year == academicYear ? Colors.green : Colors.blue,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(year),
                                            if (year == academicYear)
                                              Container(
                                                margin: const EdgeInsets.only(left: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'حالية',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      )),
                                    ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedAcademicYear = value;
                                    // تحديث الفترة الزمنية تلقائياً بناءً على السنة الدراسية
                                    if (value != null) {
                                      // استخراج السنة من النص (مثلاً: "2023-2024" -> 2023)
                                      try {
                                        final yearParts = value.split('-');
                                        if (yearParts.length >= 2) {
                                          final startYear = int.parse(yearParts[0]);
                                          final endYear = int.parse(yearParts[1]);
                                          startDate = DateTime(startYear, 9, 1); // بداية السنة الدراسية (سبتمبر)
                                          endDate = DateTime(endYear, 8, 31); // نهاية السنة الدراسية (أغسطس)
                                        } else {
                                          // إذا كان تنسيق مختلف، استخدم السنة الحالية
                                          final year = int.parse(value);
                                          startDate = DateTime(year, 1, 1);
                                          endDate = DateTime(year, 12, 31);
                                        }
                                      } catch (e) {
                                        // في حالة فشل التحليل، استخدم التواريخ الافتراضية
                                        startDate = DateTime.now().subtract(const Duration(days: 365));
                                        endDate = DateTime.now();
                                      }
                                    }
                                  });
                                  fetchReportData();
                                },
                              ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, size: 18),
                                    tooltip: 'تحديث السنوات',
                                    onPressed: () {
                                      loadAcademicYears();
                                    },
                                  ),
                                  if (selectedAcademicYear != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      tooltip: 'مسح الفلتر',
                                      onPressed: () {
                                        setState(() {
                                          selectedAcademicYear = null;
                                          startDate = DateTime.now().subtract(const Duration(days: 365));
                                          endDate = DateTime.now();
                                        });
                                        fetchReportData();
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // إظهار اختيار التاريخ فقط إذا لم يتم اختيار سنة دراسية محددة
                        if (selectedAcademicYear == null) ...[
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
                              if (picked != null) {
                                setState(() => startDate = picked);
                                fetchReportData();
                              }
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
                              if (picked != null) {
                                setState(() => endDate = picked);
                                fetchReportData();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                        ],
                        // زر تطبيق الفلترة فقط إذا لم يتم اختيار سنة دراسية
                        if (selectedAcademicYear == null)
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: fetchReportData,
                              child: const Text('تطبيق الفلترة'),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (selectedAcademicYear != null || (selectedAcademicYear == null && (startDate != null || endDate != null)))
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'إلغاء الفلترة',
                            onPressed: () {
                              setState(() {
                                selectedAcademicYear = null;
                                // إعادة تعيين التواريخ إلى العام الحالي
                                final now = DateTime.now();
                                startDate = DateTime(now.year, 1, 1);
                                endDate = DateTime(now.year, 12, 31);
                              });
                              fetchReportData();
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // عرض معلومات السنوات الدراسية المتوفرة
                  if (academicYears.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              selectedAcademicYear != null
                                  ? 'السنة الدراسية: $selectedAcademicYear (${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)})'
                                  : 'عرض عام - الفترة: ${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)} | ${academicYears.length} سنة متوفرة',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton.icon(
                            onPressed: () {
                              _showAcademicYearsDialog();
                            },
                            icon: const Icon(Icons.list, size: 16),
                            label: const Text('عرض جميع السنوات'),
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  void _showAcademicYearsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'السنوات الدراسية المتوفرة',
            textAlign: TextAlign.center,
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 400),
            child: academicYears.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد سنوات دراسية محفوظة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: academicYears.length,
                    itemBuilder: (context, index) {
                      final year = academicYears[index];
                      final isSelected = year == selectedAcademicYear;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                        child: ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            year,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.blue : null,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedAcademicYear = year;
                              // تحديث التواريخ بناءً على السنة المختارة
                              try {
                                final yearParts = year.split('-');
                                if (yearParts.length >= 2) {
                                  final startYear = int.parse(yearParts[0]);
                                  final endYear = int.parse(yearParts[1]);
                                  startDate = DateTime(startYear, 9, 1);
                                  endDate = DateTime(endYear, 6, 30);
                                }
                              } catch (e) {
                                // في حالة فشل التحليل، استخدم التواريخ الافتراضية
                                final now = DateTime.now();
                                startDate = DateTime(now.year, 1, 1);
                                endDate = DateTime(now.year, 12, 31);
                              }
                            });
                            Navigator.of(context).pop();
                            fetchReportData();
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedAcademicYear = null;
                });
                Navigator.of(context).pop();
                fetchReportData();
              },
              child: const Text('جميع السنوات'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }
}
