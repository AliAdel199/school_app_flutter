// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '/localdatabase/class.dart';
import '/localdatabase/grade.dart';
import '/localdatabase/student_crud.dart';
import '../main.dart';

class ClassesListScreen extends StatefulWidget {
  const ClassesListScreen({super.key});

  @override
  State<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends State<ClassesListScreen> {
  List<SchoolClass> classes = [];
  List<Grade> grades = [];
  bool isLoading = true;
   final classNameController = TextEditingController();
                final annualFeeController = TextEditingController();
  final levelController = TextEditingController(); // <-- أضف هذا

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    fetchClasses();
    fetchGrades();
  }

  Future<void> fetchClasses() async {
    setState(() => isLoading = true);
    classes = await getAllClasses(isar);
    setState(() => isLoading = false);
  }

  Future<void> fetchGrades() async {
    grades = await getAllGrades(isar);
    setState(() {});
  }

  Future<void> showDeleteClassDialog(SchoolClass classItem) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الصف: ${classItem.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await deleteClass(isar, classItem.id);
              Navigator.pop(context);
              fetchClasses();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الصف بنجاح')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(title: const Text('الصفوف الدراسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchClasses();
              fetchGrades();
            },
          ),  
          SizedBox(width: 200,
            child: ElevatedButton(
              onPressed: () async {
                final gradeController = TextEditingController();
                final formKey = GlobalKey<FormState>();

                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('إضافة مرحلة دراسية'),
                    content: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: gradeController,
                        decoration:
                            const InputDecoration(labelText: 'اسم المرحلة'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;


                          final grade =
                              Grade()..name = gradeController.text.trim();

                          await addGrade(isar, grade);

                          Navigator.pop(context);
                          fetchGrades();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('تمت إضافة المرحلة: ${grade.name}')),
                          );
                        },
                        child: const Text('إضافة'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('إضافة مرحلة'),
            ),
          ),
          SizedBox(width: 200,
            child: ElevatedButton(onPressed: () async {
             
                int? selectedGradeId;
                await fetchGrades();
            
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('إضافة صف جديد'),
                    content: StatefulBuilder(
                      builder: (context, setState) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          TextField(
                            controller: classNameController,
                            decoration:
                                const InputDecoration(labelText: 'اسم الصف'),
                          ),
                          TextField(
                            controller: annualFeeController,
                            decoration:
                                const InputDecoration(labelText: 'القسط السنوي'),
                            keyboardType: TextInputType.number,
                          ),
                            TextField(
            controller: levelController,
            decoration: const InputDecoration(labelText: 'ترتيب الصف (رقم)'),
            keyboardType: TextInputType.number,
          ),
                          DropdownButtonFormField<int>(
                            value: selectedGradeId,
                            items: grades
                                .map((grade) => DropdownMenuItem<int>(
                                      value: grade.id,
                                      child: Text(grade.name),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() {
                              selectedGradeId = val;
                            }),
                            decoration:
                                const InputDecoration(labelText: 'المرحلة'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed:
                         () async {
                          final name = classNameController.text.trim();
                          final annualFee =
                              int.tryParse(annualFeeController.text.trim()) ?? 0;
            
                          if (name.isEmpty || selectedGradeId == null) return;
            
                          final grade =
                              await isar.grades.get(selectedGradeId!);
                          if (grade == null) return;
            
                          final schoolClass = SchoolClass()
                            ..name = name
                            ..annualFee = annualFee.toDouble()
                            ..level = int.tryParse(levelController.text.trim()) ?? 0
                            ..grade.value = grade;
            
                          await addClass(isar, schoolClass);
            
                          Navigator.pop(context);
                          fetchClasses();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تمت إضافة الصف: $name')),
                          );

                                      levelController.clear();
                          classNameController.clear();
                          annualFeeController.clear();

                  
            
            
            }, child: const Text('إضافة صف')
                     
                      ),
        
                    ],
                  ),
                );
            }, child: const Text('إضافة صف')  ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final classItem = classes[index];
                    final gradeName = classItem.grade.value?.name ?? '-';
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(classItem.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('المرحلة: $gradeName'),
                            Text('القسط السنوي: ${classItem.annualFee?.toStringAsFixed(0) ?? '0'}')
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                                onPressed: () async {
                                final classNameController = TextEditingController(text: classItem.name);
                                final annualFeeController = TextEditingController(text: classItem.annualFee?.toStringAsFixed(0) ?? '');
                                final levelController = TextEditingController(text: classItem.level.toString());
                                int? selectedGradeId = classItem.grade.value?.id;
                                await fetchGrades();

                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                  title: const Text('تعديل الصف'),
                                  content: StatefulBuilder(
                                    builder: (context, setState) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                      controller: classNameController,
                                      decoration: const InputDecoration(labelText: 'اسم الصف'),
                                      ),
                                      

                                      TextField(
                                      controller: annualFeeController,
                                      decoration: const InputDecoration(labelText: 'القسط السنوي'),
                                      keyboardType: TextInputType.number,
                                      ),
                                        TextField(
            controller: levelController,
            decoration: const InputDecoration(labelText: 'ترتيب الصف (رقم)'),
            keyboardType: TextInputType.number,
          ),
                                      DropdownButtonFormField<int>(
                                      value: selectedGradeId,
                                      items: grades
                                        .map((grade) => DropdownMenuItem<int>(
                                            value: grade.id,
                                            child: Text(grade.name),
                                          ))
                                        .toList(),
                                      onChanged: (val) => setState(() {
                                        selectedGradeId = val;
                                      }),
                                      decoration: const InputDecoration(labelText: 'المرحلة'),
                                      ),
                                    ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                    ),
                                    ElevatedButton(
                                    onPressed: () async {
                                      final name = classNameController.text.trim();
                                      final annualFee = int.tryParse(annualFeeController.text.trim()) ?? 0;
                                      final level = int.tryParse(levelController.text.trim()) ?? 0;

                                      if (name.isEmpty || selectedGradeId == null) return;

                                      final grade = await isar.grades.get(selectedGradeId!);
                                      if (grade == null) return;

                                      classItem.name = name;
                                      classItem.annualFee = annualFee.toDouble();
                                      classItem.level = level;
                                      classItem.grade.value = grade;

                                      await isar.writeTxn(() async {
                                      await isar.schoolClass.put(classItem);
                                      await classItem.grade.save();
                                      });
                                      levelController.clear();
                                       classNameController.clear();
                          annualFeeController.clear();

                                      Navigator.pop(context);
                                      fetchClasses();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('تم تعديل الصف: $name')),
                                      );
                                    },
                                    child: const Text('حفظ التعديلات'),
                                    ),
                                  ],
                                  ),
                                );
                                
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDeleteClassDialog(classItem),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

   
    );
  }
}
