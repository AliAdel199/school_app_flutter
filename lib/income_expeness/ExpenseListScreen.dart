import 'package:flutter/material.dart';
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

  String getCategoryName(String categoryId) {
    final cat = categories.firstWhere((c) => c['id'] == categoryId, orElse: () => null);
    return cat != null ? cat['name'] : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المصروفات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // اذهب لواجهة إضافة مصروف
          await Navigator.pushNamed(context, '/add-expense');
          fetchData();
        },
        child: const Icon(Icons.add),
      ),
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
