// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'dart:math';
// import 'localdatabase/student.dart';
// import 'localdatabase/class.dart';
// import 'localdatabase/subject.dart';
// import 'localdatabase/student_fee_status.dart';
// import 'localdatabase/attendance.dart';
// import 'main.dart';

// class TestDataGenerator extends StatefulWidget {
//   const TestDataGenerator({Key? key}) : super(key: key);

//   @override
//   State<TestDataGenerator> createState() => _TestDataGeneratorState();
// }

// class _TestDataGeneratorState extends State<TestDataGenerator> {
//   bool isGenerating = false;
//   int studentsGenerated = 0;
//   int attendanceRecordsGenerated = 0;
//   List<String> log = [];

//   // قوائم الأسماء العربية
//   final List<String> firstNames = [
//     'أحمد', 'محمد', 'علي', 'حسن', 'حسين', 'عمر', 'يوسف', 'إبراهيم', 'خالد', 'سعد',
//     'فاطمة', 'عائشة', 'زينب', 'مريم', 'خديجة', 'سارة', 'نور', 'هدى', 'رقية', 'أسماء',
//     'عبدالله', 'عبدالرحمن', 'كريم', 'طارق', 'وليد', 'ماجد', 'فيصل', 'بدر', 'نايف', 'سامي',
//     'آمنة', 'ليلى', 'هناء', 'رنا', 'دعاء', 'إيمان', 'أمل', 'فرح', 'ندى', 'شهد',
//     'عبدالعزيز', 'متعب', 'تركي', 'راشد', 'فهد', 'مشعل', 'سلطان', 'عبدالإله', 'محمود', 'أسامة'
//   ];

//   final List<String> lastNames = [
//     'الأحمد', 'المحمد', 'العلي', 'الحسن', 'الحسين', 'العمر', 'اليوسف', 'الإبراهيم', 'الخالد', 'السعد',
//     'الكريم', 'الطارق', 'الوليد', 'الماجد', 'الفيصل', 'البدر', 'النايف', 'السامي', 'المتعب', 'التركي',
//     'الراشد', 'الفهد', 'المشعل', 'السلطان', 'العبدالله', 'الصالح', 'العتيبي', 'الشمري', 'القحطاني', 'الغامدي',
//     'الحربي', 'الدوسري', 'الزهراني', 'العنزي', 'المطيري', 'الرشيدي', 'الخالدي', 'البقمي', 'الجهني', 'السبيعي',
//     'الشهري', 'العسيري', 'الحمدان', 'العريفي', 'الطويل', 'الثقفي', 'العبيد', 'السويد', 'الربيع', 'النصار'
//   ];

//   final List<String> cities = [
//     'الرياض', 'جدة', 'مكة المكرمة', 'المدينة المنورة', 'الدمام', 'الخبر', 'تبوك', 'بريدة', 'خميس مشيط', 'حائل',
//     'الطائف', 'الجبيل', 'القطيف', 'الأحساء', 'نجران', 'جازان', 'ينبع', 'أبها', 'القصيم', 'عرعر'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('مولد البيانات التجريبية'),
//         backgroundColor: Colors.blue[700],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'إنشاء بيانات تجريبية للاختبار',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text('سيتم إنشاء:'),
//                     const Text('• 100 طالب مع بيانات متنوعة'),
//                     const Text('• سجلات حضور عشوائية للطلاب'),
//                     const Text('• ربط الطلاب بالصفوف المتاحة'),
//                     const Text('• حالات دفع متنوعة'),
//                     const SizedBox(height: 16),
//                     if (isGenerating)
//                       Column(
//                         children: [
//                           const CircularProgressIndicator(),
//                           const SizedBox(height: 8),
//                           Text('تم إنشاء $studentsGenerated طالب'),
//                           Text('تم إنشاء $attendanceRecordsGenerated سجل حضور'),
//                         ],
//                       )
//                     else
//                       ElevatedButton.icon(
//                         onPressed: _generateTestData,
//                         icon: const Icon(Icons.data_usage),
//                         label: const Text('إنشاء البيانات التجريبية'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'عمليات إضافية',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         Flexible(
//                           child: ElevatedButton.icon(
//                             onPressed: _clearAllData,
//                             icon: const Icon(Icons.delete_forever),
//                             label: const Text('حذف جميع البيانات'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _generateAttendanceData,
//                             icon: const Icon(Icons.access_time),
//                             label: const Text('إنشاء سجلات حضور إضافية'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orange,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _showStatistics,
//                             icon: const Icon(Icons.analytics),
//                             label: const Text('عرض الإحصائيات'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'سجل العمليات',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: ListView.builder(
//                             itemCount: log.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 child: Text(
//                                   log[index],
//                                   style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addLog(String message) {
//     setState(() {
//       log.add('${DateTime.now().toString().substring(11, 19)}: $message');
//     });
//     // اجعل القائمة تظهر آخر سجل
//     if (log.length > 100) {
//       log.removeAt(0);
//     }
//   }

