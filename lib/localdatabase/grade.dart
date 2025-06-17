import 'package:isar/isar.dart';
import 'school.dart';
import 'class.dart';
import 'subject.dart';

part 'grade.g.dart';

@collection
class Grade {
  Id id = Isar.autoIncrement;

  late String name;

  final school = IsarLink<School>();
  final classes = IsarLinks<SchoolClass>();
  final subjects = IsarLinks<Subject>();
}
