import 'package:isar/isar.dart';

part 'auto_discount_settings.g.dart';

@collection
class AutoDiscountSettings {
  Id id = Isar.autoIncrement;

  /// تفعيل/إيقاف النظام بالكامل
  late bool globalEnabled = true;

  /// إعدادات خصم الأشقاء
  late bool siblingDiscountEnabled = true;
  double siblingDiscountRate2nd = 10.0; // نسبة خصم الطالب الثاني
  double siblingDiscountRate3rd = 15.0; // نسبة خصم الطالب الثالث
  double siblingDiscountRate4th = 20.0; // نسبة خصم الطالب الرابع فما فوق

  /// إعدادات خصم الدفع المبكر
  late bool earlyPaymentDiscountEnabled = true;
  double earlyPaymentDiscountRate = 5.0; // نسبة الخصم
  int earlyPaymentDays = 30; // عدد الأيام قبل بداية العام

  /// إعدادات خصم الدفع الكامل
  late bool fullPaymentDiscountEnabled = true;
  double fullPaymentDiscountRate = 3.0; // نسبة الخصم

  /// إعدادات إضافية
  late bool autoApplyOnPayment = true; // تطبيق تلقائي عند إضافة دفعة
  late bool showNotifications = true; // إظهار الإشعارات
  late bool allowDuplicateDiscounts = false; // السماح بالخصومات المكررة

  /// تاريخ آخر تحديث
  DateTime lastUpdated = DateTime.now();

  /// ملاحظات الإعدادات
  String? notes;

  /// تفعيل خصومات حسب الصف (تم تعطيلها مؤقتاً)
  @ignore
  Map<String, bool> classSpecificEnabled = {};

  /// الحد الأدنى والأقصى لقيم الخصومات
  double minDiscountAmount = 0.0;
  double maxDiscountAmount = 1000000.0;
  double minDiscountPercentage = 0.0;
  double maxDiscountPercentage = 100.0;
}
