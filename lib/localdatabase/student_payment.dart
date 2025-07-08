import 'package:isar/isar.dart';
import 'student.dart';

part 'student_payment.g.dart';

@collection
class StudentPayment {
  Id id = Isar.autoIncrement;

  late double amount;
  bool isDebtSettlement = false; // حقل جديد للتمييز بين الدفعات العادية ودفعات تسوية الديون

  DateTime paidAt = DateTime.now();

  String? receiptNumber;
  String? notes;
  DateTime createdAt = DateTime.now();
  String? academicYear;
   int invoiceSerial=0; // ✅ الرقم التسلسلي للفاتورة

bool archived=false;

  // ربط IsarLink
  final student = IsarLink<Student>();

  // معرف الطالب النصي (محلي أو uid من Supabase)
  late String studentId;
}
