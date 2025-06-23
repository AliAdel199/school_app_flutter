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

  final grade = IsarLink<Grade>();

  final subjects = IsarLinks<Subject>();
}
