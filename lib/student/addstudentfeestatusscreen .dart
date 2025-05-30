import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentFeeStatusScreen extends StatefulWidget {
  final String studentId;

  const AddStudentFeeStatusScreen({super.key, required this.studentId});

  @override
  State<AddStudentFeeStatusScreen> createState() => _AddStudentFeeStatusScreenState();
}

class _AddStudentFeeStatusScreenState extends State<AddStudentFeeStatusScreen> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final yearController = TextEditingController();
  final feeController = TextEditingController();
  final paidController = TextEditingController();
  final dueController = TextEditingController();
  DateTime? lastPaidDate;
  DateTime? nextDueDate;

  bool isLoading = false;

  void calculateDueAmount() {
    final fee = double.tryParse(feeController.text) ?? 0;
    final paid = double.tryParse(paidController.text) ?? 0;
    final due = fee - paid;
    dueController.text = due.toStringAsFixed(0);
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await supabase.from('student_fee_status').insert({
        'student_id': widget.studentId,
        'academic_year': yearController.text.trim(),
        'annual_fee': double.parse(feeController.text.trim()),
        'paid_amount': double.parse(paidController.text.trim()),
        'due_amount': double.parse(dueController.text.trim()),
        'last_payment_date': lastPaidDate?.toIso8601String(),
        'next_due_date': nextDueDate?.toIso8601String(),
      });

      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الإضافة: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    yearController.dispose();
    feeController.dispose();
    paidController.dispose();
    dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة حالة قسط طالب')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'السنة الدراسية'),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: feeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'القسط السنوي'),
                onChanged: (_) => calculateDueAmount(),
                validator: (val) => double.tryParse(val ?? '') == null ? 'أدخل مبلغًا صالحًا' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: paidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ المدفوع'),
                onChanged: (_) => calculateDueAmount(),
                validator: (val) => double.tryParse(val ?? '') == null ? 'أدخل مبلغًا صالحًا' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dueController,
                keyboardType: TextInputType.number,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'المتبقي'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  lastPaidDate == null
                      ? 'اختر تاريخ آخر دفع'
                      : 'آخر دفع: ${DateFormat('yyyy-MM-dd').format(lastPaidDate!)}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => lastPaidDate = picked);
                },
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  nextDueDate == null
                      ? 'اختر موعد الدفع القادم'
                      : 'الاستحقاق القادم: ${DateFormat('yyyy-MM-dd').format(nextDueDate!)}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => nextDueDate = picked);
                },
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submit,
                      child: const Text('حفظ'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
