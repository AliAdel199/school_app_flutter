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

                        Navigator.pop(context);
                        onSuccess();
                      } catch (e) {
                        debugPrint('خطأ: $e');
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

Future<void> showWithdrawStudentDialog({
  required BuildContext context,
  required String studentId,
  required String academicYear,
  required VoidCallback onSuccess,
}) async {
  final refundController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('انسحاب الطالب'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: refundController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'مبلغ الاسترجاع'),
              validator: (val) {
                if (val == null || double.tryParse(val) == null) {
                  return 'أدخل مبلغًا صالحًا';
                }
                return null;
              },
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
                        final refund = double.parse(refundController.text);
                        final now = DateTime.now();

                        await supabase.from('student_payments').insert({
                          'student_id': studentId,
                          'amount': -refund,
                          'paid_at': now.toIso8601String(),
                          'notes': 'استرجاع عند الانسحاب',
                          'academic_year': academicYear,
                        });

                        await supabase.from('students').update({'status': 'منسحب'}).eq('id', studentId);

                        Navigator.pop(context);
                        onSuccess();
                      } catch (e) {
                        debugPrint('خطأ: $e');
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading ? const CircularProgressIndicator() : const Text('تنفيذ'),
            ),
          ],
        );
      });
    },
  );
}

Future<void> showUpdateFeeDialog({
  required BuildContext context,
  required String feeStatusId,
  required double currentAnnualFee,
  required VoidCallback onSuccess,
}) async {
  final feeController = TextEditingController(text: currentAnnualFee.toString());
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('تعديل القسط السنوي'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'القسط الجديد'),
              validator: (val) {
                if (val == null || double.tryParse(val) == null) {
                  return 'أدخل رقمًا صالحًا';
                }
                return null;
              },
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
                        final newFee = double.parse(feeController.text);

                        final record = await supabase
                            .from('student_fee_status')
                            .select()
                            .eq('id', feeStatusId)
                            .maybeSingle();

                        if (record != null) {
                          final paid = record['paid_amount'] ?? 0;
                          final due = newFee - paid;

                          await supabase.from('student_fee_status').update({
                            'annual_fee': newFee,
                            'due_amount': due,
                          }).eq('id', feeStatusId);
                        }

                        Navigator.pop(context);
                        onSuccess();
                      } catch (e) {
                        debugPrint('خطأ: $e');
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading ? const CircularProgressIndicator() : const Text('تعديل'),
            ),
          ],
        );
      });
    },
  );
}
