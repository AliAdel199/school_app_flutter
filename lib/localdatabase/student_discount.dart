import 'package:isar/isar.dart';
import 'student.dart';

part 'student_discount.g.dart';

@collection
class StudentDiscount {
  Id? id;

  /// معرف الطالب
  late String studentId;

  /// نوع الخصم (مثل: متفوق، أيتام، إعاقة، أبناء موظفين، إلخ)
  late String discountType;

  /// قيمة الخصم (يمكن أن تكون مبلغ ثابت أو نسبة مئوية)
  late double discountValue;

  /// هل الخصم نسبة مئوية أم مبلغ ثابت
  /// true = نسبة مئوية, false = مبلغ ثابت
  late bool isPercentage=false;

  /// السنة الدراسية التي ينطبق عليها الخصم
  late String academicYear;

  /// ملاحظات حول الخصم
  String? notes;

  /// تاريخ إنشاء الخصم
  late DateTime createdAt=DateTime.now();

  /// هل الخصم نشط
  late bool isActive=true;

  /// تاريخ انتهاء صلاحية الخصم (اختياري)
  DateTime? expiryDate;

  /// الشخص الذي أضاف الخصم
  String? addedBy;

  /// رابط مع جدول الطلاب
  final student = IsarLink<Student>();
}