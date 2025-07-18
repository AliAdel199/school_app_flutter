import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '/localdatabase/subject.dart';

import '../main.dart';
import 'class.dart';
import 'grade.dart';
import 'invoice_serial.dart';
import 'school.dart';
import 'student.dart';
import 'student_fee_status.dart';
import 'student_payment.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

//
// 🧑‍🎓 Student
//
Future<void> addStudent(Isar isar, Student student) async {
  await isar.writeTxn(() async {
    // Add the student
    await isar.students.put(student);
    student.schoolclass.save();

  });

  await isar.writeTxn(() async {
     // Generate initial fee status for the student
    final feeStatus = StudentFeeStatus()
      ..student.value = student
      ..annualFee=student.annualFee!
      ..dueAmount = student.annualFee // Assuming annualFee is the total fee
      ..studentId = student.id.toString()
      ..academicYear = student.registrationYear ?? DateTime.now().year.toString()
      ..className = student.schoolclass.value?.name ?? 'غير محدد'
      ..createdAt = DateTime.now()
      ..paidAmount = 0.0 // Initial paid amount
      ..lastPaymentDate = null // No payments made yet  
      ..nextDueDate = DateTime.now().add(const Duration(days: 30)) // Set next due date to 30 days from now
;       // or any default status you want

    await isar.studentFeeStatus.put(feeStatus);
    student.feeStatus.value = feeStatus; // Link the fee status to the student
    await feeStatus.student.save();
    await student.feeStatus.save();
    
  });

}

Future<List<Student>> getAllStudents(Isar isar) async {
  return await isar.students.where().findAll();
}

Future<Student?> getStudentById(Isar isar, int id) async {
  return await isar.students.get(id);
}

Future<void> updateStudent(Isar isar, Student student) async {
  await isar.writeTxn(() async {
    await isar.students.put(student);
  });
}

Future<void> deleteStudent(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.students.delete(id);
  });
}

//
// 💳 StudentPayment
//
Future<void> addStudentPayment(Isar isar, StudentPayment payment,Student student,String studentId,String academicYear,DateTime nextDueDate) async {
  await isar.writeTxn(() async {
 // Set the invoice serial number
    await isar.studentPayments.put(payment);
 final feeStatus = await isar.studentFeeStatus
                            .filter()
                            .studentIdEqualTo(studentId)
                            .academicYearEqualTo(academicYear)
                            .findFirst();
                            print(feeStatus!.annualFee);

                        final payments = await isar.studentPayments
                            .filter()
                            .studentIdEqualTo(studentId)
                            .academicYearEqualTo(academicYear)
                            .findAll();

                        double totalPaid = 0;
                        DateTime? lastDate;

                        for (final p in payments) {
                          totalPaid += p.amount;
                          if (lastDate == null || p.paidAt.isAfter(lastDate)) {
                            lastDate = p.paidAt;
                          }
                        }

                        final due = (feeStatus.annualFee) - totalPaid;

                        
                          feeStatus.paidAmount = totalPaid;
                          feeStatus.dueAmount = due;
                          feeStatus.lastPaymentDate = lastDate;
                          feeStatus.nextDueDate = nextDueDate;


  await isar.studentFeeStatus.put(feeStatus);





}
);

}
Future<int> getNextInvoiceNumber(Isar isar) async {
  return await isar.writeTxn(() async {
    final counter = await isar.invoiceCounters.get(0);

    if (counter == null) {
      final newCounter = InvoiceCounter()..lastInvoiceNumber = 1;
      await isar.invoiceCounters.put(newCounter);
      return 1;
    } else {
      counter.lastInvoiceNumber += 1;
      await isar.invoiceCounters.put(counter);
      return counter.lastInvoiceNumber;
    }
  });
}

Future<List<StudentPayment>> getAllStudentPayments(Isar isar) async {
  return await isar.studentPayments.where().findAll();
}

