import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? expense;
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController noteController;
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  List categories = [];

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    titleController = TextEditingController(text: widget.expense?['title'] ?? '');
    amountController = TextEditingController(text: widget.expense?['amount']?.toString() ?? '');
    noteController = TextEditingController(text: widget.expense?['note'] ?? '');
    selectedCategory = widget.expense?['type'];
    if (widget.expense?['expense_date'] != null) {
      selectedDate = DateTime.parse(widget.expense!['expense_date']);
    }
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final cats = await supabase.from('expense_categories').select();
    setState(() => categories = cats);
  }

  Future<void> saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final expenseData = {
      'title': titleController.text,
      'amount': double.tryParse(amountController.text) ?? 0,
      'expense_date': selectedDate.toIso8601String().split('T').first,
      'type': selectedCategory,
      'note': noteController.text,
      // يمكنك إضافة school_id هنا إذا كان عندك صلاحيات مدارس
    };
    if (widget.expense == null) {
      await supabase.from('expenses').insert(expenseData);
    } else {
      await supabase.from('expenses').update(expenseData).eq('id', widget.expense!['id']);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'إضافة مصروف' : 'تعديل مصروف')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'عنوان المصروف'),
              validator: (v) => v == null || v.isEmpty ? 'أدخل العنوان' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'المبلغ'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'أدخل المبلغ' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: selectedCategory,
              items: categories
                  .map<DropdownMenuItem<String>>((cat) => DropdownMenuItem(
                        value: cat['id'],
                        child: Text(cat['name']),
                      ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'نوع المصروف'),
              onChanged: (val) => setState(() => selectedCategory = val as String),
              validator: (v) => v == null ? 'اختر نوع المصروف' : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text('تاريخ المصروف: ${selectedDate.toString().split(' ')[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => selectedDate = date);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveExpense,
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
