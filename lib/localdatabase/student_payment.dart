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

  // الربط مع الطالب
  final student = IsarLink<Student>();
}
