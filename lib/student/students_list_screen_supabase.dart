import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:school_app_flutter/student/add_student_screen_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_student_screen.dart';
import 'delete_student_dialog.dart';
import 'studentpaymentscreen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }
List<Map<String, dynamic>> classOptions = [];


String? selectedClassId;
String? selectedStatus;

void filterStudents() {
  setState(() {
    final query = searchQuery.toLowerCase();

    filteredStudents = students.where((student) {
      final fullName = student['full_name']?.toString().toLowerCase() ?? '';
      final studentId = student['id']?.toString().toLowerCase() ?? '';
      final nationalId = student['national_id']?.toString().toLowerCase() ?? '';
      final className = student['classes']?['name']?.toString();
      final status = student['status']?.toString();

      final matchesQuery = fullName.contains(query) ||
          studentId.contains(query) ||
          nationalId.contains(query);

      final matchesClass = selectedClassId == null || selectedClassId == className;
      final matchesStatus = selectedStatus == null || selectedStatus == status;

      return matchesQuery && matchesClass && matchesStatus;
    }).toList();
  });
}


Future<void> exportToExcel() async {
  final excel = Excel.createExcel();
  final sheet = excel['الطلاب'];
sheet.appendRow([
  TextCellValue('الاسم الكامل'),
  TextCellValue('الرقم الوطني'),
  TextCellValue('رقم الطالب'),
  TextCellValue('الجنس'),
  TextCellValue('تاريخ الميلاد'),
  TextCellValue('اسم ولي الأمر'),
  TextCellValue('هاتف ولي الأمر'),
  TextCellValue('الهاتف'),
  TextCellValue('البريد الإلكتروني'),
  TextCellValue('العنوان'),
  TextCellValue('الصف'),
  TextCellValue('الحالة'),
  TextCellValue('سنة التسجيل'),
  TextCellValue('الرسوم السنوية'),
  TextCellValue('تاريخ الإنشاء'),
]);

for (final student in filteredStudents) {
  sheet.appendRow([
    TextCellValue(student['full_name'] ?? ''),
    TextCellValue(student['national_id'] ?? ''),
    TextCellValue(student['id'] ?? ''),
    TextCellValue(student['gender'] ?? ''),
    TextCellValue(student['birth_date']?.toString().split('T').first ?? ''),
    TextCellValue(student['parent_name'] ?? ''),
    TextCellValue(student['parent_phone'] ?? ''),
    TextCellValue(student['phone'] ?? ''),
    TextCellValue(student['email'] ?? ''),
    TextCellValue(student['address'] ?? ''),
    TextCellValue(student['classes']?['name'] ?? ''),
    TextCellValue(student['status'] ?? ''),
    TextCellValue(student['registration_year'] ?? ''),
    TextCellValue(student['annual_fee']?.toString() ?? ''),
    TextCellValue(student['created_at']?.toString().split('T').first ?? ''),
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



Future<void> fetchStudents() async {
  setState(() => isLoading = true);
  try {
    final classRes = await supabase
    .from('classes')
    .select('id, name');

classOptions = List<Map<String, dynamic>>.from(classRes);

    // جلب school_id من ملف التعريف للمستخدم الحالي
    final profile = await supabase
        .from('profiles')
        .select('school_id')
        .eq('id', supabase.auth.currentUser!.id)
        .single();

    final schoolId = profile['school_id'];

    // جلب الطلاب المرتبطين فقط بهذه المدرسة
 final res = await supabase
    .from('students')
    .select('*, classes(name)')
    .eq('school_id', schoolId)
    .order('full_name', ascending: true);

    students = List<Map<String, dynamic>>.from(res);
    filterStudents(); // لتطبيق البحث إذا كان هناك استعلام
  } catch (e) {
    debugPrint('خطأ في جلب الطلاب: \n$e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل الطلاب: \n\n$e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
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
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-student')
                  .then((_) => fetchStudents());
            },
            icon: const Icon(Icons.add),
            tooltip: 'إضافة طالب',
          ),
 

        ],
  //       bottom: PreferredSize(
  //         preferredSize: const Size.fromHeight(60),
  //         child: Padding(
  //           padding: const EdgeInsets.all(12),
  //           child:
  //             Wrap(alignment: WrapAlignment.spaceAround,runAlignment: WrapAlignment.spaceAround,
  //   spacing: 12,
  //   runSpacing: 12,
  //   children: [
  //              Padding(
  //                padding: const EdgeInsets.only(top: 8.0),
  //                child: SizedBox(
  //                  width: 200,
  //                  child: ElevatedButton.icon(
  //                    onPressed: exportToExcel,
  //                    icon: const Icon(Icons.file_download),
  //                    label: const Text('تصدير Excel'),
  //                  ),
  //                ),
  //              ),
  //     SizedBox(width: 250,
  //       child: Card(elevation: 2,
  //         child: DropdownButton<String>(elevation: 5,isExpanded: true,borderRadius: BorderRadius.circular(12),underline: const SizedBox(),
  //           hint: const Text('تصفية حسب الصف'),
  //           value: selectedClassId,
  //           onChanged: (val) {
  //             setState(() {
  //               selectedClassId = val;
  //               filterStudents();
  //             });
  //           },
  //           items: [
  //   const DropdownMenuItem(
  //     value: null,
  //     child: Text('إظهار الجميع'),
  //   ),
  //   ...classOptions.map((c) {
  //     return DropdownMenuItem(
  //       value: c['name'].toString(),
  //       child: Text(c['name'] ?? '_'),
  //     );
  //   }).toList(),
  // ],
  //         ),
  //       ),
  //     ),
  //       Padding(
  //          padding: const EdgeInsets.only(top: 7.0),
  //          child: SizedBox(width: 400,
  //                   child: TextField(
  //                     decoration: InputDecoration(
  //                       hintText: 'ابحث عن طالب بالاسم...',
  //                       filled: true,
  //                       fillColor: Colors.white,
  //                       prefixIcon: const Icon(Icons.search),
  //                       border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(12)),
  //                     ),
  //                     onChanged: (val) {
  //                       searchQuery = val;
  //                       filterStudents();
  //                     },
  //                   ),
  //                 ),
  //        ),
  //     SizedBox(width: 250,
  //       child:  Card(elevation: 2,
  //         child: DropdownButton<String>(elevation: 5,isExpanded: true,borderRadius: BorderRadius.circular(12),underline: const SizedBox(),
  //           hint: const Text('تصفية حسب الحالة'),
  //           value: selectedStatus,
  //           onChanged: (val) {
  //             setState(() {
  //               selectedStatus = val;
  //               filterStudents();
  //             });
  //           },
  //           items: const [
  //               DropdownMenuItem(
  //     value: null,
  //     child: Text('إظهار الجميع'),
  //   ),
  //             DropdownMenuItem(value: 'active', child: Text('فعال')),
  //             DropdownMenuItem(value: 'inactive', child: Text('غير فعال')),
  //             DropdownMenuItem(value: 'graduated', child: Text('متخرج')),
  //             DropdownMenuItem(value: 'transferred', child: Text('منقول')),
  //           ],
  //         ),
  //       ),
  //     ),
       
              
  //   ],
  // ),

         
  //         ),
  //       ),
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
      SizedBox(width: 250,
        child: Card(elevation: 2,
          child: DropdownButton<String>(elevation: 5,isExpanded: true,borderRadius: BorderRadius.circular(12),underline: const SizedBox(),
            hint: const Text('تصفية حسب الصف'),
            value: selectedClassId,
            onChanged: (val) {
              setState(() {
                selectedClassId = val;
                filterStudents();
              });
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
    }).toList(),
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
                        filterStudents();
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
                filterStudents();
              });
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
                                        children: _buildStudentInfo(student),
                                      ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StudentPaymentsScreen(
                                              student: {
                                                'id': student['id'],
                                                'full_name': student['full_name'],
                                                'annual_fee': student['annual_fee'],
                                              },
                                            ),
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
                                            builder: (_) => AddEditStudentScreen(
                                              student: student,
                                            ),
                                          ),
                                        );
                                        fetchStudents(); // إعادة تحميل بعد التعديل
                                      },
                                      icon: const Icon(Icons.edit, size: 20),
                                      label: const Text('تعديل'),
                                    ),
                                    const SizedBox(width: 12),
                                    TextButton.icon(
                                      onPressed: () async {
                                        await showDeleteStudentDialog(
                                          context,
                                          student,
                                          fetchStudents,
                                        );
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

  List<Widget> _buildStudentInfo(Map<String, dynamic> student) {
    return [
      // استخدم Flexible بدل Expanded أو فقط Text إذا لم تكن داخل Row
      Flexible(
        flex: 3,
        child: Text(
          student['full_name'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        flex: 2,
        child: Text(
          'الصف: ${student['classes']?['name'] ?? '-'}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        flex: 2,
        child: Text(
          'الهوية: ${student['national_id'] ?? '-'}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        child: Align(
          alignment: Alignment.centerRight,
          child: Chip(
            label: Text(student['status']),
            backgroundColor: getStatusColor(student['status']).withOpacity(0.2),
            labelStyle: TextStyle(color: getStatusColor(student['status'])),
          ),
        ),
      ),
    ];
  }
}
