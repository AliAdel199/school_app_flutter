import 'package:isar/isar.dart';

import 'grade.dart';
import 'school.dart';
import 'student.dart';
import 'subject.dart';


part 'class.g.dart';

@collection
class SchoolClass {
  Id id = Isar.autoIncrement;

  late String name;
  double? annualFee;

  final school = IsarLink<School>();
  final grade = IsarLink<Grade>();

  final students = IsarLinks<Student>();
  final subjects = IsarLinks<Subject>();
}
