import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> showAddPaymentDialog({
  required BuildContext context,
  required String studentId,
  required String academicYear,
  required VoidCallback onSuccess,
}) async {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  DateTime paidAt = DateTime.now();
  DateTime? nextDueDate;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('إضافة دفعة جديدة'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  validator: (val) {
                    if (val == null || double.tryParse(val) == null) {
                      return 'أدخل مبلغًا صالحًا';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: paidAt,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => paidAt = picked);
                  },
                  child: Text('تاريخ الدفع: ${DateFormat('yyyy-MM-dd').format(paidAt)}'),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => nextDueDate = picked);
                  },
                  child: Text(
                    nextDueDate == null
                        ? 'اختيار تاريخ الدفعة القادمة'
                        : 'تاريخ الدفعة القادمة: ${DateFormat('yyyy-MM-dd').format(nextDueDate!)}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);
                      try {
                        final amount = double.parse(amountController.text);
                        final receiptNumber = 'R-${DateTime.now().millisecondsSinceEpoch}';

                        await supabase.from('student_payments').insert({
                          'student_id': studentId,
                          'amount': amount,
                          'paid_at': paidAt.toIso8601String(),
                          'notes': notesController.text,
                          'academic_year': academicYear,
                          'receipt_number': receiptNumber,
                        });

                        final feeStatus = await supabase
                            .from('student_fee_status')
                            .select()
                            .eq('student_id', studentId)
                            .eq('academic_year', academicYear)
                            .maybeSingle();

                        if (feeStatus != null) {
                          final payments = await supabase
                              .from('student_payments')
                              .select('amount, paid_at')
                              .eq('student_id', studentId)
                              .eq('academic_year', academicYear);

                          double totalPaid = 0;
                          DateTime? lastDate;

                          for (final p in payments) {
                            totalPaid += (p['amount'] as num).toDouble();
                            final paidAt = DateTime.tryParse(p['paid_at']);
                            if (paidAt != null) {
                              if (lastDate == null || paidAt.isAfter(lastDate)) {
                                lastDate = paidAt;
                              }
                            }
                          }

                          final due = (feeStatus['annual_fee'] as num).toDouble() - totalPaid;

                          await supabase.from('student_fee_status').update({
                            'paid_amount': totalPaid,
                            'due_amount': due,
                            'last_payment_date': lastDate?.toIso8601String(),
                            'next_due_date': nextDueDate?.toIso8601String(),
                          }).eq('id', feeStatus['id']);
                        }

                        Navigator.pop(context);
                        onSuccess();
                      } catch (e) {
                        debugPrint('خطأ: \n$e');
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading ? const CircularProgressIndicator() : const Text('إضافة'),
            ),
          ],
        );
      });
    },
  );
}
