// ✅ تم تعديل الكود ليتوافق مع Isar فقط (بدون Supabase)
// ✅ عرض دفعات الطالب وربطها بحالته المالية
// ✅ تم تحميل الدفعات وحالة القسط من Isar وربطها بالواجهة
// ✅ جاهز للعمل بالكامل

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/student.dart';
import 'package:school_app_flutter/localdatabase/user.dart';
import '../localdatabase/income.dart';
import '../localdatabase/log.dart';
import '../localdatabase/student_crud.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/student_payment.dart';
import '../main.dart';
import '../dialogs/payment_dialog_ui.dart';

class StudentPaymentsScreen extends StatefulWidget {
  final int studentId;
  final String fullName;
  final Student? student;

  const StudentPaymentsScreen({super.key, required this.studentId, required this.fullName, this.student});

  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  List<StudentPayment> payments = [];
  StudentFeeStatus? feeStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchData();
    refreshFeeStatus();
    reloadAllData();
    // s();
  }
Future<void> reloadAllData() async {
  setState(() => isLoading = true);
  try {
    payments = await isar.studentPayments
        .filter()
        .studentIdEqualTo(widget.studentId.toString())
        .sortByPaidAtDesc()
        .findAll();

    feeStatus = await isar.studentFeeStatus
        .filter()
        .studentIdEqualTo(widget.studentId.toString())
        .findFirst();
        setState(() {
          
        });
  } catch (e) {
    debugPrint('Error during reloadAllData: $e');
  } finally {
    setState(() => isLoading = false);
  }
}



  

  Future<void> refreshFeeStatus() async {
    try {
      feeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(widget.studentId.toString())
          .findFirst();
      setState(() {
        // Update the UI with the new feeStatus
      });
    } catch (e) {
      debugPrint('Error fetching fee status: $e');
    }
  }

   final formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
   

   
    return Scaffold(
      appBar: AppBar(title: Text('دفعات الطالب: ${widget.fullName}')),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    if(feeStatus!.dueAmount! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن إضافة دفعة، القسط مدفوع بالكامل')),
      );
      return;
    }
    final result = await showAddPaymentDialogIsar(
      context: context,
      studentId: widget.studentId.toString(),
      academicYear: feeStatus?.academicYear ?? 'غير معروف',
      student: widget.student!,
      isar: isar,
    );
   
    print("dialog result: $result"); // اختبار للتأكد
    if (result == true) {
      print("reloading..."); // اختبار
      await reloadAllData();
  
      // جلب بيانات المستخدم من Isar
   var   user = await isar.users.where().findFirst();
      
      if (user != null) {
    final log = Log()
      ..action = 'اضافة دفعة'
      ..tableName = 'users'
      ..description = 'تم اضافة دفعة بواسطة ${user.username}'
      ..user.value = user;

    await isar.writeTxn(() async {
      await isar.logs.put(log);
      await log.user.save();
    });
  }
    }
  },
  child: const Icon(Icons.add),
),

  
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatCard('القسط السنوي', '${formatter.format(feeStatus!.annualFee)} د.ع', Colors.blue),
          _buildStatCard('المدفوع', '${formatter.format(feeStatus!.paidAmount)} د.ع', Colors.green),
          _buildStatCard('المتبقي', '${formatter.format(feeStatus!.dueAmount)} د.ع', Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('سجل الدفعات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: payments.isEmpty
                        ? const Center(child: Text('لا توجد دفعات مسجلة'))
                        : ListView.builder(
                            itemCount: payments.length,
                            itemBuilder: (context, index) {
                              final p = payments[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                child: ListTile(
                                  title: Text('${formatter.format(p.amount)} د.ع'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('تاريخ: ${p.paidAt.toString().split(' ').first}'),
                                      Text('رقم الوصل: ${p.receiptNumber ?? 'بدون رقم'}'),
                                      if (p.notes != null) Text('ملاحظات: ${p.notes}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                       deleteStudentPayment(isar, p.id, widget.studentId.toString(),feeStatus!.academicYear);
                                       
                                    }
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