//   Future<void> _generateTestData() async {
//     setState(() {
//       isGenerating = true;
//       studentsGenerated = 0;
//       attendanceRecordsGenerated = 0;
//     });

//     try {
//       _addLog('بدء إنشاء البيانات التجريبية...');
      
//       // احصل على الصفوف المتاحة
//       final classes = await isar.schoolClass.where().findAll();
//       if (classes.isEmpty) {
//         _addLog('خطأ: لا توجد صفوف متاحة في النظام');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('يجب إضافة صفوف دراسية أولاً'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         setState(() {
//           isGenerating = false;
//         });
//         return;
//       }

//       _addLog('تم العثور على ${classes.length} صف دراسي');

//       final random = Random();
      
//       // إنشاء 100 طالب
//       for (int i = 0; i < 100; i++) {
//         await _createRandomStudent(classes, random, i + 1);
//         setState(() {
//           studentsGenerated = i + 1;
//         });
        
//         // توقف قصير لإظهار التقدم
//         if (i % 10 == 0) {
//           await Future.delayed(const Duration(milliseconds: 100));
//         }
//       }

//       _addLog('تم إنشاء 100 طالب بنجاح');
      
//       // إنشاء سجلات حضور
//       await _generateAttendanceForAllStudents();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم إنشاء البيانات التجريبية بنجاح!'),
//           backgroundColor: Colors.green,
//         ),
//       );

//     } catch (e) {
//       _addLog('خطأ في إنشاء البيانات: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في إنشاء البيانات: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }

//     setState(() {
//       isGenerating = false;
//     });
//   }

//   Future<void> _createRandomStudent(List<SchoolClass> classes, Random random, int index) async {
//     final firstName = firstNames[random.nextInt(firstNames.length)];
//     final lastName = lastNames[random.nextInt(lastNames.length)];
//     final fullName = '$firstName $lastName';
    
//     final student = Student()
//       ..fullName = fullName
//       ..gender = random.nextBool() ? 'ذكر' : 'انثى'
//       ..birthDate = DateTime(
//         2005 + random.nextInt(10), // عمر بين 10-20 سنة
//         1 + random.nextInt(12),
//         1 + random.nextInt(28),
//       )
//       ..nationalId = '${random.nextInt(9) + 1}${random.nextInt(100000000).toString().padLeft(8, '0')}'
//       ..parentName = '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}'
//       ..parentPhone = '05${random.nextInt(9)}${random.nextInt(10000000).toString().padLeft(7, '0')}'
//       ..address = '${cities[random.nextInt(cities.length)]}, حي ${random.nextInt(50) + 1}'
//       ..phone = random.nextBool() ? '05${random.nextInt(9)}${random.nextInt(10000000).toString().padLeft(7, '0')}' : null
//       ..email = random.nextBool() ? '${firstName.toLowerCase()}${random.nextInt(100)}@example.com' : null
//       ..status = ['active', 'active', 'active', 'inactive'][random.nextInt(4)] // 75% نشط
//       ..registrationYear = ['2023-2024', '2024-2025', '2025-2026'][random.nextInt(3)]
//       ..annualFee = 1000 + random.nextDouble() * 4000; // رسوم بين 1000-5000

//     // ربط بصف عشوائي
//     final randomClass = classes[random.nextInt(classes.length)];
//     student.schoolclass.value = randomClass;

//     await isar.writeTxn(() async {
//       await isar.students.put(student);
//       await student.schoolclass.save();
//     });

//     // إنشاء حالة الرسوم
//     await _createFeeStatus(student, random);

//     if (index % 10 == 0) {
//       _addLog('تم إنشاء $index طالب');
//     }
//   }

//   Future<void> _createFeeStatus(Student student, Random random) async {
//     final feeStatus = StudentFeeStatus()
//       ..academicYear = student.registrationYear ?? '2025-2026'
//       ..annualFee = student.annualFee ?? 0
//       ..paidAmount = random.nextDouble() * (student.annualFee ?? 0)
//       ..lastPaymentDate = DateTime.now().subtract(Duration(days: random.nextInt(90)))
//       ..className = student.schoolclass.value?.name ?? 'غير محدد'
//       ..studentId = student.id.toString()
//       ..discountAmount = random.nextBool() ? random.nextDouble() * 500 : 0;

//     // حساب المبلغ المتبقي
//     feeStatus.dueAmount = feeStatus.annualFee - feeStatus.paidAmount - feeStatus.discountAmount;

//     student.feeStatus.value = feeStatus;

//     await isar.writeTxn(() async {
//       await isar.studentFeeStatus.put(feeStatus);
//       await student.feeStatus.save();
//     });
//   }

//   Future<void> _generateAttendanceForAllStudents() async {
//     _addLog('بدء إنشاء سجلات الحضور...');
    
//     final students = await isar.students.where().findAll();
//     final subjects = await isar.subjects.where().findAll();
//     final random = Random();
    
