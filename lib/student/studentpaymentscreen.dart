// ✅ تم تعديل الكود ليتوافق مع Isar فقط (بدون Supabase)
// ✅ عرض دفعات الطالب وربطها بحالته المالية
// ✅ تم تحميل الدفعات وحالة القسط من Isar وربطها بالواجهة
// ✅ جاهز للعمل بالكامل

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/student_payment.dart';
import '../main.dart';
import '../dialogs/payment_dialog_ui.dart';

class StudentPaymentsScreen extends StatefulWidget {
  final int studentId;
  final String fullName;

  const StudentPaymentsScreen({super.key, required this.studentId, required this.fullName});

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
    fetchData();
    // refreshFeeStatus();
  }

  Future<void> fetchData() async {
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
        print(feeStatus!.annualFee);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deletePayment(int id) async {
    await isar.writeTxn(() async {
      await isar.studentPayments.delete(id);
    });
    fetchData();
  }
  
 var fee;

  var paid;
  var due;
  // Future<void> refreshFeeStatus() async {
  //   try {
  //     feeStatus = await isar.studentFeeStatus
  //         .filter()
  //         .studentIdEqualTo(widget.studentId.toString())
  //         .findFirst();
  //     setState(() {
  //         fee = feeStatus?.annualFee ?? 0;
  //    paid = feeStatus?.paidAmount ?? 0;
  //    due = feeStatus?.dueAmount ?? 0;
  //     });
  //   } catch (e) {
  //     debugPrint('Error fetching fee status: $e');
  //   }
  // }

   final formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
   

   
    return Scaffold(
      appBar: AppBar(title: Text('دفعات الطالب: ${widget.fullName}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showAddPaymentDialogIsar(
            context: context,
            studentId: widget.studentId.toString(),
            academicYear: feeStatus?.academicYear ?? 'غير معروف',
            onSuccess: fetchData,
            isar: isar,
          );
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
                                    onPressed: () async => await deletePayment(p.id),
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
