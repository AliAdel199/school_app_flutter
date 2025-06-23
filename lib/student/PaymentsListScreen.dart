import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../localdatabase/student_payment.dart';
import '../localdatabase/student.dart';
import '../main.dart';

class PaymentsListScreen extends StatefulWidget {
  const PaymentsListScreen({super.key, });

  @override
  State<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  List<StudentPayment> allPayments = [];
  List<StudentPayment> filteredPayments = [];
  String searchQuery = '';
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    final payments = await isar.studentPayments
        .where()
        .sortByPaidAtDesc()
        .thenByReceiptNumber()
        .findAll();

    setState(() {
      allPayments = payments;
      filteredPayments = payments;
    });
  }

  void filterPayments(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredPayments = allPayments.where((p) {
        final studentName = p.student.value?.fullName.toLowerCase() ?? '';
        final receipt = p.receiptNumber?.toLowerCase() ?? '';
        return studentName.contains(lowerQuery) || receipt.contains(lowerQuery);
      }).toList();
    });
  }

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الوصولات المالية'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: filterPayments,
              decoration: const InputDecoration(
                labelText: 'بحث برقم الوصل أو اسم الطالب',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredPayments.isEmpty
                ? const Center(child: Text('لا توجد وصولات مطابقة'))
                : ListView.builder(
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      final studentName = payment.student.value?.fullName ?? 'غير معروف';
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('المبلغ: ${payment.amount}'),
                              Text('التاريخ: ${formatDate(payment.paidAt)}'),
                              Text('رقم الوصل: ${payment.receiptNumber ?? 'غير متوفر'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content: const Text('هل أنت متأكد من حذف هذا الوصل؟'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('إلغاء')),
                                    ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('حذف')),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await isar.writeTxn(() async {
                                  await isar.studentPayments.delete(payment.id);
                                });
                                loadPayments();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