//     int recordsCreated = 0;
    
//     // إنشاء سجلات حضور للشهر الماضي
//     final startDate = DateTime.now().subtract(const Duration(days: 30));
    
//     for (final student in students) {
//       await student.schoolclass.load();
      
//       // إنشاء سجلات حضور لكل يوم تقريباً (مع بعض الأيام المفقودة)
//       for (int day = 0; day < 30; day++) {
//         final date = startDate.add(Duration(days: day));
        
//         // تخطي عطلة نهاية الأسبوع أحياناً
//         if (date.weekday == DateTime.friday || date.weekday == DateTime.saturday) {
//           if (random.nextBool()) continue; // 50% احتمال عدم وجود دراسة
//         }
        
//         // 85% احتمال وجود سجل حضور
//         if (random.nextDouble() < 0.85) {
//           await _createAttendanceRecord(student, subjects, date, random);
//           recordsCreated++;
          
//           if (recordsCreated % 50 == 0) {
//             setState(() {
//               attendanceRecordsGenerated = recordsCreated;
//             });
//             _addLog('تم إنشاء $recordsCreated سجل حضور');
//           }
//         }
//       }
//     }
    
//     setState(() {
//       attendanceRecordsGenerated = recordsCreated;
//     });
//     _addLog('تم إنشاء $recordsCreated سجل حضور بنجاح');
//   }

//   Future<void> _createAttendanceRecord(Student student, List<Subject> subjects, DateTime date, Random random) async {
//     final attendance = Attendance()
//       ..date = date
//       ..checkInTime = DateTime(
//         date.year,
//         date.month,
//         date.day,
//         7 + random.nextInt(3), // بين 7-10 صباحاً
//         random.nextInt(60),
//       )
//       ..status = _getRandomAttendanceStatus(random)
//       ..type = random.nextBool() ? AttendanceType.daily : AttendanceType.subject
//       ..notes = random.nextBool() ? null : ['تأخر بسبب المواصلات', 'عذر طبي', 'ظرف عائلي'][random.nextInt(3)];

//     attendance.student.value = student;
    
//     // ربط بمادة عشوائية أحياناً
//     if (attendance.type == AttendanceType.subject && subjects.isNotEmpty) {
//       final availableSubjects = subjects.where((s) => 
//         s.schoolClass.value?.id == student.schoolclass.value?.id
//       ).toList();
      
//       if (availableSubjects.isNotEmpty) {
//         attendance.subject.value = availableSubjects[random.nextInt(availableSubjects.length)];
//       }
//     }

//     await isar.writeTxn(() async {
//       await isar.attendances.put(attendance);
//       await attendance.student.save();
//       if (attendance.subject.value != null) {
//         await attendance.subject.save();
//       }
//     });
//   }

//   AttendanceStatus _getRandomAttendanceStatus(Random random) {
//     final statuses = [
//       AttendanceStatus.present,
//       AttendanceStatus.present,
//       AttendanceStatus.present,
//       AttendanceStatus.present, // 60% حاضر
//       AttendanceStatus.late,
//       AttendanceStatus.late, // 20% متأخر
//       AttendanceStatus.absent,
//       AttendanceStatus.absent, // 15% غائب
//       AttendanceStatus.excused, // 5% معذور
//     ];
    
//     return statuses[random.nextInt(statuses.length)];
//   }

//   Future<void> _generateAttendanceData() async {
//     setState(() {
//       isGenerating = true;
//     });

//     try {
//       await _generateAttendanceForAllStudents();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم إنشاء سجلات حضور إضافية بنجاح!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       _addLog('خطأ في إنشاء سجلات الحضور: $e');
//     }

//     setState(() {
//       isGenerating = false;
//     });
//   }

//   Future<void> _clearAllData() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: const Text('هل أنت متأكد من حذف جميع البيانات التجريبية؟\nهذا الإجراء لا يمكن التراجع عنه.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await isar.writeTxn(() async {
//           await isar.students.clear();
//           await isar.attendances.clear();
//           await isar.studentFeeStatus.clear();
//         });

//         _addLog('تم حذف جميع البيانات التجريبية');
//         setState(() {
//           studentsGenerated = 0;
//           attendanceRecordsGenerated = 0;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم حذف جميع البيانات التجريبية'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         _addLog('خطأ في حذف البيانات: $e');
//       }
//     }
//   }

//   Future<void> _showStatistics() async {
//     try {
//       final studentsCount = await isar.students.count();
//       final attendanceCount = await isar.attendances.count();
//       final classesCount = await isar.schoolClass.count();
//       final subjectsCount = await isar.subjects.count();
      
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('إحصائيات النظام'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('عدد الطلاب: $studentsCount'),
//               Text('عدد سجلات الحضور: $attendanceCount'),
//               Text('عدد الصفوف: $classesCount'),
//               Text('عدد المواد: $subjectsCount'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('موافق'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       _addLog('خطأ في جلب الإحصائيات: $e');
//     }
//   }
// }
