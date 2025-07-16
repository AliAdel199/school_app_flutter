
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final annualFeeController = TextEditingController();
  String? selectedGradeId;

  List<Map<String, dynamic>> grades = [];
  bool isLoading = false;

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    fetchGrades();
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

    final res = await supabase
        .from('grades')
        .select()
        .eq('school_id', schoolId)
        .order('name');

    setState(() {
      grades = List<Map<String, dynamic>>.from(res);
    });
  } catch (e) {
    debugPrint('خطأ في جلب المراحل: \n\n$e');
  }
}

  // Future<void> fetchGrades() async {
  //   try {
  //     final res = await supabase.from('grades').select().order('name');
  //     setState(() {
  //       grades = List<Map<String, dynamic>>.from(res);
  //     });
  //   } catch (e) {
  //     debugPrint('خطأ في جلب المراحل: \n\n$e');
  //   }
  // }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      await supabase.from('classes').insert({
        'name': nameController.text.trim(),
        'grade_id': selectedGradeId,
        'annual_fee':  double.tryParse(annualFeeController.text) ?? 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الصف بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ في الإضافة: \n\n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة الصف: \n\n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

Future<void> showAddGradeDialog() async {
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
          decoration: const InputDecoration(labelText: 'اسم المرحلة'),
          validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
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

            await supabase.from('grades').insert({
              'name': gradeController.text.trim(),
              'school_id': schoolId,
            });

            Navigator.pop(context);
            fetchGrades();
          },
          child: const Text('إضافة'),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة صف دراسي')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('تفاصيل الصف',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الصف',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'يرجى إدخال اسم الصف' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedGradeId,
                        decoration: const InputDecoration(
                          labelText: 'المرحلة الدراسية',
                          border: OutlineInputBorder(),
                        ),
                        items: grades
                            .map((grade) => DropdownMenuItem<String>(
                                  value: grade['id'] as String,
                                  child: Text(grade['name'] as String),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedGradeId = value);
                        },
                        validator: (value) =>
                            value == null ? 'يرجى اختيار المرحلة' : null,
                      ),
                      const SizedBox(height: 20),

                         TextFormField(
                        controller: annualFeeController,keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: ' القسط السنوي',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'يرجى إدخال القسط' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('حفظ'),
                        onPressed: isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
