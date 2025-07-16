// ✅ تم تحويل الكود من Supabase إلى Isar فقط
// ✅ الكود يعرض الإيرادات ويقوم بتصديرها وطباعتها + يدعم الفلترة

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '/localdatabase/expense_category.dart';
import '/localdatabase/expense.dart';

import '/main.dart';
import '../localdatabase/income_category.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _IncomesListScreenState();
}

class _IncomesListScreenState extends State<ExpensesListScreen> {
  List<Expense> expenses = [];
  List<ExpenseCategory> categories = [];
  bool isLoading = true;

  String? selectedFilterCategory;
  DateTime? filterStartDate;
  DateTime? filterEndDate;

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    expenses = await isar.expenses.where().sortByExpenseDateDesc().findAll();
    categories = await isar.expenseCategorys.where().findAll();
    setState(() => isLoading = false);
  }

  List<Expense> getFilteredIncomes() {
    return expenses.where((Expense) {
      bool matchesCategory = selectedFilterCategory == null ||
          selectedFilterCategory == 'all' ||
          Expense.category.value?.id.toString() == selectedFilterCategory;
      DateTime expensesDate = Expense.expenseDate;
      bool matchesStart = filterStartDate == null ||
          expensesDate.isAfter(filterStartDate!.subtract(const Duration(days: 1)));
      bool matchesEnd = filterEndDate == null ||
          expensesDate.isBefore(filterEndDate!.add(const Duration(days: 1)));
      return matchesCategory && matchesStart && matchesEnd;
    }).toList();
  }

  double getTotalAmount(List<Expense> filteredExpenses) {
    return filteredExpenses.fold(0, (sum, item) => sum + item.amount);
  }

  String getCategoryName(ExpenseCategory? category) => category?.name ?? '-';

  Future<void> exportIncomesToExcel(List<Expense> filteredExpenses) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['expenses'];
    sheetObject.appendRow([
      TextCellValue('العنوان'),
      TextCellValue('المبلغ'),
      TextCellValue('التصنيف'),
      TextCellValue('التاريخ'),
      TextCellValue('الملاحظات'),
    ]);
    for (var exp in filteredExpenses) {
      sheetObject.appendRow([
        TextCellValue(exp.title),
        TextCellValue(exp.amount.toString()),
        TextCellValue(getCategoryName(exp.category.value)),
        TextCellValue(exp.expenseDate.toIso8601String().split('T').first),
        TextCellValue(exp.note ?? '')
      ]);
    }
    final bytes = excel.encode();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/IncomesReport.xlsx');
    await file.writeAsBytes(bytes!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ التقرير: ${file.path}')),
    );
  }
