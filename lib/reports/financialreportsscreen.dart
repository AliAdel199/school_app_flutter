import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  bool isLoading = true;
  String selectedStatus = 'الكل';
  String searchQuery = '';

  final List<String> statusOptions = ['الكل', 'مكتمل', 'متأخر', 'غير مكتمل'];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> printFilteredReports() async {
    final pdf = pw.Document();

    // إعداد الخط العربي (مثال: Cairo أو Amiri)
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final arabicBoldFont = await PdfGoogleFonts.amiriBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'تقرير الرسوم المالية',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: arabicBoldFont,
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'عدد الطلاب: ${filteredReports.length}',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 14,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            columnWidths: {
              0: const pw.FlexColumnWidth(2.2),
              1: const pw.FlexColumnWidth(1.3),
              2: const pw.FlexColumnWidth(1.1),
              3: const pw.FlexColumnWidth(1.4),
              4: const pw.FlexColumnWidth(1.4),
              5: const pw.FlexColumnWidth(1.4),
              6: const pw.FlexColumnWidth(1.7),
              7: const pw.FlexColumnWidth(1.1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  for (final h in [
                    'اسم الطالب',
                    'الصف',
                    'السنة',
                    'القسط السنوي',
                    'المدفوع',
                    'المتبقي',
                    'آخر دفعة',
                    'الحالة',
                  ])
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                      child: pw.Text(
                        h,
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 12,
                          color: PdfColors.blue900,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                ],
              ),
              ...filteredReports.map((report) {
                PdfColor statusColor;
                switch (report['status']) {
                  case 'مكتمل':
                    statusColor = PdfColors.green700;
                    break;
                  case 'متأخر':
                    statusColor = PdfColors.red700;
                    break;
                  default:
                    statusColor = PdfColors.orange700;
                }
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                      child: pw.Text(
                        report['full_name'] ?? '',
                        style: pw.TextStyle(font: arabicFont, fontSize: 11),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ),
                    pw.Text(
                      report['class_name'] ?? '',
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      report['academic_year'] ?? '',
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      report['annual_fee'].toString(),
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      report['paid_amount'].toString(),
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      report['due_amount'].toString(),
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      report['last_payment_date'] ?? '',
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(
                          (statusColor.toInt() & 0x00FFFFFF) | ((0.13 * 255).toInt() << 24),
                        ),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        report['status'] ?? '',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 11,
                       
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 22),
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'تم إنشاء التقرير بتاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount}',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/financial_report.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> fetchReports() async {
    setState(() => isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final profile = await supabase
          .from('profiles')
          .select('school_id')
          .eq('id', userId)
          .single();

      final schoolId = profile['school_id'];

      final data = await supabase
          .from('student_fee_status')
          .select(
              'id, academic_year, annual_fee, paid_amount, last_payment_date, students:student_id(full_name, id, class_id, classes(name), school_id)')
          .eq('students.school_id', schoolId);

      final formatted = data.map<Map<String, dynamic>>((entry) {
        final student = entry['students'];
        final annualFee = entry['annual_fee'] ?? 0;
        final paid = entry['paid_amount'] ?? 0;
        final due = annualFee - paid;
        final lastDate = entry['last_payment_date'] != null
            ? DateTime.tryParse(entry['last_payment_date'])
            : null;

        String status;
        if (due == 0) {
          status = 'مكتمل';
        } else if (lastDate != null && lastDate.isBefore(DateTime.now())) {
          status = 'متأخر';
        } else {
          status = 'غير مكتمل';
        }

        return {
          'full_name': student['full_name'],
          'class_name': student['classes']?['name'] ?? '-',
          'academic_year': entry['academic_year'] ?? '-',
          'annual_fee': annualFee,
          'paid_amount': paid,
          'due_amount': due,
          'last_payment_date': lastDate != null
              ? DateFormat('yyyy-MM-dd').format(lastDate)
              : '-',
          'status': status,
        };
      }).toList();

      setState(() {
        reports = formatted;
        applyFilters();
      });
    } catch (e) {
      debugPrint('خطأ في تحميل التقارير: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    setState(() {
      filteredReports = reports.where((r) {
        final matchesStatus = selectedStatus == 'الكل' || r['status'] == selectedStatus;
        final matchesSearch = r['full_name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'متأخر':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث باسم الطالب...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (val) {
                searchQuery = val;
                applyFilters();
              },
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: selectedStatus,
            items: statusOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                selectedStatus = val;
                applyFilters();
              }
            },
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }

  Widget buildReportCard(Map<String, dynamic> r) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: statusColor(r['status']).withOpacity(0.15),
              child: Icon(Icons.person, color: statusColor(r['status']), size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['full_name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.class_, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('الصف: ${r['class_name']}',
                          style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('السنة: ${r['academic_year']}',
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text('القسط السنوي: ${r['annual_fee']} د.ع',
                          style: TextStyle(color: Colors.green[900])),
                      const SizedBox(width: 12),
                      Icon(Icons.payment, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text('المدفوع: ${r['paid_amount']} د.ع',
                          style: TextStyle(color: Colors.blue[900])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.money_off, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text('المتبقي: ${r['due_amount']} د.ع',
                          style: TextStyle(color: Colors.red[900])),
                      const SizedBox(width: 12),
                      Icon(Icons.date_range, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('آخر دفعة: ${r['last_payment_date']}',
                          style: TextStyle(color: Colors.grey[800])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Chip(
                  label: Text(r['status']),
                  backgroundColor: statusColor(r['status']).withOpacity(0.18),
                  labelStyle: TextStyle(
                      color: statusColor(r['status']),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير المالية'),
        actions: [
          IconButton(
        icon: const Icon(Icons.print),
        tooltip: 'طباعة التقرير',
        onPressed: () async {
          await printFilteredReports();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم طباعة التقرير في وحدة التصحيح')),
          );
        },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildFilterBar(),
                Expanded(
                  child: filteredReports.isEmpty
                      ? const Center(child: Text('لا توجد نتائج.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredReports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              buildReportCard(filteredReports[index]),
                        ),
                ),
              ],
            ),
    );
  }
}
