import 'package:isar/isar.dart';
import 'expense.dart';

part 'expense_category.g.dart';

@collection
class ExpenseCategory {
  Id id = Isar.autoIncrement;

  late String name;

  @Index(unique: true)
  late String identifier; // تمييز فريد للفئة (مثلاً: rent, salary, supplies)

  // final expenses = IsarLinks<Expense>(); // الربط مع جدول المصروفات
}
