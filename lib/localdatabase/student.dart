import 'package:isar/isar.dart';

part 'student.g.dart';

@collection
class Student {
  Id id = Isar.autoIncrement; // id داخلي لـ Isar

  late String serverId; // id من Supabase

  late String fullName;
  String? gender;
  String? parentName;
  String? parentPhone;
  String? phone;
  String? birthDate;
  String? nationalId;
  String? email;
  String? address;
  String? status;
  String? classId;
  String? schoolId;
  int? annualFee;
  String? currentFeeStatusId;
  String? registrationYear;
  DateTime createdAt = DateTime.now();
}
