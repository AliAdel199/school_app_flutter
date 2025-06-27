import 'package:isar/isar.dart';
import '/localdatabase/class.dart';
import 'student_fee_status.dart';
import 'student_payment.dart';


part 'student.g.dart';

@collection
class Student {
  Id id = Isar.autoIncrement;

  late String fullName;

  String? gender;
  DateTime? birthDate;
  String? nationalId;
  String? parentName;
  String? parentPhone;
  String? address;
  String? email;
  String? phone;
  String status = 'active'; // active, inactive, graduated, transferred
  DateTime createdAt = DateTime.now();
  String? registrationYear;
  double? annualFee;

  // العلاقات
  final payments = IsarLinks<StudentPayment>();
  final feeStatus = IsarLink<StudentFeeStatus>();
  final schoolclass = IsarLink<SchoolClass>(); // Assuming classId is a String, adjust if needed
}