Future<void> deleteStudentPayment(Isar isar, int id,String studentId,String academicYear) async {
  await isar.writeTxn(() async {
    
  });
    await isar.writeTxn(() async {
    await isar.studentPayments.delete(id);
 final feeStatus = await isar.studentFeeStatus
                            .filter()
                            .studentIdEqualTo(studentId)
                            .academicYearEqualTo(academicYear)
                            .findFirst();
                            print(feeStatus!.annualFee);

                        final payments = await isar.studentPayments
                            .filter()
                            .studentIdEqualTo(studentId)
                            .academicYearEqualTo(academicYear)
                            .findAll();

                        double totalPaid = 0;
                        DateTime? lastDate;

                        for (final p in payments) {
                          totalPaid += p.amount;
                          if (lastDate == null || p.paidAt.isAfter(lastDate)) {
                            lastDate = p.paidAt;
                          }
                        }

                        final due = (feeStatus.annualFee) - totalPaid;

                        
                          feeStatus.paidAmount = totalPaid;
                          feeStatus.dueAmount = due;
                          feeStatus.lastPaymentDate = lastDate;


  await isar.studentFeeStatus.put(feeStatus);





}
);

  
}

//
// 💵 StudentFeeStatus
//
Future<void> addFeeStatus(Isar isar, StudentFeeStatus status) async {
  await isar.writeTxn(() async {
    await isar.studentFeeStatus.put(status);
  });
}

Future<List<StudentFeeStatus>> getAllFeeStatuses(Isar isar) async {
  return await isar.studentFeeStatus.where().findAll();
}

Future<void> deleteFeeStatus(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.studentFeeStatus.delete(id);
  });
}

//
// 🏫 SchoolClass
//
Future<void> addClass(Isar isar, SchoolClass schoolClass) async {
  await isar.writeTxn(() async {
    await isar.schoolClass.put(schoolClass);

    schoolClass.grade.save(); // Save the grades associated with the class
  });
}


Future<List<SchoolClass>> getAllClasses(Isar isar) async {
  return await isar.schoolClass.where().findAll();
}

Future<SchoolClass?> getClassById(Isar isar, int id) async {
  return await isar.schoolClass.get(id);
}

Future<void> updateClass(Isar isar, SchoolClass schoolClass) async {
  await isar.writeTxn(() async {
    await isar.schoolClass.put(schoolClass);
  });
}

Future<void> deleteClass(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.schoolClass.delete(id);
  });
}

//
// 🎓 Grade
//
Future<void> addGrade(Isar isar, Grade grade) async {

  // Example: Fetch a school by its id (assuming grade.schoolId exists)
 
    final school = await isar.schools.where().findFirst();
    // You can use the fetched school object as needed here
  
  
  await isar.writeTxn(() async {
    grade.school.value=school!;
    await isar.grades.put(grade);
    school.grades.add(grade);
    grade.school.save();
    school.grades.save();


  });
}

Future<List<Grade>> getAllGrades(Isar isar) async {
  return await isar.grades.where().findAll();
}

Future<Grade?> getGradeById(Isar isar, int id) async {
  return await isar.grades.get(id);
}

Future<void> updateGrade(Isar isar, Grade grade) async {
  await isar.writeTxn(() async {
    await isar.grades.put(grade);
    grade.classes.save();
  });
}

Future<void> deleteGrade(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.grades.delete(id);
  });
}

//
// 🏫 School
//
Future<void> addSchool(Isar isar, School school) async {
  await isar.writeTxn(() async {
    await isar.schools.put(school);
  });
}

Future<List<School>> getAllSchools(Isar isar) async {
  return await isar.schools.where().findAll();
}

Future<School?> getSchoolById(Isar isar, int id) async {
  return await isar.schools.get(id);
}

Future<void> updateSchool(Isar isar, School school) async {
  await isar.writeTxn(() async {
    await isar.schools.put(school);
  });
}

Future<void> deleteSchool(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.schools.delete(id);
  });
}

//
// 📘 Subject
//
Future<void> addSubject(Isar isar, Subject subject) async {
  await isar.writeTxn(() async {
    await isar.subjects.put(subject);
  });
}

