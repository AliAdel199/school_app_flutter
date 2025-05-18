import 'package:flutter/material.dart';
import 'package:school_app_flutter/screens/add_student_screen_supabase.dart';
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

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final profile = await supabase
          .from('profiles')
          .select('school_id')
          .eq('id', supabase.auth.currentUser!.id)
          .single();

      final schoolId = profile['school_id'];

      final res = await supabase
          .from('students')
          .select()
          .eq('school_id', schoolId)
          .order('full_name', ascending: true);

      students = List<Map<String, dynamic>>.from(res);
      filterStudents();
    } catch (e) {
      debugPrint('خطأ في جلب الطلاب: \n\n$e');
  if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('فشل تحميل الطلاب: \n\n$e')),
  );
}

    } finally {
if(mounted){
        setState(() => isLoading = false);
}
    }
  }

  void filterStudents() {
    setState(() {
      filteredStudents = students
          .where((student) =>
              student['full_name']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    });
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
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
      ),
      body: isLoading
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
            ),
    );
  }

  List<Widget> _buildStudentInfo(Map<String, dynamic> student) {
    return [
      Text(student['full_name'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text('ID: ${student['student_id'] ?? '-'}'),
      Text('الصف: ${student['class_name'] ?? '-'}'),
      Text('الهوية: ${student['national_id'] ?? '-'}'),
      Chip(
        label: Text(student['status']),
        backgroundColor: getStatusColor(student['status']).withOpacity(0.2),
        labelStyle: TextStyle(color: getStatusColor(student['status'])),
      ),
    ];
  }
}
