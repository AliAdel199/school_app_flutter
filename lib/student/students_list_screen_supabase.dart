import 'dart:typed_data';

import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:printing/printing.dart';
import 'package:school_app_flutter/localdatabase/expense.dart';
import 'package:school_app_flutter/localdatabase/student_fee_status.dart';
import '../localdatabase/expense_category.dart';
import '../helpers/program_info.dart';
import 'package:file_picker/file_picker.dart';

import '/localdatabase/class.dart';
// import '/localdatabase/students/StudentService.dart';
import '/student/add_student_screen_supabase.dart';

import '../localdatabase/student.dart';
import '../main.dart';
import '../reports/student_transfer_helper.dart';


import 'studentpaymentscreen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  // final supabase = Supabase.instance.client;
  List<Student> students = [];
  List<Student> filteredStudents = [];
  bool isLoading = true;
  String searchQuery = '';
  
  // إضافة متغيرات للسنة الدراسية
  List<String> availableAcademicYears = [];
  String? selectedAcademicYearForStats;

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    // fetchStudentsFromIsar();
    fetchStudentsFromIsar();
    loadAvailableAcademicYears();
   
  }

  // تحميل السنوات الدراسية المتاحة
  Future<void> loadAvailableAcademicYears() async {
    try {
      final feeStatuses = await isar.studentFeeStatus.where().findAll();
      final years = feeStatuses.map((status) => status.academicYear).toSet().toList();
      years.sort((a, b) => b.compareTo(a)); // ترتيب تنازلي (الأحدث أولاً)
      
      setState(() {
        availableAcademicYears = years;
        selectedAcademicYearForStats = academicYear; // افتراضياً السنة الحالية
      });
    } catch (e) {
      debugPrint('خطأ في تحميل السنوات الدراسية: $e');
    }
  }

List<Map<String, dynamic>> classOptions = [];


String? selectedClassId;
String? selectedStatus;

