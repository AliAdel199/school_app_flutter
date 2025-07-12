import 'package:isar/isar.dart';
import 'student.dart';
import 'subject.dart';

part 'subject_mark.g.dart';

@collection
class SubjectMark {
  Id id = Isar.autoIncrement;

  double? mark; // درجة الطالب
  String? evaluationType; // مثل: نصف سنة، نهائي، شفوي...
  String? academicYear;
  DateTime createdAt = DateTime.now();

  final student = IsarLink<Student>();
  final subject = IsarLink<Subject>();
}
