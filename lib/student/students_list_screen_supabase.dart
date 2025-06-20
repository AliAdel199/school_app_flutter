import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:printing/printing.dart';
import 'package:school_app_flutter/dashboard_screen.dart';
import 'package:school_app_flutter/localdatabase/class.dart';
// import 'package:school_app_flutter/localdatabase/students/StudentService.dart';
import 'package:school_app_flutter/student/add_student_screen_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../localdatabase/student.dart';
import '../main.dart';
import 'edit_student_screen.dart';
import 'delete_student_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    // fetchStudentsFromIsar();
    fetchStudentsFromIsar();
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

  // Future<void> fetchClasses() async {
  //   try {
  //     final res = await supabase
  //         .from('classes')
  //         .select('id, name')
  //         .order('name', ascending: true);

  //     classOptions = List<Map<String, dynamic>>.from(res);
  //   } catch (e) {
  //     debugPrint('خطأ في جلب الصفوف: \n$e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('فشل تحميل الصفوف: \n\n$e')),
  //       );
  //     }
  //   }
  // }



  Future<void> fetchStudentsFromIsar() async {
    setState(() => isLoading = true);
    try {
      // جلب جميع الطلاب من قاعدة بيانات Isar
      final isarStudents = await isar.students.where().findAll();

      students = isarStudents;


      // تطبيق الفلاتر
      final query = searchQuery.toLowerCase();
      filteredStudents = students.where((student) {
        final fullName = student.fullName?.toLowerCase() ?? '';
        final studentId = student.id?.toString().toLowerCase() ?? '';
        final nationalId = student.nationalId?.toLowerCase() ?? '';
        final className = student.schoolclass.value?.name.trim();
        final status = student.status?.toString();

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

// Future<void> fetchStudentsFromIsar() async {
//   setState(() => isLoading = true);
//   try {
//   //  StudentService studentService = StudentService(isar);
//     // final isarStudents = await studentService.getAllStudents();
//     // students = isarStudents;
//     filteredStudents = students.where((student) {
//       final fullName = student.fullName?.toLowerCase() ?? '';
//       final studentId = student.id?.toString().toLowerCase() ?? '';
//       final nationalId = student.nationalId?.toLowerCase() ?? '';
//       // final className = student.classId?.toString();
//       final status = student.status?.toString();

//       final matchesQuery = fullName.contains(searchQuery.toLowerCase()) ||
//           studentId.contains(searchQuery.toLowerCase()) ||
//           nationalId.contains(searchQuery.toLowerCase());

//       // final matchesClass = selectedClassId == null || selectedClassId == className;
//       final matchesStatus = selectedStatus == null || selectedStatus == status;

//       return matchesQuery && matchesClass && matchesStatus;
//     }).toList();
//     filteredStudents.forEach((e) {
//   print( 'Student: ${e.fullName}, ID: ${e.serverId}, Class: ${e.classId}, Status: ${e.status}');
//     });
//     // تحويل الطلاب من Isar إلى Map<String, dynamic> لتسهيل التصفية
//     // filterStudents();
//   } catch (e) {
//     debugPrint('خطأ في جلب الطلاب من Isar: \n$e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('فشل تحميل الطلاب من Isar: \n\n$e')),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }
// }
// // void filterStudents() {
// //   setState(() {
// //     final query = searchQuery.toLowerCase();

// //     filteredStudents = students.where((student) {
//       final fullName = student.fullName?.toLowerCase() ?? '';
//       final studentId = student.id?.toString().toLowerCase() ?? '';
//       final nationalId = student.nationalId?.toLowerCase() ?? '';
//       final className = student.classId?.toString();
//       final status = student.status?.toString();

//       final matchesQuery = fullName.contains(query) ||
//           studentId.contains(query) ||
//           nationalId.contains(query);

//       final matchesClass = selectedClassId == null || selectedClassId == className;
//       final matchesStatus = selectedStatus == null || selectedStatus == status;

//       return matchesQuery && matchesClass && matchesStatus;
//     }).toList();
//   });
// }


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
    TextCellValue(student.fullName ?? ''),
    TextCellValue(student.nationalId ?? ''),
    TextCellValue(student.id?.toString() ?? ''),
    TextCellValue(student.gender ?? ''),
    TextCellValue(student.birthDate?.toString().split(' ').first ?? ''),
    TextCellValue(student.parentName ?? ''),
    TextCellValue(student.parentPhone ?? ''),
    TextCellValue(student.phone ?? ''),
    TextCellValue(student.email ?? ''),
    TextCellValue(student.address ?? ''),
    // TextCellValue(student.classId ?? ''), // Ensure you have a className property or adjust accordingly
    TextCellValue(student.status ?? ''),
    TextCellValue(student.registrationYear?.toString() ?? ''),
    TextCellValue(student.annualFee?.toString() ?? ''),
    TextCellValue(student.createdAt?.toString().split(' ').first ?? ''),
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



// Future<void> fetchStudents() async {
//   setState(() => isLoading = true);
//   try {
//     final classRes = await supabase
//     .from('classes')
//     .select('id, name');

// classOptions = List<Map<String, dynamic>>.from(classRes);

//     // جلب school_id من ملف التعريف للمستخدم الحالي
//     final profile = await supabase
//         .from('profiles')
//         .select('school_id')
//         .eq('id', supabase.auth.currentUser!.id)
//         .single();

//     final schoolId = profile['school_id'];

//     // جلب الطلاب المرتبطين فقط بهذه المدرسة
//  final res = await supabase
//     .from('students')
//     .select('*, classes(name)')
//     .eq('school_id', schoolId)
//     .order('full_name', ascending: true);

//     students = List<Map<String, dynamic>>.from(res);
//     filterStudents(); // لتطبيق البحث إذا كان هناك استعلام
//   } catch (e) {
//     debugPrint('خطأ في جلب الطلاب: \n$e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('فشل تحميل الطلاب: \n\n$e')),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }
// }

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
              // Navigator.pushNamed(context, '/add-student')
              //     .then((_) => fetchStudentsFromIsar());
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
                // fetchStudentsFromIsar();
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
                        // fetchStudentsFromIsar();
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
                // fetchStudentsFromIsar();
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
                                            content: Text('هل أنت متأكد أنك تريد حذف الطالب "${student.fullName ?? ''}"؟ لا يمكن التراجع عن هذه العملية.'),
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
                                            await isar.students.delete(student.id!);
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

  List<Widget> _buildStudentInfo(Student student) {
    return [
      // استخدم Flexible بدل Expanded أو فقط Text إذا لم تكن داخل Row
      Flexible(
        flex: 3,
        child: Text(
          student.fullName ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Flexible(
        flex: 2,
        child: Text(
          'الصف: hhhhh ?? ''}',
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
            label: Text(student.status ?? ''),
            backgroundColor: getStatusColor(student.status ?? '').withOpacity(0.2),
            labelStyle: TextStyle(color: getStatusColor(student.status ?? '')),
          ),
        ),
      ),
    ];
  }
}
