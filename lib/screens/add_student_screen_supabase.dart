
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final nationalIdController = TextEditingController();
  final phoneController = TextEditingController();
  final classNameController = TextEditingController();

  String gender = 'male';
  String status = 'active';
  bool isLoading = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      // جلب id المدرسة المرتبط بالمستخدم الحالي
      final profile = await supabase.from('profiles').select('school_id').eq('id', supabase.auth.currentUser!.id).single();
      final schoolId = profile['school_id'];

      await supabase.from('students').insert({
        'school_id': schoolId,
        'full_name': fullNameController.text.trim(),
        'student_id': studentIdController.text.trim(),
        'national_id': nationalIdController.text.trim(),
        'phone': phoneController.text.trim(),
        'class_name': classNameController.text.trim(), // سيتم تعديله لاحقًا لـ class_id
        'gender': gender,
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الطالب بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة الطالب: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة طالب')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildTextField('الاسم الكامل', fullNameController),
                      _buildTextField('رقم الطالب', studentIdController),
                      _buildTextField('رقم الهوية', nationalIdController),
                      _buildTextField('رقم الهاتف', phoneController),
                      _buildTextField('الصف الدراسي', classNameController),
                      _buildDropdownField('الجنس', ['male', 'female'], (val) {
                        setState(() => gender = val!);
                      }, gender),
                      _buildDropdownField('الحالة', ['active', 'inactive', 'graduated', 'transferred'], (val) {
                        setState(() => status = val!);
                      }, status),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: isLoading ? const CircularProgressIndicator() : const Text('حفظ الطالب'),
                          onPressed: isLoading ? null : submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged, String value) {
    return SizedBox(
      width: 320,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
