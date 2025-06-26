import 'package:isar/isar.dart';
import 'student.dart';

part 'student_payment.g.dart';

@collection
class StudentPayment {
  Id id = Isar.autoIncrement;

  late double amount;

  DateTime paidAt = DateTime.now();

  String? receiptNumber;
  String? notes;
  DateTime createdAt = DateTime.now();
  String? academicYear;
   int invoiceSerial=0; // ✅ الرقم التسلسلي للفاتورة


  // ربط IsarLink
  final student = IsarLink<Student>();

  // معرف الطالب النصي (محلي أو uid من Supabase)
  late String studentId;
}
