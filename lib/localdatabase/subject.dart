import 'package:isar/isar.dart';
import 'class.dart';
import 'school.dart';
import 'grade.dart';

part 'subject.g.dart';

@collection
class Subject {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  double maxMark = 100.0; // الدرجة الكاملة للمادة (افتراضياً 100)
  DateTime createdAt = DateTime.now();

  final school = IsarLink<School>();
  final grade = IsarLink<Grade>();
  final schoolClass = IsarLink<SchoolClass>();
}
