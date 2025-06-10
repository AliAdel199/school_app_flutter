import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final supabase = Supabase.instance.client;
  List expenses = [];
  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final exp = await supabase.from('expenses').select().order('expense_date', ascending: false);
    final cats = await supabase.from('expense_categories').select();
    setState(() {
      expenses = exp;
      categories = cats;
      isLoading = false;
    });
  }
Future<void> showAddExpenseCategoryDialog(BuildContext context, void Function() onSuccess) async {
  final TextEditingController categoryController = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('إضافة نوع مصروف جديد'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(labelText: 'اسم النوع'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = categoryController.text.trim();
              if (name.isEmpty) return;
              await Supabase.instance.client
                  .from('expense_categories')
                  .insert({'name': name});
              Navigator.pop(ctx);
              onSuccess();
            },
            child: const Text('إضافة'),
          ),
        ],
      );
    },
  );
}

Future<void> showAddExpenseDialog(BuildContext context, List categories, void Function() onSuccess) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة مصروف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان المصروف'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map<DropdownMenuItem<String>>((cat) =>
                    DropdownMenuItem(value: cat['id'], child: Text(cat['name']))
                  ).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val),
                  decoration: const InputDecoration(labelText: 'نوع المصروف'),
                ),
                ListTile(
                  title: Text('التاريخ: ${selectedDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
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
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                  minLines: 1,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    amountController.text.trim().isEmpty ||
                    selectedCategory == null) return;

                await Supabase.instance.client.from('expenses').insert({
                  'title': titleController.text.trim(),
                  'amount': double.tryParse(amountController.text) ?? 0,
                  'type': selectedCategory,
                  'expense_date': selectedDate.toIso8601String().split('T').first,
                  'note': noteController.text,
                });
                Navigator.pop(ctx);
                onSuccess();
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      );
    },
  );
}

  String getCategoryName(String categoryId) {
    final cat = categories.firstWhere((c) => c['id'] == categoryId, orElse: () => null);
    return cat != null ? cat['name'] : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المصروفات')),
      floatingActionButtonLocation: ExpandableFab.location,
            floatingActionButton: ExpandableFab(
                type: ExpandableFabType.up,
  pos: ExpandableFabPos.center,
  fanAngle: 180,
              children: [
            
                 FloatingActionButton.extended(
        heroTag: null,
        label: const Text('إضافة نوع مصروف'),
        icon: const Icon(Icons.edit),
        onPressed: () {
       showAddExpenseCategoryDialog(context, fetchData);
        },
      ),
                     FloatingActionButton.extended(
        heroTag: null,
        label: const Text('إضافة مصروف'),
        icon: const Icon(Icons.edit),
        onPressed: () {
       showAddExpenseDialog(context, categories, fetchData);
        },
      ),
              // FloatingActionButton.extended( 
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const AddClassScreen(),
              //       ),
              //     );
              //   },
              //   label: const Text('إضافة صف'),
              //   icon: const Icon(Icons.add),
              // ),
              //       FloatingActionButton.extended(
              //   onPressed: () {
              //     showAddGradeDialog();
              //   },
              //   label: const Text('إضافة مرحلة'),
              //   icon: const Icon(Icons.add),
              // ),
           
              // FloatingActionButton.extended(
              //   onPressed: () {
              //     // إضافة شاشة جديدة
              //   },
              //   label: const Text('إضافة مادة'),
              //   icon: const Icon(Icons.add),
              // ),
            ]),
      // FloatingActionButton(
      //   onPressed: () async {
      //     // اذهب لواجهة إضافة مصروف
      //     await Navigator.pushNamed(context, '/add-expense');
      //     fetchData();
      //   },
      //   child: const Icon(Icons.add),
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final exp = expenses[index];
                return ListTile(
                  leading: Text('${exp['amount']} د.ع'),
                  title: Text(exp['title']),
                  subtitle: Text('${getCategoryName(exp['type'])} - ${exp['expense_date']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/add-edit-expense', arguments: exp);
                      fetchData();
                    },
                  ),
                  onLongPress: () async {
                    await supabase.from('expenses').delete().eq('id', exp['id']);
                    fetchData();
                  },
                );
              },
            ),
    );
  }
}
