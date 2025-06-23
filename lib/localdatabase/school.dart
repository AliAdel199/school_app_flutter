import 'package:isar/isar.dart';
import 'grade.dart';
import 'class.dart';
import 'student.dart';

part 'school.g.dart';

@collection
class School {
  Id id = Isar.autoIncrement;

  late String name;
  String? email;
  String? phone;
  String? subscriptionPlan;
  String subscriptionStatus = 'active';
  DateTime? endDate;
  DateTime createdAt = DateTime.now();

  final grades = IsarLinks<Grade>();
  final classes = IsarLinks<SchoolClass>();
}
