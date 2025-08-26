import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String username;

  late String email;

  late String password; // يفضل لاحقًا تخزينها مشفرة
  late String schoolId;  // auth.uid() من Supabase

  DateTime createdAt = DateTime.now();
}
