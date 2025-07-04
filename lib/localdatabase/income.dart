import 'package:isar/isar.dart';
import 'income_category.dart';

part 'income.g.dart';

@collection
class Income {
  Id id = Isar.autoIncrement;

  late String title;          // عنوان الإيراد
  late double amount;         // المبلغ
  String? note;               // ملاحظات
  late DateTime incomeDate;   // تاريخ الإيراد
bool archived=false;
  final category = IsarLink<IncomeCategory>(); // ربط بتصنيف الإيراد
}
