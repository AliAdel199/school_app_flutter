import 'package:isar/isar.dart';

import 'income.dart';

part 'income_category.g.dart';

@collection
class IncomeCategory {
  Id id = Isar.autoIncrement;

  late String name;

  @Index(unique: true)
  late String identifier; // يمكن استخدامه لتمييز التصنيفات بشكل فريد

  // ربط مع الإيرادات
  // final incomes = IsarLinks<Income>();
}
