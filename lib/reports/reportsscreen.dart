import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
  // استخدم حزمة pdf و printing
  import 'package:pdf/widgets.dart' as pw;
  import 'package:printing/printing.dart';
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

  List<String> academicYears = [];
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    fetchAcademicYears().then((_) {
      if (academicYears.isNotEmpty) selectedYear = academicYears.first;
      fetchReportData();
    });
  }

  Future<void> fetchAcademicYears() async {
    final res = await supabase
        .from('student_fee_status')
        .select('academic_year')
        .neq('academic_year', '')
        .order('academic_year', ascending: false);

    final data = res as List;
    academicYears = data.map((e) => e['academic_year'] as String).toSet().toList();
  }

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

      final userId = supabase.auth.currentUser!.id;
      final profile = await supabase
          .from('profiles')
          .select('school_id')
          .eq('id', userId)
          .single();
      final schoolId = profile['school_id'];

      final studentsRes = await supabase
          .from('students')
          .select('id, status')
          .eq('school_id', schoolId);

      final students = List<Map<String, dynamic>>.from(studentsRes);
      totalStudents = students.length;
      activeStudents = students.where((s) => s['status'] == 'active').length;
      inactiveStudents = students.where((s) => s['status'] == 'inactive').length;
      graduatedStudents = students.where((s) => s['status'] == 'graduated').length;
      withdrawnStudents = students.where((s) => s['status'] == 'منسحب').length;

      final studentIds = students.map((s) => s['id']).toList();

      List<Map<String, dynamic>> fees = [];
      if (selectedYear == null || selectedYear == 'all') {
        // جمع مبالغ جميع السنوات
        final feeRes = await supabase
        .from('student_fee_status')
        .select('annual_fee, paid_amount, due_amount, student_id')
        .inFilter('student_id', studentIds);

        fees = List<Map<String, dynamic>>.from(feeRes);
      } else {
        // جمع مبالغ سنة محددة فقط
        final feeRes = await supabase
        .from('student_fee_status')
        .select('annual_fee, paid_amount, due_amount, student_id')
        .eq('academic_year', selectedYear!)
        .inFilter('student_id', studentIds);

        fees = List<Map<String, dynamic>>.from(feeRes);
      }

      for (var fee in fees) {
        totalAnnualFees += (fee['annual_fee'] ?? 0).toDouble();
        totalPaid += (fee['paid_amount'] ?? 0).toDouble();
        totalDue += (fee['due_amount'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل التقارير: \n$e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

Future<void> printReportPdf() async {
  final pdf = pw.Document();

  final formatter = NumberFormat('#,###');
  final arabicFont = await PdfGoogleFonts.amiriRegular();
  final boldFont = await PdfGoogleFonts.amiriBold();

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
              if (selectedYear != null && selectedYear != 'all')
                pw.Text(
                  'السنة الدراسية: $selectedYear',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
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
                    inside: pw.BorderSide(color: PdfColors.blueGrey, width: 0.5),
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.blue50),
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
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd – HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
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

// Helper for table rows with improved style
pw.TableRow _pdfTableRow(String title, String value) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: pw.Text(title, style: pw.TextStyle(fontSize: 13)),
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
          const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Center(child: Text('طباعة التقرير')),
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
                    DropdownButton<String>(
                    value: selectedYear,
                    hint: const Text('اختر السنة الدراسية'),
                    onChanged: (val) {
                      setState(() {
                      selectedYear = val;
                      fetchReportData();
                      });
                    },
                    items: [
                      DropdownMenuItem(
                      value: 'all',
                      child: const Text('الجميع'),
                      ),
                      ...academicYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                      }).toList(),
                    ],
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildCard('عدد الطلاب الكلي', '$totalStudents', Colors.blue),
                        _buildCard('الطلاب الفعالين', '$activeStudents', Colors.green),
                        _buildCard('غير الفعالين', '$inactiveStudents', Colors.grey),
                        _buildCard('الخريجين', '$graduatedStudents', Colors.indigo),
                        _buildCard('المنسحبين', '$withdrawnStudents', Colors.orange),
                        _buildCard('مجموع الأقساط السنوية', '${formatter.format(totalAnnualFees)} د.ع', Colors.blue),
                        _buildCard('المدفوع الكلي', '${formatter.format(totalPaid)} د.ع', Colors.green),
                        _buildCard('المتبقي الكلي', '${formatter.format(totalDue)} د.ع', Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
