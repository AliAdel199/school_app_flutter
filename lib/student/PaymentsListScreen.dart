import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../localdatabase/student_payment.dart';
import '../localdatabase/student.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentsListScreen extends StatefulWidget {
  const PaymentsListScreen({super.key, });

  @override
  State<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  List<StudentPayment> allPayments = [];
  List<StudentPayment> filteredPayments = [];
  String searchQuery = '';
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    final payments = await isar.studentPayments
        .where()
        .sortByPaidAtDesc()
        .thenByReceiptNumber()
        .findAll();

    setState(() {
      allPayments = payments;
      filteredPayments = payments;
    });
  }


void printArabicInvoice({
  required String studentName,
  required String receiptNumber,
  required double amount,
  required String notes,
  required DateTime paidAt,
  required String academicYear,
}) async {
  final format = NumberFormat('#,###');
  final pdf = pw.Document();

  final baseFont = await PdfGoogleFonts.amiriRegular();
  final boldFont = await PdfGoogleFonts.amiriBold();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      build: (context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ✅ رأس الصفحة
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey700, width: 1)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('مدرسة المستقبل الأهلية', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text('إيصال دفع رسوم دراسية', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blueGrey300,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text('🔖', style: pw.TextStyle(fontSize: 24)),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // ✅ معلومات الإيصال
              pw.Text('اسم الطالب: $studentName', style: pw.TextStyle(fontSize: 14)),
              pw.Text('السنة الأكاديمية: $academicYear', style: pw.TextStyle(fontSize: 14)),
              pw.Text('رقم الوصل: $receiptNumber', style: pw.TextStyle(fontSize: 14)),
              pw.Text('تاريخ الدفع: ${DateFormat('yyyy-MM-dd').format(paidAt)}', style: pw.TextStyle(fontSize: 14)),
              if (notes.isNotEmpty)
                pw.Text('ملاحظات: $notes', style: pw.TextStyle(fontSize: 14)),

              pw.SizedBox(height: 20),

              // ✅ المبلغ المدفوع بشكل واضح
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blueGrey600),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('المبلغ المدفوع', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${format.format(amount)} د.ع', style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              pw.Spacer(),

              // ✅ التوقيع والتذييل
              pw.Divider(),
              pw.Text('توقيع الإدارة', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 30),
              pw.Text('📞 للاستفسار: 0780 000 0000', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              pw.Text('📍 العنوان: بغداد - شارع الربيعي', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
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

  void filterPayments(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredPayments = allPayments.where((p) {
        final studentName = p.student.value?.fullName.toLowerCase() ?? '';
        final receipt = p.receiptNumber?.toLowerCase() ?? '';
        return studentName.contains(lowerQuery) || receipt.contains(lowerQuery);
      }).toList();
    });
  }

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الوصولات المالية'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: filterPayments,
              decoration: const InputDecoration(
                labelText: 'بحث برقم الوصل أو اسم الطالب',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredPayments.isEmpty
                ? const Center(child: Text('لا توجد وصولات مطابقة'))
                : ListView.builder(
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      final studentName = payment.student.value?.fullName ?? 'غير معروف';
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child:ListTile(
  title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('المبلغ: ${payment.amount}'),
      Text('التاريخ: ${formatDate(payment.paidAt)}'),
      Text('رقم الوصل: ${payment.receiptNumber ?? 'غير متوفر'}'),
    ],
  ),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('تأكيد الحذف'),
              content: const Text('هل أنت متأكد من حذف هذا الوصل؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('حذف'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await isar.writeTxn(() async {
              await isar.studentPayments.delete(payment.id);
            });
            loadPayments();
          }
        },
      ),

      IconButton(
        icon: const Icon(Icons.print, color: Colors.blue),
        onPressed: () {
          final receiptNumber = payment.receiptNumber ?? 'غير متوفر';
          final notes = payment.notes ?? '';
          final studentNameFromIsar = payment.student.value?.fullName ?? 'غير معروف';

          printArabicInvoice(
            studentName: studentNameFromIsar,
            receiptNumber: receiptNumber,
            amount: payment.amount,
            notes: notes,
            paidAt: payment.paidAt,
            academicYear: payment.academicYear ?? 'غير محدد',
          );
        },
      ),
    ],
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
