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
  late String className;
  
  // حقول لتتبع الديون المنقولة من سنوات سابقة
  double transferredDebtAmount = 0; // المبلغ المنقول من سنة سابقة
  String? originalDebtAcademicYear; // السنة الدراسية الأصلية للدين
  String? originalDebtClassName; // الصف الأصلي للدين
  
  // الربط مع الطالب
  final student = IsarLink<Student>();
  late String studentId;

  /// مبلغ الخصم المطبق
  late double discountAmount=0;

  /// تفاصيل الخصومات (JSON string للتفاصيل)
  String? discountDetails;
}
