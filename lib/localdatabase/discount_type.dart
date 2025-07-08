import 'package:isar/isar.dart';

part 'discount_type.g.dart';

@collection
class DiscountType {
  Id? id;

  /// اسم نوع الخصم
  late String name;

  /// وصف نوع الخصم
  String? description;

  /// قيمة الخصم الافتراضية
  double? defaultValue;

  /// هل القيمة الافتراضية نسبة مئوية
  late bool defaultIsPercentage=false;

  /// لون مميز لنوع الخصم (للعرض في الواجهة)
  String? color;

  /// هل نوع الخصم نشط
  late bool isActive=true;

  /// ترتيب العرض
  late int sortOrder=0;

  /// تاريخ الإنشاء
  late DateTime createdAt= DateTime.now();
}