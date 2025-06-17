import 'package:isar/isar.dart';
import 'student.dart';

part 'student_fee_status.g.dart';

@collection
class StudentFeeStatus {
  Id id = Isar.autoIncrement;

  late String academicYear;
  late double annualFee;
  double paidAmount = 0;
  double? dueAmount;
  DateTime? lastPaymentDate;
  DateTime? nextDueDate;
  DateTime createdAt = DateTime.now();

  // الربط مع الطالب
  final student = IsarLink<Student>();
}
