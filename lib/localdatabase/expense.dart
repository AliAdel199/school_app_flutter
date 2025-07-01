import 'package:isar/isar.dart';
import 'expense_category.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  late String title;           // عنوان المصروف
  late double amount;          // المبلغ
  String? note;                // ملاحظات
  late DateTime expenseDate;   // تاريخ المصروف
bool isActivated=false;

  final category = IsarLink<ExpenseCategory>(); // ربط بتصنيف المصروف
}
