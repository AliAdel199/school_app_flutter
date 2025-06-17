import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import '../localdatabase/user.dart';
import '../localdatabase/log.dart';
import '../main.dart';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

// إنشاء مستخدم جديد
Future<void> registerUser(String username, String email, String password) async {
  final hashedPassword = hashPassword(password);

  final user = User()
    ..username = username
    ..email = email
    ..password = hashedPassword;

  await isar.writeTxn(() async {
    await isar.users.put(user);
  });
}

// تسجيل دخول
Future<User?> loginUser(String email, String password) async {
  final hashedPassword = hashPassword(password);

  final user = await isar.users
      .filter()
      .emailEqualTo(email)
      .passwordEqualTo(hashedPassword)
      .findFirst();

  if (user != null) {
    final log = Log()
      ..action = 'تسجيل دخول'
      ..tableName = 'users'
      ..description = 'تم تسجيل الدخول من ${user.email}'
      ..user.value = user;

    await isar.writeTxn(() async {
      await isar.logs.put(log);
      await log.user.save();
    });
  }

  return user;
}