Future<void> fetchClassesFromIsar() async {
  try {
    final isarClasses = await isar.schoolClass.where().findAll();
    classOptions = isarClasses
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'level': c.level, // أضف هذا
            })
        .toList();
    if (mounted) setState(() {});
  } catch (e) {
    debugPrint('خطأ في جلب الصفوف من Isar: \n$e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل الصفوف من Isar: \n\n$e')),
      );
    }
  }
}


  Future<void> fetchStudentsFromIsar() async {
    setState(() => isLoading = true);
    try {
      // جلب جميع الطلاب من قاعدة بيانات Isar
      final isarStudents = await isar.students.where().findAll();

      students = isarStudents;


      // تطبيق الفلاتر
      final query = searchQuery.toLowerCase();
      filteredStudents = students.where((student) {
        final fullName = student.fullName.toLowerCase();
        final studentId = student.id.toString().toLowerCase();
        final nationalId = student.nationalId?.toLowerCase() ?? '';
        final className = student.schoolclass.value?.name.trim();
        final status = student.status.toString();

        final matchesQuery = fullName.contains(query) ||
            studentId.contains(query) ||
            nationalId.contains(query);

        final matchesClass = selectedClassId == null || selectedClassId == className;
        final matchesStatus = selectedStatus == null || selectedStatus == status;

        return matchesQuery && matchesClass && matchesStatus;
      }).toList();
    } catch (e) {
      debugPrint('خطأ في جلب الطلاب من Isar: \n$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل الطلاب من Isar: \n\n$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchClassesFromIsar();
    // fetchClasses();
  }




Future<void> exportToExcel() async {
  final excel = excel_lib.Excel.createExcel();
  final sheet = excel['الطلاب'];
sheet.appendRow([
  excel_lib.TextCellValue('الاسم الكامل'),
  excel_lib.TextCellValue('الرقم الوطني'),
  excel_lib.TextCellValue('رقم الطالب'),
  excel_lib.TextCellValue('الجنس'),
  excel_lib.TextCellValue('تاريخ الميلاد'),
  excel_lib.TextCellValue('اسم ولي الأمر'),
  excel_lib.TextCellValue('هاتف ولي الأمر'),
  excel_lib.TextCellValue('الهاتف'),
  excel_lib.TextCellValue('البريد الإلكتروني'),
  excel_lib.TextCellValue('العنوان'),
  excel_lib.TextCellValue('الصف'),
  excel_lib.TextCellValue('الحالة'),
  excel_lib.TextCellValue('سنة التسجيل'),
  excel_lib.TextCellValue('الرسوم السنوية'),
  excel_lib.TextCellValue('تاريخ الإنشاء'),
]);

for (final student in filteredStudents) {
  sheet.appendRow([
    excel_lib.TextCellValue(student.fullName),
    excel_lib.TextCellValue(student.nationalId ?? ''),
    excel_lib.TextCellValue(student.id.toString()),
    excel_lib.TextCellValue(student.gender ?? ''),
    excel_lib.TextCellValue(student.birthDate?.toString().split(' ').first ?? ''),
    excel_lib.TextCellValue(student.parentName ?? ''),
    excel_lib.TextCellValue(student.parentPhone ?? ''),
    excel_lib.TextCellValue(student.phone ?? ''),
    excel_lib.TextCellValue(student.email ?? ''),
    excel_lib.TextCellValue(student.address ?? ''),
    excel_lib.TextCellValue(student.status),
    excel_lib.TextCellValue(student.registrationYear?.toString() ?? ''),
    excel_lib.TextCellValue(student.annualFee?.toString() ?? ''),
    excel_lib.TextCellValue(student.createdAt.toString().split(' ').first),
  ]);
}


  

  final fileBytes = excel.encode();
  if (fileBytes != null) {
    await Printing.sharePdf(
      bytes: Uint8List.fromList(fileBytes),
      filename: 'students_list.xlsx',
    );
  }
}





  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'graduated':
        return Colors.blue;
      case 'transferred':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلاب'),
        actions: [
          ProgramInfo.buildInfoButton(context),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/auto-discount');
            },
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'الخصومات التلقائية',
          ),
          IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/add-student')
              //     .then((_) => fetchStudentsFromIsar());
            },
            icon: const Icon(Icons.add),
            tooltip: 'إضافة طالب',
          ),
 

        ],
  
      ),
      body:
      
  Column(children: [
//     Expanded(flex: 1,
//       child: Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   child: 
  

// ),
// ),
 PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
              Wrap(alignment: WrapAlignment.spaceAround,runAlignment: WrapAlignment.spaceAround,
    spacing: 12,
    runSpacing: 12,
    children: [
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: SizedBox(
                   width: 200,
                   child: ElevatedButton.icon(
                     onPressed: exportToExcel,
                     icon: const Icon(Icons.file_download),
                     label: const Text('تصدير Excel'),
                   ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: SizedBox(
                   width: 200,
                   child: ElevatedButton.icon(
                     onPressed: importFromExcel,
                     icon: const Icon(Icons.file_upload),
                     label: const Text('استيراد Excel'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       foregroundColor: Colors.white,
                     ),
                   ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: SizedBox(
                   width: 200,
                   child: ElevatedButton.icon(
                     onPressed: downloadExcelTemplate,
                     icon: const Icon(Icons.download),
                     label: const Text('تحميل القالب'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue,
                       foregroundColor: Colors.white,
                     ),
                   ),
                 ),
               ),
      SizedBox(width: 250,
        child: Card(elevation: 2,
          child: DropdownButton<String>(elevation: 5,isExpanded: true,borderRadius: BorderRadius.circular(12),underline: const SizedBox(),
            hint: const Text('تصفية حسب الصف'),
            value: selectedClassId,
            onChanged: (val) {
              setState(() {
                selectedClassId = val;
              });
              fetchStudentsFromIsar();
            },
            items: [
    const DropdownMenuItem(
      value: null,
      child: Text('إظهار الجميع'),
    ),
    ...classOptions.map((c) {
      return DropdownMenuItem(
        value: c['name'].toString(),
        child: Text(c['name'] ?? '_'),
      );
    }),
  ],
          ),
        ),
      ),
        Padding(
           padding: const EdgeInsets.only(top: 7.0),
           child: SizedBox(width: 400,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن طالب بالاسم...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) {
                        searchQuery = val;
                        fetchStudentsFromIsar();
                      },
                    ),
                  ),
         ),
      SizedBox(width: 250,
        child:  Card(elevation: 2,
          child: DropdownButton<String>(elevation: 5,isExpanded: true,borderRadius: BorderRadius.circular(12),underline: const SizedBox(),
            hint: const Text('تصفية حسب الحالة'),
            value: selectedStatus,
            onChanged: (val) {
              setState(() {
                selectedStatus = val;
              });
              fetchStudentsFromIsar();
            },
            items: const [
                DropdownMenuItem(
      value: null,
      child: Text('إظهار الجميع'),
    ),
              DropdownMenuItem(value: 'active', child: Text('فعال')),
              DropdownMenuItem(value: 'inactive', child: Text('غير فعال')),
              DropdownMenuItem(value: 'graduated', child: Text('متخرج')),
              DropdownMenuItem(value: 'transferred', child: Text('منقول')),
            ],
          ),
        ),
      ),
       
              
    ],
  ),

         
          ),
        ),
        // إضافة بطاقة الإحصائيات السريعة
        _buildQuickStatsCard(),
    Expanded(flex: 9,
      child:  isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredStudents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isWide
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: _buildStudentInfo(student),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: _buildStudentInfoMobile(student),
                                      ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
  onPressed: () async {
    final refundController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد انسحاب الطالب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل تريد تسجيل انسحاب الطالب "${student.fullName}"؟'),
            const SizedBox(height: 10),
            TextField(
              controller: refundController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'مبلغ الاسترجاع',
                hintText: 'أدخل المبلغ بالدينار',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final refundAmount = double.tryParse(refundController.text) ?? 0;

await isar.writeTxn(() async {
  // تحديث حالة الطالب
  student.status = 'inactive';
  await isar.students.put(student);

  // تصفير المبلغ المتبقي إن وجد
  final feeStatus = await isar.studentFeeStatus
      .filter()
      .studentIdEqualTo(student.id.toString())
      .findFirst();
  if (feeStatus != null) {
    feeStatus.dueAmount = 0;
    await isar.studentFeeStatus.put(feeStatus);
  }

  // جلب فئة المصروف "استرجاع قسط" أو إنشائها إذا لم تكن موجودة
  ExpenseCategory? refundCategory = await isar.expenseCategorys
      .filter()
      .nameEqualTo('استرجاع قسط')
      .findFirst();

  if (refundCategory == null) {
    refundCategory = ExpenseCategory()
      ..name = 'استرجاع قسط'
      ..identifier = 'refund_fee';
    refundCategory.id = await isar.expenseCategorys.put(refundCategory);
  }

  // إضافة مصروف استرجاع
  final expense = Expense()
    ..title = 'استرجاع قسط للطالب ${student.fullName}'
    ..amount = refundAmount
    ..expenseDate = DateTime.now()
    ..note = 'استرجاع قسط للطالب ${student.fullName}'
    ..archived = false
    ..category.value = refundCategory;
  await isar.expenses.put(expense);
  await expense.category.save();
});

      fetchStudentsFromIsar(); // تحديث الواجهة
    }
  },
  icon: const Icon(Icons.exit_to_app),
  label: const Text('انسحاب'),
  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
),
TextButton.icon(
  icon: const Icon(Icons.arrow_upward, color: Colors.blue),
  label: const Text('ترحيل', style: TextStyle(color: Colors.blue)),
  onPressed: () async {
    final currentClass = student.schoolclass.value;
    final currentLevel = currentClass?.level ?? 0;
    final higherClasses = classOptions
        .where((c) => (c['level'] ?? 0) > currentLevel)
        .toList();

    if (higherClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد صفوف أعلى لترحيل الطالب إليها.')),
      );
      return;
    }

    String? selectedNewClassId;
    final annualFeeController = TextEditingController(
      text: student.annualFee?.toString() ?? '',
    );
    final newAcademicYearController = TextEditingController(text: academicYear);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('ترحيل الطالب'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('اختر الصف الجديد للطالب "${student.fullName}"'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedNewClassId,
                  items: higherClasses.map((c) {
                    return DropdownMenuItem(
                      value: c['id'].toString(),
                      child: Text(c['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) async {
                    setState(() {
                      selectedNewClassId = val;
                    });
                    if (val != null) {
                      final newClass = await isar.schoolClass.get(int.parse(val));
                      setState(() {
                        annualFeeController.text = newClass?.annualFee?.toString() ?? '';
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'الصف الجديد',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: annualFeeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'القسط السنوي الجديد',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newAcademicYearController,
                  decoration: const InputDecoration(
                    labelText: 'السنة الدراسية الجديدة',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedNewClassId == null || newAcademicYearController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى اختيار الصف الجديد وإدخال السنة الدراسية الجديدة.')),
                    );
                    return;
                  }
                  
                  final newAcademicYear = newAcademicYearController.text.trim();
                  final exists = await isar.studentFeeStatus
                      .filter()
                      .studentIdEqualTo(student.id.toString())
                      .academicYearEqualTo(newAcademicYear)
                      .findFirst();
                      
                  if (exists != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الطالب لديه سجل قسط لنفس السنة الدراسية بالفعل!')),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true && selectedNewClassId != null) {
      final newClass = await isar.schoolClass.get(int.parse(selectedNewClassId!));
      final newFee = double.tryParse(annualFeeController.text) ?? student.annualFee ?? 0;
      final newAcademicYear = newAcademicYearController.text.trim();

      // جلب آخر سجل قسط للطالب (أحدث سنة دراسية)
      final allFeeStatuses = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(student.id.toString())
          .sortByAcademicYearDesc()
          .findAll();
      
      final currentFeeStatus = allFeeStatuses.isNotEmpty ? allFeeStatuses.first : null;

      debugPrint('البحث عن سجل القسط للطالب ID: ${student.id}');
      debugPrint('جميع سجلات الأقساط للطالب: ${allFeeStatuses.length}');
      if (currentFeeStatus != null) {
        debugPrint('آخر سجل قسط: السنة ${currentFeeStatus.academicYear}, الصف ${currentFeeStatus.className}');
      } else {
        debugPrint('لا يوجد أي سجل قسط للطالب');
      }
      
      double previousDue = 0;
      if (currentFeeStatus != null) {
        // حساب المبلغ المتبقي الفعلي
        final totalRequired = currentFeeStatus.annualFee + currentFeeStatus.transferredDebtAmount - currentFeeStatus.discountAmount;
        final totalPaid = currentFeeStatus.paidAmount;
        previousDue = totalRequired - totalPaid;
        
        debugPrint('القسط السنوي: ${currentFeeStatus.annualFee}');
        debugPrint('الدين المنقول: ${currentFeeStatus.transferredDebtAmount}');
        debugPrint('المبلغ المدفوع: $totalPaid');
        debugPrint('المبلغ المتبقي المحسوب: $previousDue');
      } else {
        debugPrint('⚠️ لا يوجد سجل قسط للطالب في هذه السنة الدراسية');
        // يمكن أن نبحث في جميع سجلات الأقساط للطالب
        final allFeeStatuses = await isar.studentFeeStatus
            .filter()
            .studentIdEqualTo(student.id.toString())
            .findAll();
        debugPrint('جميع سجلات الأقساط للطالب: ${allFeeStatuses.length}');
        for (var status in allFeeStatuses) {
          debugPrint('- السنة: ${status.academicYear}, القسط: ${status.annualFee}, المدفوع: ${status.paidAmount}, المتبقي: ${status.dueAmount}');
        }
      }

      if (previousDue > 0) {
        debugPrint('يوجد مبلغ متبقي: $previousDue - سيتم عرض حوار التسوية');
        
        // إضافة تفاصيل عن طبيعة الدين
        String debtDetails = '';
        if (currentFeeStatus != null) {
          final currentYearDebt = previousDue - currentFeeStatus.transferredDebtAmount;
          if (currentFeeStatus.transferredDebtAmount > 0) {
            debtDetails = '\n\nتفاصيل الدين:\n'
                '• دين من سنوات سابقة: ${currentFeeStatus.transferredDebtAmount.toStringAsFixed(2)} د.ع\n'
                '• دين السنة الحالية: ${currentYearDebt.toStringAsFixed(2)} د.ع\n'
                '• السنة الأصلية للدين: ${currentFeeStatus.originalDebtAcademicYear ?? "غير معروف"}\n'
                '• الصف الأصلي للدين: ${currentFeeStatus.originalDebtClassName ?? "غير معروف"}';
          } else {
            debtDetails = '\n\nهذا دين من السنة الحالية فقط.';
          }
        }
        
        // إذا كان هناك مبلغ متبقي، اعرض خيارات التسوية
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تسوية الأقساط السابقة'),
            content: Text(
                'يوجد مبلغ متبقي (${previousDue.toStringAsFixed(2)} د.ع) من القسط السابق.$debtDetails\n\nاختر طريقة التسوية:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'pay_all'),
                child: const Text('دفع المتبقي بالكامل'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'move_due'),
                child: const Text('نقل المتبقي مع القسط الجديد'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        );

        if (action == null) return;

        // استخدام الـ Helper الجديد للترحيل
        final transferHelper = StudentTransferHelper(isar);
        final success = await transferHelper.transferStudent(
          student: student,
          newClass: newClass!,
          newAnnualFee: newFee,
          newAcademicYear: newAcademicYear,
          currentAcademicYear: academicYear,
          debtHandlingAction: action,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم ترحيل الطالب بنجاح.')),
          );
          fetchStudentsFromIsar();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في ترحيل الطالب.')),
          );
        }
      } else {
        debugPrint('لا يوجد مبلغ متبقي: $previousDue - سيتم الترحيل العادي');
        // إذا لم يكن هناك متبقي، نفذ الترحيل العادي
        final transferHelper = StudentTransferHelper(isar);
        final success = await transferHelper.transferStudent(
          student: student,
          newClass: newClass!,
          newAnnualFee: newFee,
          newAcademicYear: newAcademicYear,
          currentAcademicYear: academicYear,
          debtHandlingAction: 'pay_all', // لا يهم لأنه لا يوجد دين
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم ترحيل الطالب بنجاح.')),
          );
          fetchStudentsFromIsar();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في ترحيل الطالب.')),
          );
        }
      }
    }
  },
),
                
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StudentPaymentsScreen(studentId: student.id,fullName: student.fullName,student: student,),
                                              // student: {
                                              //   'id': student.id,
                                              //   'full_name': student.fullName,
                                              //   'annual_fee': student.annualFee,
                                              // },
                                            
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.payment, size: 20),
                                      label: const Text('دفعات الطالب'),
                                    ),
                                    const SizedBox(width: 12),
                                    TextButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddEditStudentScreen(student: student,),  
                                          ),
                                        );
                                        // fetchStudentsFromIsar(); // إعادة تحميل بعد التعديل
                                      },
                                      icon: const Icon(Icons.edit, size: 20),
                                      label: const Text('تعديل'),
                                    ),
                                    const SizedBox(width: 12),
                                    TextButton.icon(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('تأكيد الحذف'),
                                            content: Text('هل أنت متأكد أنك تريد حذف الطالب "${student.fullName}"؟ لا يمكن التراجع عن هذه العملية.'),
                                            actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('إلغاء'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                                              child: const Text('حذف'),
                                            ),
                                            ],
                                          ),
                                          );
                                          if (confirm == true) {
                                          await isar.writeTxn(() async {
                                            await isar.students.delete(student.id);
                                          });
                                          await fetchStudentsFromIsar();
                                          }
                                      },
                                      icon: const Icon(Icons.delete, size: 20),
                                      label: const Text('حذف'),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),)
  ],)
    );
  }

  List<Widget> _buildStudentInfoMobile(Student student) {
    return [
      Text(
        student.fullName,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text('الصف: ${student.schoolclass.value!.name}'),
      const SizedBox(height: 4),
      Text('الهوية: ${student.nationalId ?? '-'}'),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          label: Text(student.status),
          backgroundColor: getStatusColor(student.status).withOpacity(0.2),
          labelStyle: TextStyle(color: getStatusColor(student.status)),
        ),
      ),
    ];
  }

  List<Widget> _buildStudentInfo(Student student) {
    return [
      // استخدم Flexible بدل Expanded أو فقط Text إذا لم تكن داخل Row
      Flexible(
        flex: 3,
        child: Text(
          student.fullName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        flex: 2,
        child: Text(
          'الصف: ${student.schoolclass.value!.name} ',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        flex: 2,
        child: Text(
          'الهوية: ${student.nationalId ?? '-'}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        child: Align(
          alignment: Alignment.centerRight,
          child: Chip(
            label: Text(student.status),
            backgroundColor: getStatusColor(student.status).withOpacity(0.2),
            labelStyle: TextStyle(color: getStatusColor(student.status)),
          ),
        ),
      ),
    ];
  }

  // حساب الإحصائيات المالية السريعة
  Future<Map<String, dynamic>> _calculateQuickStats() async {
    try {
      // استخدام السنة المختارة أو السنة الحالية
      final yearToUse = selectedAcademicYearForStats ?? academicYear;
      
      final feeStatuses = await isar.studentFeeStatus
          .filter()
          .academicYearEqualTo(yearToUse)
          .findAll();
      
      double totalExpected = 0;
      double totalPaid = 0;
      double totalRemaining = 0;
      double totalDiscounts = 0;
      int studentsWithDebts = 0;
      int paidStudents = 0;
      
      for (var status in feeStatuses) {
        totalExpected += status.annualFee + status.transferredDebtAmount;
        totalPaid += status.paidAmount;
        totalRemaining += status.dueAmount ?? 0;
        totalDiscounts += status.discountAmount;
        
        if ((status.dueAmount ?? 0) > 0) {
          studentsWithDebts++;
        } else {
          paidStudents++;
        }
      }
      
      return {
        'totalExpected': totalExpected,
        'totalPaid': totalPaid,
        'totalRemaining': totalRemaining,
        'totalDiscounts': totalDiscounts,
        'studentsWithDebts': studentsWithDebts,
        'paidStudents': paidStudents,
        'totalStudents': feeStatuses.length,
        'collectionRate': totalExpected > 0 ? (totalPaid / totalExpected) * 100 : 0,
        'selectedYear': yearToUse,
      };
    } catch (e) {
      return {};
    }
  }

  // بناء بطاقة إحصائيات سريعة
  Widget _buildQuickStatsCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _calculateQuickStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container();
        }
        
        final stats = snapshot.data!;
        
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان مع فلتر السنة الدراسية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الإحصائيات المالية',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (availableAcademicYears.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedAcademicYearForStats,
                          hint: const Text('اختر السنة'),
                          underline: Container(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAcademicYearForStats = newValue;
                            });
                          },
                          items: availableAcademicYears.map<DropdownMenuItem<String>>((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(
                                year,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'السنة الدراسية: ${stats['selectedYear']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickStatChip(
                      'إجمالي مطلوب', 
                      '${stats['totalExpected'].toStringAsFixed(0)} د.ع',
                      Colors.blue,
                    ),
                    _buildQuickStatChip(
                      'محصل', 
                      '${stats['totalPaid'].toStringAsFixed(0)} د.ع',
                      Colors.green,
                    ),
                    _buildQuickStatChip(
                      'متبقي', 
                      '${stats['totalRemaining'].toStringAsFixed(0)} د.ع',
                      Colors.red,
                    ),
                    _buildQuickStatChip(
                      'نسبة التحصيل', 
                      '${stats['collectionRate'].toStringAsFixed(1)}%',
                      Colors.purple,
                    ),
                    _buildQuickStatChip(
                      'طلاب مدينون', 
                      '${stats['studentsWithDebts']}',
                      Colors.orange,
                    ),
                    _buildQuickStatChip(
                      'طلاب مكتملون', 
                      '${stats['paidStudents']}',
                      Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> importFromExcel() async {
  try {
    // اختيار ملف Excel
    FilePickerResult? result = await FilePicker .platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final excel = excel_lib.Excel.decodeBytes(bytes);
      
      // التحقق من وجود ورقة العمل
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];
      
      if (sheet == null) {
        throw Exception('لا توجد بيانات في الملف');
      }

      // عرض نافذة تأكيد مع معاينة البيانات
      final shouldImport = await _showImportPreviewDialog(sheet);
      if (!shouldImport) return;

      setState(() => isLoading = true);

      // قراءة البيانات وإنشاء الطلاب
      List<Student> newStudents = [];
      List<String> errors = [];
      int skippedRows = 0;
      
      // البدء من السطر الثاني (تجاهل العناوين)
      for (int i = 1; i < sheet.maxRows; i++) {
        try {
          final row = sheet.rows[i];
          
          // التحقق من وجود بيانات في السطر
          if (row.isEmpty || _isRowEmpty(row)) {
            skippedRows++;
            continue;
          }

          // قراءة البيانات من الأعمدة
          final fullName = _getCellValue(row, 0)?.trim();
          final nationalId = _getCellValue(row, 1)?.trim();
          final gender = _getCellValue(row, 2)?.trim();
          final birthDateStr = _getCellValue(row, 3)?.trim();
          final parentName = _getCellValue(row, 4)?.trim();
          final parentPhone = _getCellValue(row, 5)?.trim();
          final phone = _getCellValue(row, 6)?.trim();
          final email = _getCellValue(row, 7)?.trim();
          final address = _getCellValue(row, 8)?.trim();
          final className = _getCellValue(row, 9)?.trim();
          final status = _getCellValue(row, 10)?.trim() ?? 'active';
          final registrationYearStr = _getCellValue(row, 11)?.trim();
          final annualFeeStr = _getCellValue(row, 12)?.trim();

          // التحقق من البيانات الأساسية
          if (fullName == null || fullName.isEmpty) {
            errors.add('السطر ${i + 1}: اسم الطالب مطلوب');
            continue;
          }

          // البحث عن الصف
          SchoolClass? schoolClass;
          if (className != null && className.isNotEmpty) {
            schoolClass = await isar.schoolClass
                .filter()
                .nameEqualTo(className)
                .findFirst();
            
            if (schoolClass == null) {
              errors.add('السطر ${i + 1}: الصف "$className" غير موجود');
              continue;
            }
          }

          // تحويل التاريخ
          DateTime? birthDate;
          if (birthDateStr != null && birthDateStr.isNotEmpty) {
            try {
              // محاولة تحويل التاريخ بصيغة مختلفة
              birthDate = DateTime.parse(birthDateStr);
            } catch (e) {
              errors.add('السطر ${i + 1}: تاريخ الميلاد غير صحيح "$birthDateStr"');
            }
          }

          // تحويل سنة التسجيل
          String? registrationYear;
          if (registrationYearStr != null && registrationYearStr.isNotEmpty) {
            registrationYear = registrationYearStr;
          }

          // تحويل القسط السنوي
          double? annualFee;
          if (annualFeeStr != null && annualFeeStr.isNotEmpty) {
            annualFee = double.tryParse(annualFeeStr.replaceAll(',', ''));
          }

          // إنشاء كائن الطالب
          final student = Student()
            ..fullName = fullName
            ..nationalId = nationalId
            ..gender = gender
            ..birthDate = birthDate
            ..parentName = parentName
            ..parentPhone = parentPhone
            ..phone = phone
            ..email = email
            ..address = address
            ..status = status
            
            ..registrationYear = registrationYear
            ..annualFee = annualFee ?? schoolClass?.annualFee ?? 0
            ..createdAt = DateTime.now();

          // ربط الصف
          if (schoolClass != null) {
            student.schoolclass.value = schoolClass;
            
          }

          newStudents.add(student);

        } catch (e) {
          errors.add('السطر ${i + 1}: خطأ في معالجة البيانات - $e');
        }
      }

      // حفظ الطلاب في قاعدة البيانات
      if (newStudents.isNotEmpty) {
        await isar.writeTxn(() async {
          for (final student in newStudents) {
            final studentId = await isar.students.put(student);
            await student.schoolclass.save();
            
            // تعيين الـ ID للطالب إذا كان جديد
            if (student.id != studentId) {
              student.id = studentId;
            }
            
            // إنشاء سجل قسط للطالب
            await _createFeeStatusForStudent(student);
          }
        });
      }

      setState(() => isLoading = false);

      // عرض نتائج الاستيراد
      _showImportResultsDialog(
        imported: newStudents.length,
        errors: errors,
        skipped: skippedRows,
      );

      // تحديث قائمة الطلاب
      if (newStudents.isNotEmpty) {
        fetchStudentsFromIsar();
      }

    }
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خطأ في استيراد الملف: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// دالة مساعدة لاستخراج قيمة الخلية
String? _getCellValue(List<excel_lib.Data?> row, int index) {
  if (index >= row.length || row[index] == null) return null;
  return row[index]!.value?.toString();
}

// دالة مساعدة للتحقق من أن السطر فارغ
bool _isRowEmpty(List<excel_lib.Data?> row) {
  return row.every((cell) => cell == null || cell.value == null || cell.value.toString().trim().isEmpty);
}

// عرض نافذة معاينة البيانات قبل الاستيراد
Future<bool> _showImportPreviewDialog(excel_lib.Sheet sheet) async {
  final headerRow = sheet.rows.isNotEmpty ? sheet.rows[0] : null;
  final dataRows = sheet.rows.length > 1 ? sheet.rows.sublist(1, sheet.rows.length > 6 ? 6 : sheet.rows.length) : <List<excel_lib.Data?>>[];

  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('معاينة بيانات الاستيراد'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('عدد الصفوف: ${sheet.maxRows - 1}'),
            const SizedBox(height: 10),
            const Text('التنسيق المتوقع للأعمدة:'),
            const Text('1. الاسم الكامل | 2. الرقم الوطني | 3. الجنس | 4. تاريخ الميلاد'),
            const Text('5. اسم ولي الأمر | 6. هاتف ولي الأمر | 7. الهاتف | 8. البريد الإلكتروني'),
            const Text('9. العنوان | 10. الصف | 11. الحالة | 12. سنة التسجيل | 13. الرسوم السنوية'),
            const SizedBox(height: 15),
            const Text('عينة من البيانات:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: headerRow?.map((cell) => DataColumn(
                      label: Text(
                        cell?.value?.toString() ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    )).toList() ?? [],
                    rows: dataRows.map((row) => DataRow(
                      cells: row.map((cell) => DataCell(
                        Text(
                          cell?.value?.toString() ?? '',
                          style: const TextStyle(fontSize: 11),
                        ),
                      )).toList(),
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('متابعة الاستيراد'),
        ),
      ],
    ),
  ) ?? false;
}

// عرض نتائج الاستيراد
void _showImportResultsDialog({
  required int imported,
  required List<String> errors,
  required int skipped,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('نتائج الاستيراد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تم استيراد: $imported طالب'),
          Text('تم تجاهل: $skipped سطر فارغ'),
          Text('الأخطاء: ${errors.length}'),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('تفاصيل الأخطاء:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: errors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      error,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    ),
  );
}

Future<void> downloadExcelTemplate() async {
  try {
    final excel = excel_lib.Excel.createExcel();
    final sheet = excel['قالب_الطلاب'];
    
    // إضافة العناوين
    sheet.appendRow([
      excel_lib.TextCellValue('الاسم الكامل *'),
      excel_lib.TextCellValue('الرقم الوطني'),
      excel_lib.TextCellValue('الجنس'),
      excel_lib.TextCellValue('تاريخ الميلاد (dd/mm/yyyy)'),
      excel_lib.TextCellValue('اسم ولي الأمر'),
      excel_lib.TextCellValue('هاتف ولي الأمر'),
      excel_lib.TextCellValue('الهاتف'),
      excel_lib.TextCellValue('البريد الإلكتروني'),
      excel_lib.TextCellValue('العنوان'),
      excel_lib.TextCellValue('الصف *'),
      excel_lib.TextCellValue('الحالة'),
      excel_lib.TextCellValue('سنة التسجيل'),
      excel_lib.TextCellValue('الرسوم السنوية'),
    ]);

    // إضافة بعض الأمثلة
    sheet.appendRow([
      excel_lib.TextCellValue('أحمد محمد علي'),
      excel_lib.TextCellValue('12345678901'),
      excel_lib.TextCellValue('ذكر'),
      excel_lib.TextCellValue('15/01/2010'),
      excel_lib.TextCellValue('محمد علي'),
      excel_lib.TextCellValue('07701234567'),
      excel_lib.TextCellValue('07801234567'),
      excel_lib.TextCellValue('ahmed@example.com'),
      excel_lib.TextCellValue('بغداد - الكرادة'),
      excel_lib.TextCellValue('الصف الأول'),
      excel_lib.TextCellValue('active'),
      excel_lib.TextCellValue('2024-2025'),
      excel_lib.TextCellValue('500000'),
    ]);

    sheet.appendRow([
      excel_lib.TextCellValue('فاطمة حسن'),
      excel_lib.TextCellValue('12345678902'),
      excel_lib.TextCellValue('أنثى'),
      excel_lib.TextCellValue('22/03/2009'),
      excel_lib.TextCellValue('حسن محمد'),
      excel_lib.TextCellValue('07701234568'),
      excel_lib.TextCellValue('07801234568'),
      excel_lib.TextCellValue('fatima@example.com'),
      excel_lib.TextCellValue('البصرة - المعقل'),
      excel_lib.TextCellValue('الصف الثاني'),
      excel_lib.TextCellValue('active'),
      excel_lib.TextCellValue('2024-2025'),
      excel_lib.TextCellValue('600000'),
    ]);

    // إضافة ورقة التعليمات
    final instructionsSheet = excel['التعليمات'];
    instructionsSheet.appendRow([excel_lib.TextCellValue('تعليمات استيراد بيانات الطلاب')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('الحقول المطلوبة (يجب ملؤها):')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• الاسم الكامل: اسم الطالب الكامل')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• الصف: يجب أن يطابق اسم صف موجود في النظام')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('الحقول الاختيارية:')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• الرقم الوطني: 11 رقم')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• الجنس: ذكر أو أنثى')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• تاريخ الميلاد: بصيغة dd/mm/yyyy')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• اسم ولي الأمر')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• هاتف ولي الأمر')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• الهاتف')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• البريد الإلكتروني')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• العنوان')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• الحالة: active, inactive, graduated, transferred')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• سنة التسجيل: مثل 2024-2025')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• الرسوم السنوية: رقم بدون فواصل')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('ملاحظات مهمة:')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• تأكد من وجود الصفوف في النظام قبل الاستيراد')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• لا تحذف السطر الأول (العناوين)')]);
    instructionsSheet.appendRow([excel_lib.TextCellValue('• تأكد من صحة صيغة التواريخ')]);

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(fileBytes),
        filename: 'قالب_استيراد_الطلاب.xlsx',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحميل ملف القالب بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خطأ في إنشاء ملف القالب: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// إنشاء سجل قسط للطالب الجديد
Future<void> _createFeeStatusForStudent(Student student) async {
  try {
    // التحقق من عدم وجود سجل قسط بالفعل
    final existingFeeStatus = await isar.studentFeeStatus
        .filter()
        .studentIdEqualTo(student.id.toString())
        .academicYearEqualTo(academicYear)
        .findFirst();
    
    if (existingFeeStatus != null) {
      return; // السجل موجود بالفعل
    }

    // إنشاء سجل قسط جديد
    final feeStatus = StudentFeeStatus()
      ..studentId = student.id.toString()
      ..className = student.schoolclass.value?.name ?? ''
      ..academicYear = academicYear
      ..annualFee = student.annualFee ?? 0
      ..paidAmount = 0
      ..discountAmount = 0
      ..transferredDebtAmount = 0
      ..dueAmount = student.annualFee ?? 0
      ..nextDueDate = DateTime.now().add(const Duration(days: 30))
      ..createdAt = DateTime.now();

    await isar.studentFeeStatus.put(feeStatus);
  } catch (e) {
    debugPrint('خطأ في إنشاء سجل القسط للطالب ${student.fullName}: $e');      
  }
}
}
