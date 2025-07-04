// lib/utils/receipt_helper.dart

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../localdatabase/student_payment.dart';

Future<void> generateAndPrintReceipt(StudentPayment payment, String studentName) async {
  final pdf = pw.Document();

  final arabicFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Amiri-Regular.ttf'),
  );

  pw.Widget receiptRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(label,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              )),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(value,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 12,
              )),
        ),
      ],
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(20),
      textDirection: pw.TextDirection.rtl,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              'مدرسة المستقبل الأهلية',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'إيصال دفع رسوم دراسية',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 14,
                color: PdfColors.blueGrey700,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.blueGrey100),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  receiptRow('اسم الطالب:', studentName),
                  pw.SizedBox(height: 6),
                  receiptRow('رقم الوصل:', payment.receiptNumber ?? 'بدون رقم'),
                  pw.SizedBox(height: 6),
                  receiptRow('المبلغ المدفوع:', '${NumberFormat('#,###').format(payment.amount)} د.ع'),
                  pw.SizedBox(height: 6),
                  receiptRow('تاريخ الدفع:', DateFormat('yyyy-MM-dd').format(payment.paidAt)),
                  if (payment.notes != null && payment.notes!.isNotEmpty)
                    ...[
                      pw.SizedBox(height: 6),
                      receiptRow('ملاحظات:', payment.notes!),
                    ]
                ],
              ),
            ),

            pw.Spacer(),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text(
                    'توقيع الإدارة',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(font: arabicFont, fontSize: 12),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Container(height: 1, width: 100, color: PdfColors.grey),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text(
                '© جميع الحقوق محفوظة - مدرسة المستقبل الأهلية',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColors.grey600),
              ),
            )
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

