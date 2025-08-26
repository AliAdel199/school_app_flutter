  // إدارة التقارير
  import 'package:school_app_flutter/localdatabase/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isar/isar.dart';


class ReportsManagement {


final supabase = Supabase.instance.client;

Future<void> loginFromIsar(Isar isar) async {
  final auth = await isar.users.where().findFirst();

  if (auth != null) {
    final response = await supabase.auth.signInWithPassword(
      email: auth.email,
      password: auth.password,
    );

    if (response.user != null) {
      print("✅ تسجيل الدخول ناجح");
    } else {
      print("❌ فشل تسجيل الدخول");
    }
  } else {
    print("⚠️ لا توجد بيانات تسجيل محفوظة محليًا");
  }
}


Future<bool> canUploadReports(String schoolId) async {
  final response = await supabase
      .from('schools')
      .select('subscription_status, subscription_end')
      .eq('id', schoolId)
      .maybeSingle();

  if (response == null) return false;

  final status = response['subscription_status'] as String?;
  final endDate = response['subscription_end'] != null
      ? DateTime.parse(response['subscription_end'])
      : null;

  if (status == 'active' && (endDate == null || endDate.isAfter(DateTime.now()))) {
    return true;
  }

  return false;
}


Future<void> uploadSchoolReport({
  required String schoolId,
  required int totalStudents,
  required int activeStudents,
  required int inactiveStudents,
  required int graduates,
  required int withdrawn,
  required int totalAnnualFees,
  required int totalPaid,
  required int totalRemaining,
  required int totalIncome,
  required int totalExpenses,
  required int netBalance,
}) async {
  final response = await supabase.from('school_reports').upsert({
    'school_id': schoolId,
    'total_students': totalStudents,
    'active_students': activeStudents,
    'inactive_students': inactiveStudents,
    'graduates': graduates,
    'withdrawn': withdrawn,
    'total_annual_fees': totalAnnualFees,
    'total_paid': totalPaid,
    'total_remaining': totalRemaining,
    'total_income': totalIncome,
    'total_expenses': totalExpenses,
    'net_balance': netBalance,
    'updated_at': DateTime.now().toIso8601String(),
  }).select();

  print("📤 تم رفع التقرير: $response");
}


}