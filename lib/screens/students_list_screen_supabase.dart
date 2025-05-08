
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final profile = await supabase.from('profiles').select('school_id').eq('id', supabase.auth.currentUser!.id).single();
      final schoolId = profile['school_id'];

      final res = await supabase
          .from('students')
          .select()
          .eq('school_id', schoolId)
          .order('full_name', ascending: true);

      students = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('خطأ في جلب الطلاب: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل الطلاب: \$e')),
      );
    } finally {
      setState(() => isLoading = false);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-student')
                    .then((_) => fetchStudents());
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة طالب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
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
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: isWide
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(student['full_name'],
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text('ID: ${student['student_id'] ?? '-'}'),
                                      Text('الصف: ${student['class_name'] ?? '-'}'),
                                      Text('الهوية: ${student['national_id'] ?? '-'}'),
                                      Chip(
                                        label: Text(student['status']),
                                        backgroundColor:
                                            getStatusColor(student['status'])
                                                .withOpacity(0.2),
                                        labelStyle: TextStyle(
                                            color: getStatusColor(
                                                student['status'])),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(student['full_name'],
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('ID: ${student['student_id'] ?? '-'}'),
                                      Text('الصف: ${student['class_name'] ?? '-'}'),
                                      Text('الهوية: ${student['national_id'] ?? '-'}'),
                                      const SizedBox(height: 6),
                                      Chip(
                                        label: Text(student['status']),
                                        backgroundColor:
                                            getStatusColor(student['status'])
                                                .withOpacity(0.2),
                                        labelStyle: TextStyle(
                                            color: getStatusColor(
                                                student['status'])),
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
}
