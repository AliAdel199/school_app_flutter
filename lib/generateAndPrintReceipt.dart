import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndPrintReceipt({
  required BuildContext context,
  required String studentName,
  required String className,
  required String academicYear,
  required double amount,
  required DateTime paidAt,
  required String receiptNumber,
  String? notes,
}) async {
  final pdf = pw.Document();
  final formatter = NumberFormat('#,###');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'مدرسة المستقبل الأهلية',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'وصل استلام دفعة',
                  style: pw.TextStyle(fontSize: 16),
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text('الاسم: $studentName'),
              pw.Text('الصف: $className'),
              pw.Text('السنة الدراسية: $academicYear'),
              pw.SizedBox(height: 12),
              pw.Text(
                'المبلغ: ${formatter.format(amount)} د.ع',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(paidAt)}'),
              if (notes != null && notes.isNotEmpty)
                pw.Text('ملاحظات: $notes'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Text('رقم الوصل: $receiptNumber'),
              pw.SizedBox(height: 20),
              pw.Text('توقيع المسؤول: ______________________'),
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