Future<void> showAddIncomeDialogIsar(BuildContext context, void Function() onSuccess) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  List<ExpenseCategory> categories = await isar.expenseCategorys.where().findAll();
  ExpenseCategory? selectedCategory;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('إضافة مصروف جديد'),
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
              DropdownButtonFormField<ExpenseCategory>(
                value: selectedCategory,
                hint: const Text('اختر الفئة'),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('اختر التاريخ'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              Text(
                'التاريخ: ${selectedDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.grey[700]),
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
              final title = titleController.text.trim();
              final amount = double.tryParse(amountController.text.trim());

              if (title.isEmpty || amount == null || selectedCategory == null) return;

              final expense = Expense()
                ..title = title
                ..amount = amount
                ..note = noteController.text.trim()
                ..expenseDate = selectedDate
                ..academicYear = academicYear // إضافة السنة الدراسية الحالية
                ..category.value = selectedCategory;

              await isar.writeTxn(() async {
                await isar.expenses.put(expense);
                await expense.category.save(); // حفظ الربط
              });

              Navigator.pop(ctx);
              onSuccess();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الإيراد')));
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    ),
  );
}

  Future<void> showAddIncomeCategoryDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('إضافة فئة مصروف'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'اسم الفئة'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;

            final identifier = name.toLowerCase().replaceAll(' ', '_');

            final exists = await isar.incomeCategorys
                .filter()
                .identifierEqualTo(identifier)
                .findFirst();

            if (exists == null) {
              final category = ExpenseCategory()
                ..name = name
                ..identifier = identifier;

              await isar.writeTxn(() async {
                await isar.expenseCategorys.put(category);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تمت إضافة الفئة "$name"')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الفئة موجودة مسبقًا')),
              );
            }

            Navigator.pop(ctx);
          },
          child: const Text('إضافة'),
        ),
      ],
    ),
  );
}


  Future<void> printIncomesReport(List<Expense> filteredExpenses) async {
    final pdf = pw.Document();
    final arabicFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
    final arabicBoldFont =pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Bold.ttf'));

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
                pw.Text('تقرير الإيرادات',
                    style: pw.TextStyle(font: arabicBoldFont, fontSize: 24)),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: ['العنوان', 'المبلغ', 'التصنيف', 'التاريخ', 'الملاحظات'],
                  data: filteredExpenses.map((e) => [
                        e.title,
                        e.amount.toString(),
                        getCategoryName(e.category.value),
                        e.expenseDate.toIso8601String().split('T').first,
                        e.note ?? ''
                      ]).toList(),
                  headerStyle: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
                  cellStyle: pw.TextStyle(font: arabicFont, fontSize: 11),
                  cellAlignment: pw.Alignment.centerRight,
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
                  cellHeight: 28,
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'إجمالي الإيرادات: ${getTotalAmount(filteredExpenses)}',
                  style: pw.TextStyle(font: arabicBoldFont, fontSize: 16, color: PdfColors.green800),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
Future<void> showEditIncomeDialog(BuildContext context, Expense Expense, void Function() onSuccess) async {
  final titleController = TextEditingController(text: Expense.title);
  final amountController = TextEditingController(text: Expense.amount.toString());
  final noteController = TextEditingController(text: Expense.note ?? '');
  DateTime selectedDate = Expense.expenseDate;
  await Expense.category.load();
  List<ExpenseCategory> categories = await isar.expenseCategorys.where().findAll();
  ExpenseCategory? selectedCategory = Expense.category.value;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('تعديل الإيراد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'المبلغ'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<ExpenseCategory>(
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
                child: const Text('اختر التاريخ'),
              ),
              Text('التاريخ: ${selectedDate.toLocal().toString().split(' ')[0]}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Expense.title = titleController.text.trim();
              Expense.amount = double.tryParse(amountController.text.trim()) ?? 0;
              Expense.note = noteController.text.trim();
              Expense.expenseDate = selectedDate;
              Expense.academicYear = academicYear; // تحديث السنة الدراسية
              Expense.category.value = selectedCategory;

              await isar.writeTxn(() async {
                await isar.expenses.put(Expense);
                await Expense.category.save();
              });

              Navigator.pop(ctx);
              onSuccess();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل الإيراد')));
            },
            child: const Text('حفظ التعديلات'),
          )
        ],
      ),
    ),
  );
}
Future<void> deleteIncome(int id) async {
  await isar.writeTxn(() async {
    await isar.expenses.delete(id); // حذف الإيراد حسب الـ ID
  });
  await fetchData(); // إعادة تحميل البيانات لتحديث الشاشة
}
@override
Widget build(BuildContext context) {
  final filtered = getFilteredIncomes();
  final formatter = NumberFormat('#,###');

  return Scaffold(
    appBar: AppBar(title: const Text('قائمة المصروفات'),actions: [ SizedBox(width: 150,
                        child:  ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // يمكنك تغيير القيمة حسب الرغبة
    ),
  ),
                          onPressed: () => exportIncomesToExcel(filtered),
                          icon: const Icon(Icons.file_download),
                          label: const Text('تصدير Excel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(width: 150,
                        child:  ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // يمكنك تغيير القيمة حسب الرغبة
    ),
  ),
                          onPressed: () => printIncomesReport(filtered),
                          icon: const Icon(Icons.print),
                          label: const Text('طباعة PDF'),
                        ),
                      ),
                          const SizedBox(width: 10,),
                      SizedBox(width: 150,
                        child:  ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // يمكنك تغيير القيمة حسب الرغبة
    ),
  ),
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة مصروف'),
                          onPressed: () => showAddIncomeDialogIsar(context, fetchData),
                        ),),
                      const SizedBox(width: 10,),
                      SizedBox(width: 150,
                        child:  ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // يمكنك تغيير القيمة حسب الرغبة
    ),
  ),
                        
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة فئة'),
                          onPressed: () => showAddIncomeCategoryDialog(context),
                        ),
                      ),
                      const SizedBox(width: 10,),

],),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // --- أداة الفلترة ---
                Row(
                  children: [
                    // فلتر الفئة
                    SizedBox(
                      width: 150,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedFilterCategory ?? 'all',
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('كل الفئات')),
                          ...categories.map((cat) => DropdownMenuItem(
                                value: cat.id.toString(),
                                child: Text(cat.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedFilterCategory = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // زر اختيار تاريخ البداية
                    SizedBox(width: 150,
                      child: ElevatedButton(                          style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // يمكنك تغيير القيمة حسب الرغبة
    ),
  ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: filterStartDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              filterStartDate = picked;
                            });
                          }
                        },
                        child: Text(filterStartDate == null
                            ? 'تاريخ البداية'
                            : 'من: ${filterStartDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // زر اختيار تاريخ النهاية
                    SizedBox(width: 150,
                      child: ElevatedButton(                          style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // يمكنك تغيير القيمة حسب الرغبة
    ),
  ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: filterEndDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              filterEndDate = picked;
                            });
                          }
                        },
                        child: Text(filterEndDate == null
                            ? 'تاريخ النهاية'
                            : 'إلى: ${filterEndDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // زر مسح الفلاتر
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'مسح الفلاتر',
                      onPressed: () {
                        setState(() {
                          selectedFilterCategory = 'all';
                          filterStartDate = null;
                          filterEndDate = null;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // عرض مجموع الإيرادات بعد الفلترة
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'إجمالي الإيرادات: ${formatter.format(getTotalAmount(filtered))} د.ع',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final Expense = filtered[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(Expense.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('المبلغ: ${formatter.format(Expense.amount)} د.ع'),
                              Text('التصنيف: ${getCategoryName(Expense.category.value)}'),
                              Text('التاريخ: ${Expense.expenseDate.toIso8601String().split('T').first}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => showEditIncomeDialog(context, Expense, fetchData),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('تأكيد الحذف'),
                                          content: const Text('هل أنت متأكد أنك تريد حذف هذا الإيراد؟'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) await deleteIncome(Expense.id);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
  );
}


//   @override
//   Widget build(BuildContext context) {
//     final filtered = getFilteredIncomes();
//     final formatter = NumberFormat('#,###');

//     return Scaffold(
//       appBar: AppBar(title: const Text('قائمة الإيرادات')),

//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                      // SizedBox(width: 150,
                      //   child:  ElevatedButton.icon(

                      //     onPressed: () => exportIncomesToExcel(filtered),
                      //     icon: const Icon(Icons.file_download),
                      //     label: const Text('تصدير Excel'),
                      //   ),
                      // ),
                      // const SizedBox(width: 10),
                      // SizedBox(width: 150,
                      //   child:  ElevatedButton.icon(

                      //     onPressed: () => printIncomesReport(filtered),
                      //     icon: const Icon(Icons.print),
                      //     label: const Text('طباعة PDF'),
                      //   ),
                      // ),
                      //     SizedBox(width: 10,),
                      // SizedBox(width: 150,
                      //   child:  ElevatedButton.icon(

                      //     icon: Icon(Icons.add),
                      //     label: Text('إضافة مصروف'),
                      //     onPressed: () => showAddIncomeDialogIsar(context, fetchData),
                      //   ),),
                      // SizedBox(width: 10,),
                      // SizedBox(width: 150,
                      //   child:  ElevatedButton.icon(

                      //     icon: Icon(Icons.add),
                      //     label: Text('إضافة فئة'),
                      //     onPressed: () => showAddIncomeCategoryDialog(context),
                      //   ),
                      // ),

                  //   ],
                  // ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: filtered.length,
//                       itemBuilder: (context, index) {
//                         final Expense = filtered[index];
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           child: ListTile(
//                             title: Text(Expense.title ?? ''),
//                             subtitle: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Text('المبلغ: ${formatter.format(Expense.amount)} د.ع'),
//     Text('التصنيف: ${getCategoryName(Expense.category.value)}'),
//     Text('التاريخ: ${Expense.expensesDate.toIso8601String().split('T').first}'),
//     Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         IconButton(
//           icon: Icon(Icons.edit, color: Colors.blue),
//           onPressed: () => showEditIncomeDialog(context, Expense, fetchData),
//         ),
//         IconButton(
//           icon: Icon(Icons.delete, color: Colors.red),
//           onPressed: () async {
//             final confirm = await showDialog<bool>(
//               context: context,
//               builder: (ctx) => AlertDialog(
//                 title: Text('تأكيد الحذف'),
//                 content: Text('هل أنت متأكد أنك تريد حذف هذا الإيراد؟'),
//                 actions: [
//                   TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('إلغاء')),
//                   ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('حذف')),
//                 ],
//               ),
//             );
//             if (confirm == true) await deleteIncome(Expense.id);
//           },
//         ),
//       ],
//     )
//   ],
// )

//                           ),
//                         );
                    
//                       },
//                     ),
//                   )
//                 ],
//               ),
//             ),
//     );
//   }

}
