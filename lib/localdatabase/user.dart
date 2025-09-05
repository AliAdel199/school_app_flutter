import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String username;

  late String email;
  late String schoolId;
  late String supabaseUserId;

  late String password; // يفضل لاحقًا تخزينها مشفرة

  DateTime createdAt = DateTime.now();
}
