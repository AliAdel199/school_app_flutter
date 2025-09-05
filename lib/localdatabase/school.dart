import 'package:isar/isar.dart';
import 'grade.dart';
import 'class.dart';

part 'school.g.dart';

@collection
class School {
  Id id = Isar.autoIncrement;

  /// معرف المدرسة في Supabase (uuid)
  String? supabaseId;

  late String name;
  String? email;
  String? phone;
  String? address;
  String? logoUrl;
  String? subscriptionPlan;
  String subscriptionStatus = 'inactive'; // نفس الافتراضي في Supabase
  DateTime? subscriptionStart;
  DateTime? subscriptionEnd;
  DateTime createdAt = DateTime.now();

  final grades = IsarLinks<Grade>();
  final classes = IsarLinks<SchoolClass>();
}