import 'package:supabase_flutter/supabase_flutter.dart';

class DataController {
  final supabase = Supabase.instance.client;

  /// إضافة طالب
  Future<void> addStudent(Map<String, dynamic> data) async {
    await supabase.from('students').insert(data);
  }

  /// تعديل بيانات طالب
  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    await supabase.from('students').update(data).eq('id', id);
  }

  /// حذف طالب
  Future<void> deleteStudent(String id) async {
    await supabase.from('students').delete().eq('id', id);
  }

  /// إضافة موظف
  Future<void> addEmployee(Map<String, dynamic> data) async {
    await supabase.from('employees').insert(data);
  }

  /// تعديل بيانات موظف
  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    await supabase.from('employees').update(data).eq('id', id);
  }

  /// حذف موظف
  Future<void> deleteEmployee(String id) async {
    await supabase.from('employees').delete().eq('id', id);
  }

  /// إضافة مصروف
  Future<void> addExpense(Map<String, dynamic> data) async {
    await supabase.from('expenses').insert(data);
  }

  /// تعديل مصروف
  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await supabase.from('expenses').update(data).eq('id', id);
  }

  /// حذف مصروف
  Future<void> deleteExpense(String id) async {
    await supabase.from('expenses').delete().eq('id', id);
  }

  /// إضافة إيراد
  Future<void> addIncome(Map<String, dynamic> data) async {
    await supabase.from('incomes').insert(data);
  }

  /// تعديل إيراد
  Future<void> updateIncome(String id, Map<String, dynamic> data) async {
    await supabase.from('incomes').update(data).eq('id', id);
  }

  /// حذف إيراد
  Future<void> deleteIncome(String id) async {
    await supabase.from('incomes').delete().eq('id', id);
  }

  /// التحقق من الاشتراك
  Future<bool> isSchoolSubscribed(String schoolId) async {
    final res = await supabase
        .from('schools')
        .select('subscription_end')
        .eq('id', schoolId)
        .maybeSingle();
    if (res == null || res['subscription_end'] == null) return false;
    return DateTime.parse(res['subscription_end']).isAfter(DateTime.now());
  }

  /// تحديث حالة الترحيل
  Future<void> promoteStudent(String id, Map<String, dynamic> data) async {
    await supabase.from('students').update(data).eq('id', id);
  }
}
