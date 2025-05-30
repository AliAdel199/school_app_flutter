import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectsListScreen extends StatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> grades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
    fetchGrades();
  }

  Future<void> fetchSubjects() async {
    setState(() => isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      final profile = await supabase
          .from('profiles')
          .select('school_id')
          .eq('id', user!.id)
          .single();

      final schoolId = profile['school_id'];

      final response = await supabase
          .from('subjects')
          .select('id, name, description')
          .eq('school_id', schoolId)
          .order('name');

      setState(() {
        subjects = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل المواد الدراسية: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchGrades() async {
    try {
      final user = supabase.auth.currentUser;
      final profile = await supabase
          .from('profiles')
          .select('school_id')
          .eq('id', user!.id)
          .single();

      final schoolId = profile['school_id'];

      final response = await supabase
          .from('grades')
          .select('id, name')
          .eq('school_id', schoolId)
          .order('name');

      setState(() {
        grades = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching grades: $e');
    }
  }

  Future<void> showAddSubjectDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String? selectedGradeId;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مادة دراسية'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم المادة'),
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'المرحلة الدراسية'),
                  items: grades
                      .map((grade) => DropdownMenuItem<String>(
                            value: grade['id'].toString(),
                            child: Text(grade['name'].toString()),
                          ))
                      .toList(),
                  onChanged: (val) => selectedGradeId = val,
                  validator: (val) => val == null ? 'يرجى اختيار المرحلة' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
                  maxLines: 2,
                ),
              ],
            ),
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
              final user = supabase.auth.currentUser;
              final profile = await supabase
                  .from('profiles')
                  .select('school_id')
                  .eq('id', user!.id)
                  .single();
              final schoolId = profile['school_id'];

              await supabase.from('subjects').insert({
                'name': nameController.text.trim(),
                'description': descController.text.trim(),
                'grade_id': selectedGradeId,
                'school_id': schoolId,
              });

              Navigator.pop(context);
              fetchSubjects();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المواد الدراسية')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: subjects.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(subject['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subject['description'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // تعديل لاحقًا
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddSubjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
