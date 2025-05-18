import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentPaymentScreen extends StatefulWidget {
  final String studentId;
  final String academicYear;

  const AddStudentPaymentScreen({
    super.key,
    required this.studentId,
    required this.academicYear,
  });

  @override
  State<AddStudentPaymentScreen> createState() =>
      _AddStudentPaymentScreenState();
}

class _AddStudentPaymentScreenState extends State<AddStudentPaymentScreen> {
  final supabase = Supabase.instance.client;
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  DateTime paidAt = DateTime.now();
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> addPayment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final amount = double.parse(amountController.text.trim());
      final receiptNumber = 'R-${DateTime.now().millisecondsSinceEpoch}';

      await supabase.from('student_payments').insert({
        'student_id': widget.studentId,
        'amount': amount,
        'paid_at': paidAt.toIso8601String(),
        'notes': notesController.text,
        'academic_year': widget.academicYear,
        'receipt_number': receiptNumber,
      });

      Navigator.pop(context); // الرجوع بعد النجاح
    } catch (e) {
      debugPrint('فشل إضافة الدفع: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الإضافة: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دفعة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ'),
                validator: (val) {
                  if (val == null || double.tryParse(val) == null) {
                    return 'يرجى إدخال مبلغ صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.date_range),
                  const SizedBox(width: 10),
                  Text('تاريخ الدفع: ${DateFormat('yyyy-MM-dd').format(paidAt)}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: paidAt,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          paidAt = picked;
                        });
                      }
                    },
                    child: const Text('اختيار تاريخ'),
                  )
                ],
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: addPayment,
                      child: const Text('إضافة'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
