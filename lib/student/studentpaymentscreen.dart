import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../reports/receipt_helper.dart';
import '/localdatabase/student.dart';
import '/localdatabase/user.dart';
import '../localdatabase/log.dart';
import '../localdatabase/student_crud.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/student_payment.dart';
import '../main.dart';
import '../dialogs/payment_dialog_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  List<String> academicYears = [];
  String? selectedAcademicYear;

  final formatter = NumberFormat('#,###');





  @override
  void initState() {
    super.initState();
    loadAcademicYearsAndInit();
  }
  Future<bool?> showEditPaymentDialogIsar({
    required BuildContext context,
    required StudentPayment payment,
    required String studentId,
    required String academicYear,
  }) async {
    final amountController = TextEditingController(text: payment.amount.toString());
    final receiptController = TextEditingController(text: payment.receiptNumber ?? '');
    final notesController = TextEditingController(text: payment.notes ?? '');
    DateTime paidAt = payment.paidAt;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الدفعة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                ),
                TextField(
                  controller: receiptController,
                  decoration: const InputDecoration(labelText: 'رقم الوصل'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('تاريخ الدفع: '),
                    TextButton(
                      child: Text('${paidAt.toLocal()}'.split(' ')[0]),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: paidAt,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          paidAt = picked;
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('حفظ'),
              onPressed: () async {
                final newAmount = double.tryParse(amountController.text) ?? 0;
                final oldAmount = payment.amount;

                payment.amount = newAmount;
                payment.receiptNumber = receiptController.text.trim().isEmpty ? null : receiptController.text.trim();
                payment.notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();
                payment.paidAt = paidAt;

                await isar.writeTxn(() async {
                  await isar.studentPayments.put(payment);

                  // تحديث حالة القسط
                  final feeStatus = await isar.studentFeeStatus
                      .filter()
                      .studentIdEqualTo(studentId)
                      .academicYearEqualTo(academicYear)
                      .findFirst();

                  if (feeStatus != null) {
                    // الفرق بين المبلغ الجديد والقديم
                    final diff = newAmount - oldAmount;
                    feeStatus.paidAmount = (feeStatus.paidAmount ?? 0) + diff;
                    // التأكد من عدم تجاوز القيم المنطقية
                    if (feeStatus.paidAmount! < 0) feeStatus.paidAmount = 0;
                    feeStatus.dueAmount = (feeStatus.annualFee ?? 0) - (feeStatus.paidAmount ?? 0);
                    if (feeStatus.dueAmount! < 0) feeStatus.dueAmount = 0;
                    await isar.studentFeeStatus.put(feeStatus);
                  }
                });

                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> loadAcademicYearsAndInit() async {
    setState(() => isLoading = true);
    try {
      final yearsFromPayments = await isar.studentPayments
          .filter()
          .studentIdEqualTo(widget.studentId.toString())
          .findAll();
      final yearsFromFeeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(widget.studentId.toString())
          .findAll();

      final yearsSet = <String>{};
      yearsSet.addAll(yearsFromPayments.map((e) => e.academicYear ?? 'غير معروف'));
      yearsSet.addAll(yearsFromFeeStatus.map((e) => e.academicYear ?? 'غير معروف'));

      academicYears = yearsSet.where((y) => y.isNotEmpty).toList();
      academicYears.sort((a, b) => b.compareTo(a));

      selectedAcademicYear = academicYears.isNotEmpty ? academicYears.first : null;

      await reloadAllData();
    } catch (e) {
      debugPrint('Error loading academic years: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> reloadAllData() async {
    setState(() => isLoading = true);
    try {
      if (selectedAcademicYear == null) {
        payments = [];
        feeStatus = null;
      } else {
        payments = await isar.studentPayments
            .filter()
            .studentIdEqualTo(widget.studentId.toString())
            .academicYearEqualTo(selectedAcademicYear)
            .sortByPaidAtDesc()
            .findAll();

        feeStatus = await isar.studentFeeStatus
            .filter()
            .studentIdEqualTo(widget.studentId.toString())
            .academicYearEqualTo(selectedAcademicYear!)
            .findFirst();
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error during reloadAllData: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('دفعات الطالب: ${widget.fullName}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (feeStatus == null || feeStatus!.dueAmount! <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا يمكن إضافة دفعة، القسط مدفوع بالكامل أو لا توجد حالة قسط')),
            );
            return;
          }
          final result = await showAddPaymentDialogIsar(
            context: context,
            studentId: widget.studentId.toString(),
            academicYear: selectedAcademicYear ?? 'غير معروف',
            student: widget.student!,
            isar: isar,
          );

          if (result == true) {
            await reloadAllData();

            var user = await isar.users.where().findFirst();
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
                  if (academicYears.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('السنة الدراسية: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: selectedAcademicYear,
                          items: academicYears
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year),
                                  ))
                              .toList(),
                          onChanged: (value) async {
                            setState(() {
                              selectedAcademicYear = value;
                            });
                            await reloadAllData();
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (feeStatus != null)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildStatCard('القسط السنوي', '${formatter.format(feeStatus!.annualFee)} د.ع', Colors.blue),
                        _buildStatCard('المدفوع', '${formatter.format(feeStatus!.paidAmount)} د.ع', Colors.green),
                        _buildStatCard('المتبقي', '${formatter.format(feeStatus!.dueAmount)} د.ع', Colors.red),
                      ],
                    ),
                  if (feeStatus == null)
                    const Text('لا توجد حالة قسط لهذه السنة', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        const Text('سجل الدفعات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        SizedBox(width: 200,child: ElevatedButton(style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                    
                          onPressed: ()=>printStudentPayments(widget.student!,selectedAcademicYear!), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Icon(Icons.print),Text('طباعة الدفعات'),],)),)
                      ],
                    ),
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
                                    trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await deleteStudentPayment(isar, p.id, widget.studentId.toString(), selectedAcademicYear!);
                                        await reloadAllData();
                                      },
                                      ),
                                      IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        final result = await showEditPaymentDialogIsar(
                                        context: context,
                                        payment: p,
                                        studentId: widget.studentId.toString(),
                                        academicYear: selectedAcademicYear ?? 'غير معروف',
                                        );
                                        if (result == true) {
                                        await reloadAllData();
                                        }
                                      },
                                      ),
                                      IconButton(onPressed: (){
                                   printArabicInvoice2(
                                        // context: context,
                                        studentName: widget.fullName,
                                        // className: widget.student?.schoolclass.value?.name ?? 'غير معروف',
                                        academicYear: selectedAcademicYear ?? 'غير معروف',
                                        amount: p.amount,
                                        paidAt: p.paidAt,
                                        receiptNumber: p.receiptNumber ?? 'غير متوفر',
                                        notes: p.notes ?? '',
                                        invoiceSerial: p.invoiceSerial

                                      );
                                      }, icon: Icon(Icons.print_outlined, color: Colors.green)),
                                    ],
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
