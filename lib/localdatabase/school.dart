import 'package:isar/isar.dart';
import 'grade.dart';
import 'class.dart';

part 'school.g.dart';

@collection
class School {
  Id id = Isar.autoIncrement;

  late String name;
  String? email;
  String? phone;
  String? address;
  String? logoUrl;
  String? subscriptionPlan;
  String subscriptionStatus = 'active';
  DateTime? endDate;
  DateTime createdAt = DateTime.now();

  // معلومات المؤسسة التعليمية
  int? organizationId; // معرف المؤسسة في Supabase
  String? organizationType; // نوع المدرسة (ابتدائية، متوسطة، ثانوية)
  String? organizationName; // اسم المؤسسة التابعة لها

  // إضافة معرف Supabase
  int? supabaseId;
  bool syncedWithSupabase = false;
  DateTime? lastSyncAt;

  // حقول الاشتراك في مزامنة التقارير
  String? reportsSyncSubscription; // JSON للتفاصيل
  bool reportsSyncActive = false;
  DateTime? reportsSyncExpiryDate;

  final grades = IsarLinks<Grade>();
  final classes = IsarLinks<SchoolClass>();
}
