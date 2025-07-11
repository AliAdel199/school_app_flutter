import 'package:isar/isar.dart';

import 'grade.dart';
import 'subject.dart';


part 'class.g.dart';

@collection
class SchoolClass {
  Id id = Isar.autoIncrement;

  late String name;
  double? annualFee;
  late int level; 

  final grade = IsarLink<Grade>();

  final subjects = IsarLinks<Subject>();
}
