
import 'package:flutter/material.dart';
import 'package:school_app_flutter/screens/edit_class_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'addclassscreen.dart';

class ClassesListScreen extends StatefulWidget {
  const ClassesListScreen({super.key});

  @override
  State<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends State<ClassesListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }



  Future<void> fetchClasses() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('classes')
          .select('id, name, grade_id,annual_fee, grades(id,name), students(count)')
          .order('name', ascending: true);

      classes = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('خطأ في جلب الصفوف: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل الصفوف: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفوف الدراسية'),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16),
        //     child: ElevatedButton.icon(
        //       onPressed: () {
        //         // إضافة شاشة جديدة
        //       },
        //       icon: const Icon(Icons.add),
        //       label: const Text('إضافة صف'),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.teal,
        //         foregroundColor: Colors.white,
        //       ),
        //     ),
        //   ),
        // ],
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
                    final studentCount = classItem['students'] != null
                        ? classItem['students'][0]['count'] ?? 0
                        : 0;
                        final annualFee = classItem['annual_fee'];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(classItem['name'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'المرحلة: ${classItem['grades']['name'] ?? '-'}',
                               style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(width: 25),
                            Text('عدد الطلاب: $studentCount', style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                               const SizedBox(width: 25),
                            Text('عدد الطلاب: $annualFee', style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                   Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditClassScreen( classData: {
                      'name': classItem['name'],
                      'annual_fee': classItem['annual_fee'],
                      'grade_id': classItem['grades']['id'],
                      'gradeName': classItem['grades']['name'],
                      'studentCount': studentCount,
                    }
              
                    ),
                  ),
                );
                                // تعديل الصف
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDeleteClassDialog(
                                  context,
                                  classItem,
                                  fetchClasses, // إعادة تحميل الصفوف بعد الحذف
                                );
                                // حذف الصف
                              },
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
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddClassScreen(),
                  ),
                );
                // إضافة صف جديد
              },
              child: const Icon(Icons.add),
            ),
    );
  }
  
Future<void> showDeleteClassDialog(BuildContext context, Map<String, dynamic> classData, VoidCallback onDeleted) async {
  final supabase = Supabase.instance.client;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل أنت متأكد من حذف الصف: ${classData['name']}؟'),
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
            try {
              await supabase
                  .from('classes')
                  .delete()
                  .eq('id', classData['id']);

              Navigator.pop(context); // إغلاق الحوار
              onDeleted(); // إعادة تحميل القائمة
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الصف بنجاح')),
              );
            } catch (e) {
              debugPrint('Delete error: \n$e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فشل في حذف الصف: \n$e')),
              );
            }
          },
        ),
      ],
    ),
  );
}

}
