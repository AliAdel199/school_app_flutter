import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
  
  // متغيرات الفلترة
  String? selectedFilterCategory; // null أو "all" يعني الكل
  DateTime? filterStartDate;
  DateTime? filterEndDate;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

final userId = supabase.auth.currentUser!.id;

    // جلب school_id من جدول profiles
    final profileResponse = await supabase
        .from('profiles')
        .select('school_id')
        .eq('id', userId)
        .single();

    if (profileResponse == null || profileResponse['school_id'] == null) {
      throw Exception('لم يتم العثور على معرف المدرسة.');
    }

    final schoolId = profileResponse['school_id'];
    final exp = await supabase
  .from('expenses')
  .select()
  .eq('school_id', schoolId)
  .order('expense_date', ascending: false);


    // final exp = await supabase
    //     .from('expenses')
    //     .select().eq('school_id', supabase.auth.currentUser!.id)
    //     .order('expense_date', ascending: false);
    final cats = await supabase.from('expense_categories').select();
    setState(() {
      expenses = exp;
      categories = cats;
      isLoading = false;
    });
  }

  List getFilteredExpenses() {
    return expenses.where((expense) {
      bool matchesCategory = selectedFilterCategory == null ||
          selectedFilterCategory == 'all' ||
          expense['type'].toString() == selectedFilterCategory;
      DateTime expenseDate =
          DateTime.tryParse(expense['expense_date']) ?? DateTime.now();
      bool matchesStart = filterStartDate == null ||
          expenseDate.isAfter(filterStartDate!.subtract(const Duration(days: 1)));
      bool matchesEnd = filterEndDate == null ||
          expenseDate.isBefore(filterEndDate!.add(const Duration(days: 1)));
      return matchesCategory && matchesStart && matchesEnd;
    }).toList();
  }

  double getTotalAmount(List filteredExpenses) {
    return filteredExpenses.fold(0, (sum, item) {
      double amt = 0;
      if (item['amount'] is num) {
        amt = (item['amount'] as num).toDouble();
      }
      return sum + amt;
    });
  }

  String getCategoryName(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c['id'].toString() == categoryId,
      orElse: () => <String, dynamic>{},
    );
    return cat.isNotEmpty ? cat['name'] : '-';
  }

  // دالة لتصدير البيانات إلى Excel
  Future<void> exportExpensesToExcel(List filteredExpenses) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Expenses'];
    // كتابة header
    sheetObject.appendRow([
      TextCellValue('العنوان'),
      TextCellValue('المبلغ'),
      TextCellValue('التصنيف'),
      TextCellValue('التاريخ'),
      TextCellValue('الملاحظات'),
    ]);
    // كتابة البيانات
    for (var exp in filteredExpenses) {
      sheetObject.appendRow([
        TextCellValue(exp['title'].toString()),
        TextCellValue(exp['amount'].toString()),
        TextCellValue(getCategoryName(exp['type'].toString())),
        TextCellValue(exp['expense_date'].toString()),
        TextCellValue(exp['note']?.toString() ?? '')
      ]);
    }
    // حفظ الملف
    final bytes = excel.encode();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ExpensesReport.xlsx');
    await file.writeAsBytes(bytes!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ التقرير: ${file.path}')),
    );
  }

  // دالة لطباعة التقرير عبر إنشاء PDF مع دعم اللغة العربية وتحسين التصميم
  Future<void> printExpensesReport(List filteredExpenses) async {
    final pdf = pw.Document();

    // إعداد خط يدعم العربية
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'تقرير المصروفات',
                  style: pw.TextStyle(
                    font: arabicBoldFont,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: [
                    'العنوان',
                    'المبلغ',
                    'التصنيف',
                    'التاريخ',
                    'الملاحظات'
                  ],
                  data: filteredExpenses.map((e) {
                    return [
                      e['title'] ?? '',
                      e['amount']?.toString() ?? '',
                      getCategoryName(e['type'].toString()),
                      e['expense_date'] ?? '',
                      e['note'] ?? ''
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    font: arabicBoldFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 11,
                  ),
                  cellAlignment: pw.Alignment.centerRight,
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  border: pw.TableBorder.all(
                    color: PdfColors.grey600,
                    width: 0.5,
                  ),
                  cellHeight: 28,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1.2),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FlexColumnWidth(2.5),
                  },
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'إجمالي المصروفات: ${getTotalAmount(filteredExpenses)}',
                    style: pw.TextStyle(
                      font: arabicBoldFont,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
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
final userId = supabase.auth.currentUser!.id;
                 // جلب school_id من جدول profiles
    final profileResponse = await supabase
        .from('profiles')
        .select('school_id')
        .eq('id', userId)
        .single();

    if (profileResponse == null || profileResponse['school_id'] == null) {
      throw Exception('لم يتم العثور على معرف المدرسة.');
    }

    final schoolId = profileResponse['school_id'];
                await Supabase.instance.client
                    .from('expense_categories')
                    .insert({'name': name, 'school_id':schoolId});
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
                    items: categories
                        .map<DropdownMenuItem<String>>((cat) =>
                            DropdownMenuItem(value: cat['id'].toString(), child: Text(cat['name'])))
                        .toList(),
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
final userId = supabase.auth.currentUser!.id;

    // جلب school_id من جدول profiles
    final profileResponse = await supabase
        .from('profiles')
        .select('school_id')
        .eq('id', userId)
        .single();

    if (profileResponse == null || profileResponse['school_id'] == null) {
      throw Exception('لم يتم العثور على معرف المدرسة.');
    }

    final schoolId = profileResponse['school_id'];

                  await Supabase.instance.client.from('expenses').insert({
                    'title': titleController.text.trim(),
                    'amount': double.tryParse(amountController.text) ?? 0,
                    'type': selectedCategory,
                    'school_id': schoolId,
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

  Future<void> showEditExpenseDialog(
    BuildContext context,
    Map expense,
    List categories,
    void Function() onSuccess,
  ) async {
    final titleController = TextEditingController(text: expense['title']);
    final amountController = TextEditingController(text: expense['amount'].toString());
    final noteController = TextEditingController(text: expense['note'] ?? '');
    DateTime selectedDate = DateTime.tryParse(expense['expense_date']) ?? DateTime.now();
    String? selectedCategory = expense['type'];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('تعديل مصروف'),
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
                    items: categories
                        .map<DropdownMenuItem<String>>((cat) =>
                            DropdownMenuItem(value: cat['id'].toString(), child: Text(cat['name'])))
                        .toList(),
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

                  await Supabase.instance.client.from('expenses').update({
                    'title': titleController.text.trim(),
                    'amount': double.tryParse(amountController.text) ?? 0,
                    'type': selectedCategory,
                    'expense_date': selectedDate.toIso8601String().split('T').first,
                    'note': noteController.text,
                  }).eq('id', expense['id']);
                  Navigator.pop(ctx);
                  onSuccess();
                },
                child: const Text('حفظ التعديلات'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showDeleteExpenseDialog(
    BuildContext context,
    Map expense,
    void Function() onSuccess,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await supabase.from('expenses').delete().eq('id', expense['id']);
      onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    List filteredExpenses = getFilteredExpenses();
    double totalAmount = getTotalAmount(filteredExpenses);
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصروفات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'طباعة التقرير',
            onPressed: () => printExpensesReport(filteredExpenses),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'تصدير Excel',
            onPressed: () => exportExpensesToExcel(filteredExpenses),
          ),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
      type: ExpandableFabType.up,
  pos: ExpandableFabPos.center,
  fanAngle: 180,
        // fanAngle: 180,
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
              // تأكد من أن التصنيفات موجودة
              showAddExpenseDialog(context, categories, fetchData);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // قسم الفلترة
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // فلترة حسب النوع
                        Row(
                          children: [
                            const Text('التصنيف: '),
                            DropdownButton<String>(
                              value: selectedFilterCategory,
                              hint: const Text('الكل'),
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text('الكل'),
                                ),
                                ...categories.map<DropdownMenuItem<String>>((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat['id'].toString(),
                                    child: Text(cat['name']),
                                  );
                                }).toList(),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  selectedFilterCategory = val;
                                });
                              },
                            ),
                          ],
                        ),
                        // فلترة حسب التاريخ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(filterStartDate == null
                                  ? 'من تاريخ'
                                  : filterStartDate!.toString().split(' ')[0]),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: filterStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    filterStartDate = date;
                                  });
                                }
                              },
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(filterEndDate == null
                                  ? 'إلى تاريخ'
                                  : filterEndDate!.toString().split(' ')[0]),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: filterEndDate ?? DateTime.now(),
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    filterEndDate = date;
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  filterStartDate = null;
                                  filterEndDate = null;
                                });
                              },
                            ),
                          ],
                        ),
                        // زر لتحديث الفلترة وعرض إجمالي المصروفات
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text('تطبيق الفلترة'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'إجمالي المصروفات: $totalAmount',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // عرض قائمة المصروفات المفلترة
                Expanded(
                  child: filteredExpenses.isEmpty
                      ? const Center(child: Text('لا توجد مصروفات'))
                      : ListView.separated(
                          itemCount: filteredExpenses.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final exp = filteredExpenses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 2,
                              child: SizedBox(
                                height: 80,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exp['title'],
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${exp['amount']}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                          ),
                                        ),
                                        Expanded(child: Text(getCategoryName(exp['type'].toString()))),
                                        Expanded(
                                          child: Text(
                                            exp['expense_date'],
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              exp['note'] == null || exp['note'].toString().isEmpty
                                                  ? 'لا توجد ملاحظات'
                                                  : exp['note'],
                                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blue),
                                                onPressed: () async {
                                                  await showEditExpenseDialog(
                                                    context,
                                                    exp,
                                                    categories,
                                                    fetchData,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () async {
                                                  await showDeleteExpenseDialog(
                                                    context,
                                                    exp,
                                                    fetchData,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
