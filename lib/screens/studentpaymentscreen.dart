import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dialogs/payment_dialog_ui.dart';
import 'package:pdf/widgets.dart' as pw;

class StudentPaymentsScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentPaymentsScreen({super.key, required this.student});

  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> payments = [];
  Map<String, dynamic>? feeStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() => isLoading = true);
    try {
      final paymentRes = await supabase
          .from('student_payments')
          .select()
          .eq('student_id', widget.student['id'])
          .order('paid_at', ascending: false);

      final feeRes = await supabase
          .from('student_fee_status')
          .select()
          .eq('student_id', widget.student['id'])
          .maybeSingle();

      payments = List<Map<String, dynamic>>.from(paymentRes);
      feeStatus = feeRes;
    } catch (e) {
      debugPrint('فشل في تحميل الدفعات: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء تحميل البيانات: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


Future<void> printSinglePaymentReceipt({
  required String studentName,
  required String studentId,
  required String receiptNumber,
  required double amount,
  required double annualFee,
  required double totalPaid,
  required double remaining,
  required DateTime paidAt,
  String? notes,
}) async {
  final arabicFont = await PdfGoogleFonts.cairoRegular();
  final boldFont = await PdfGoogleFonts.cairoBold();

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(
        base: arabicFont,
        bold: boldFont,
      ),
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 1.5),
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  'وصل دفع رسوم دراسية',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Divider(thickness: 1.2, color: PdfColors.blueGrey400),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('اسم الطالب:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(studentName),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('رقم الطالب:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(studentId),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('رقم الوصل:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(receiptNumber),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('تاريخ الدفع:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${paidAt.toLocal().toString().split(' ').first}'),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('المبلغ المدفوع:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${amount.toStringAsFixed(0)} د.ع'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('القسط السنوي:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${annualFee.toStringAsFixed(0)} د.ع'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('إجمالي المدفوع:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${totalPaid.toStringAsFixed(0)} د.ع'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('المتبقي:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                        pw.Text('${remaining.toStringAsFixed(0)} د.ع', style: pw.TextStyle(color: PdfColors.red800)),
                      ],
                    ),
                  ],
                ),
              ),
              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ملاحظات: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Expanded(child: pw.Text(notes)),
                    ],
                  ),
                ),
              ],
              pw.Spacer(),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('توقيع الإدارة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final fee = feeStatus?['annual_fee'] ?? 0;
    final paid = feeStatus?['paid_amount'] ?? 0;
    final due = feeStatus?['due_amount'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('دفعات الطالب: ${widget.student['full_name']}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showAddPaymentDialog(
            context: context,
            studentId: widget.student['id'],
            academicYear: feeStatus?['academic_year'] ?? 'غير معروف',
            onSuccess: fetchPayments,
          );
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatCard('القسط السنوي', '${formatter.format(fee)} د.ع', Colors.blue),
                          _buildStatCard('المدفوع', '${formatter.format(paid)} د.ع', Colors.green),
                          _buildStatCard('المتبقي', '${formatter.format(due)} د.ع', Colors.red),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('سجل الدفعات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: payments.isEmpty
                            ? const Center(child: Text('لا توجد دفعات مسجلة'))
                            : ListView.builder(
                                itemCount: payments.length,
                              
                                itemBuilder: (context, index) {
                                  final p = payments[index];
                                  return Card(elevation: 3, margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                         Text('${formatter.format(p['amount'])} د.ع'),
Text('تاريخ: ${p['paid_at'].toString().split('T').first}'),
 Text(p['receipt_number'] ?? 'بدون رقم'),
                                          IconButton(
                                            icon: const Icon(Icons.print),
                                            onPressed: () async {
                                              await printSinglePaymentReceipt(
                                                studentName: widget.student['full_name'],
                                                studentId: widget.student['id'],
                                                receiptNumber: p['receipt_number'] ?? 'غير معروف',
                                                amount: p['amount'].toDouble(),
                                                annualFee: fee.toDouble(),
                                                totalPaid: paid.toDouble(),
                                                remaining: due.toDouble(),
                                                paidAt: DateTime.parse(p['paid_at']),
                                                notes: p['notes'],
                                              );
                                            },
                                          ),
                                      ],
                                  
                                    ),
                                  );
                                },
                              ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