Future<List<Subject>> getAllSubjects(Isar isar) async {
  return await isar.subjects.where().findAll();
}

Future<Subject?> getSubjectById(Isar isar, int id) async {
  return await isar.subjects.get(id);
}

Future<void> updateSubject(Isar isar, Subject subject) async {
  await isar.writeTxn(() async {
    await isar.subjects.put(subject);
  });
}

Future<void> deleteSubject(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.subjects.delete(id);
  });
}
  Future<Uint8List> _loadAsset(String path) async {
    try {
      // Ensure the path is relative to the assets directory, e.g., 'assets/images/logo.jpg'
      ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      // Return an empty Uint8List or load a default image if asset not found
      print('Asset load error: $e');
      // Optionally, load a default image asset here if you have one
      // ByteData defaultData = await rootBundle.load('assets/images/default_logo.jpg');
      // return defaultData.buffer.asUint8List();
      return Uint8List(0);
    }
  }
void printArabicInvoice2({
  required String studentName,
  required String receiptNumber,
  required double amount,
  required String notes,
  required DateTime paidAt,
  required String academicYear,
  required int invoiceSerial,
}) async {

School school = await isar.schools.where().findFirst() ?? School();

  final format = NumberFormat('#,###');
  final pdf = pw.Document();

  final baseFont =pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
  final boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Bold.ttf'));
 
 final phoneIcon = pw.MemoryImage(
  (await rootBundle.load('assets/phone.png')).buffer.asUint8List(),
);
final locationIcon = pw.MemoryImage(
  (await rootBundle.load('assets/location.png')).buffer.asUint8List(),
);
 
   // Use a default logo if school.logoUrl is null or empty
   final String logoPath = (school.logoUrl != null && school.logoUrl!.isNotEmpty)
       ? school.logoUrl!
       : 'assets/images/logo.jpg';
   final Uint8List header = await _loadAsset(logoPath);
   final pw.ImageProvider? imageProvider1 =pw.MemoryImage(await File(logoPath).readAsBytes());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(18),
theme: pw.ThemeData.withFont(
  base: baseFont,
  bold: boldFont,
  // fontFallback: [await PdfGoogleFonts.notoColorEmoji()], // ✅ إضافة fallback
),

      build: (context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey400, width: 1.2),
              borderRadius: pw.BorderRadius.circular(10),
              color: PdfColors.white,
            ),
            padding: const pw.EdgeInsets.all(14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(school.name ?? 'مدرسة غير محددة',
                            style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800)),
                        pw.Text('إيصال دفع رسوم دراسية',
                            style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blueGrey700)),
                      ],
                    ),
                    imageProvider1 != null
                        ? pw.Container(
                            width: 44,
                            height: 44,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue50,
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                  color: PdfColors.blueGrey300, width: 1),
                            ),
                            child: pw.ClipOval(
                              child: pw.Image(
                                imageProvider1,
                                fit: pw.BoxFit.cover,
                                width: 75,
                                height: 75,
                              ),
                            ),
                          )
                        : pw.Container(
                            width: 75,
                            height: 75,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue50,
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                  color: PdfColors.blueGrey300, width: 1),
                            ),
                            child: pw.Center(
                              child: pw.Text('🔖',
                                  style: const pw.TextStyle(fontSize: 22)),
                            ),
                          ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, color: PdfColors.blueGrey200),

                // Receipt Info Table
                pw.SizedBox(height: 12),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey50,
                    borderRadius: pw.BorderRadius.circular(7),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(3),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text('اسم الطالب:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(studentName),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('السنة الأكاديمية:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(academicYear),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('رقم الوصل:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(receiptNumber),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('تاريخ الدفع:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(DateFormat('yyyy-MM-dd').format(paidAt)),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('رقم الفاتورة:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(invoiceSerial.toString()),
                        ],
                      ),
                      if (notes.isNotEmpty)
                        pw.TableRow(
                          children: [
                            pw.Text('ملاحظات:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(notes),
                          ],
                        ),
                    ],
                  ),
                ),

                // Amount Section
                pw.SizedBox(height: 16),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue600, width: 1),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('المبلغ المدفوع',
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900)),
                      pw.Text('${format.format(amount)} د.ع',
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800)),
                    ],
                  ),
                ),

                // Footer
                pw.Spacer(),
                pw.Divider(thickness: 1, color: PdfColors.blueGrey200),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('توقيع الإدارة',
                            style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blueGrey700)),
                        pw.SizedBox(height: 18),
                        pw.Container(
                          width: 70,
                          height: 1,
                          color: PdfColors.blueGrey400,
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(children: [
                            pw.Row(
                              children: [
                                // pw.Text('📞', style: const pw.TextStyle(fontSize: 13)),
                                pw.Image(phoneIcon, width: 12, height: 12),

                                pw.SizedBox(width: 4),
                                pw.Text('${school.phone}',
                                  style: const pw.TextStyle(
                                    fontSize: 11, color: PdfColors.blueGrey600)),
                              ],
                            ),
                        ]),
                          pw.Row(children: [
                            pw.Row(
                              children: [
                                pw.Image(locationIcon, width: 12, height: 12),

                                pw.SizedBox(width: 4),
                                                    pw.Text(' ${school.address}',
                            style: const pw.TextStyle(
                                fontSize: 11, color: PdfColors.blueGrey600)),
                              ],
                            ),
                        ]),

                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

Future<void> printStudentPayments(Student student, String academicYear) async {

  // جلب الدفعات من Isar حسب الطالب والسنة الأكاديمية
  final payments = await isar.studentPayments
      .filter()
      .studentIdEqualTo(student.id.toString())
      .academicYearEqualTo(academicYear)
      .findAll();

  // Preload fonts before building the PDF page

  final amiriRegular =pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
  final amiriBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Bold.ttf'));

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(
  base: amiriRegular,
  bold: amiriBold,
  // fontFallback: [await PdfGoogleFonts.notoColorEmoji()], // ✅ إضافة fallback
),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
            pw.Text('دفعات الطالب: ${student.fullName ?? ''}',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              fontFallback: [amiriRegular],
            ),
            textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 10),
            pw.Text('العام الدراسي: $academicYear',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
              fontFallback: [amiriRegular],
            ),
            textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 20),
            pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blueGrey200, width: 1),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Table(
              border: pw.TableBorder.all(color: PdfColors.blueGrey200, width: 0.5),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              },
              children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Text('كود الوصل',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontFallback: [amiriBold],
                  ),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Text('الملاحظات',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontFallback: [amiriBold],
                  ),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Text('التاريخ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontFallback: [amiriBold],
                  ),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Text('القسط المدفوع',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontFallback: [amiriBold],
                  ),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),
                ],
              ),
              ...payments.map((p) => pw.TableRow(
                children: [
                     pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                
                    p.receiptNumber ?? 'غير متوفر',
                  
                  style: pw.TextStyle(
                    fontFallback: [amiriRegular],
                  ),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),


                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                  // هنا يجب إظهار المبلغ المتبقي وليس العام الدراسي
                
                    (p.notes ?? ''),
                
                  style: pw.TextStyle(
                    color: PdfColors.red800,
                    fontFallback: [amiriRegular],
                  ),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                  p.paidAt != null
                    ? DateFormat('yyyy/MM/dd', 'ar').format(p.paidAt)
                    : '',
                  style: pw.TextStyle(fontFallback: [amiriRegular]),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),
              
               pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                  NumberFormat('#,###', 'ar').format(p.amount ?? 0),
                  style: pw.TextStyle(
                    color: PdfColors.green800,
                    fontFallback: [amiriRegular],
                  ),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  ),
                ),
                ],
              )),
              ],
            ),
            ),
          pw.SizedBox(height: 16),
          pw.Text('ملاحظة: جميع المبالغ بالدينار العراقي.',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.blueGrey700,
              fontFallback: [amiriRegular],
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}