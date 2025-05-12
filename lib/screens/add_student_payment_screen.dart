
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentFeeStatusScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  final VoidCallback onSaved;

  const AddStudentFeeStatusScreen({
    super.key,
    required this.student,
    required this.onSaved,
  });

  @override
  State<AddStudentFeeStatusScreen> createState() => _AddStudentFeeStatusScreenState();
}

class _AddStudentFeeStatusScreenState extends State<AddStudentFeeStatusScreen> {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  final academicYearController = TextEditingController();
  final annualFeeController = TextEditingController();
  final paidAmountController = TextEditingController();
  final dueAmountController = TextEditingController();

  DateTime? lastPaymentDate;
  DateTime? nextDueDate;

  bool isLoading = false;

  Future<void> pickDate({required bool isNextDue}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        if (isNextDue) {
          nextDueDate = selected;
        } else {
          lastPaymentDate = selected;
        }
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await supabase.from('student_fee_status').insert({
        'student_id': widget.student['id'],
        'academic_year': academicYearController.text.trim(),
        'annual_fee': double.parse(annualFeeController.text),
        'paid_amount': double.tryParse(paidAmountController.text) ?? 0,
        'due_amount': double.tryParse(dueAmountController.text) ?? 0,
        'last_payment_date': lastPaymentDate?.toIso8601String(),
        'next_due_date': nextDueDate?.toIso8601String(),
      });

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الحفظ: \$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة قسط جديد')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('تفاصيل القسط',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: academicYearController,
                        decoration: const InputDecoration(
                          labelText: 'السنة الدراسية',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'يرجى إدخال السنة' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: annualFeeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'القسط السنوي',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'يرجى إدخال القسط' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: paidAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'المدفوع',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: dueAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'المتبقي',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => pickDate(isNextDue: false),
                            child: Text(lastPaymentDate != null
                                ? 'آخر دفع: ${formatter.format(lastPaymentDate!)}'
                                : 'اختر تاريخ آخر دفع'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => pickDate(isNextDue: true),
                            child: Text(nextDueDate != null
                                ? 'استحقاق قادم: ${formatter.format(nextDueDate!)}'
                                : 'اختر تاريخ الاستحقاق'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('حفظ'),
                        onPressed: isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
