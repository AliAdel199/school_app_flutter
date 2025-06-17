import 'package:isar/isar.dart';
import 'user.dart';

part 'log.g.dart';

@collection
class Log {
  Id id = Isar.autoIncrement;

  late String action; // مثال: "إضافة صف", "تعديل طالب"

  String? tableName;

  String? description;

  DateTime createdAt = DateTime.now();

  final user = IsarLink<User>(); // من قام بالعملية
}
