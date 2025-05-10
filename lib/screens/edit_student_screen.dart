
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditStudentScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  const EditStudentScreen({super.key, required this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final nationalIdController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String gender = 'male';
  String status = 'active';
  String? selectedClassId;
  DateTime? birthDate;
  List<Map<String, dynamic>> classes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    fetchClasses();
  }

  void _loadStudentData() {
    final s = widget.student;
    fullNameController.text = s['full_name'] ?? '';
    studentIdController.text = s['student_id'] ?? '';
    nationalIdController.text = s['national_id'] ?? '';
    parentNameController.text = s['parent_name'] ?? '';
    parentPhoneController.text = s['parent_phone'] ?? '';
    addressController.text = s['address'] ?? '';
    emailController.text = s['email'] ?? '';
    phoneController.text = s['phone'] ?? '';
    gender = s['gender'] ?? 'male';
    status = s['status'] ?? 'active';
    selectedClassId = s['class_id'];
    if (s['birth_date'] != null) {
      birthDate = DateTime.tryParse(s['birth_date']);
    }
  }

  Future<void> fetchClasses() async {
    final result = await supabase.from('classes').select('id, name');
    setState(() {
      classes = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (birthDate == null || selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الصف وتاريخ الميلاد')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await supabase.from('students').update({
        'full_name': fullNameController.text.trim(),
        'student_id': studentIdController.text.trim(),
        'national_id': nationalIdController.text.trim(),
        'parent_name': parentNameController.text.trim(),
        'parent_phone': parentPhoneController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'class_id': selectedClassId,
        'gender': gender,
        'status': status,
        'birth_date': birthDate!.toIso8601String(),
      }).eq('id', widget.student['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات الطالب')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في التحديث: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل بيانات الطالب')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 950),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        children: [
                          _buildTextField('الاسم الكامل', fullNameController),
                          _buildTextField('رقم الطالب', studentIdController),
                          _buildTextField('رقم الهوية', nationalIdController),
                          _buildDatePicker(context),
                          _buildDropdownField('الجنس', ['male', 'female'], gender,
                              (val) => setState(() => gender = val!)),
                          _buildDropdownField(
                            'الحالة',
                            ['active', 'inactive', 'graduated', 'transferred'],
                            status,
                            (val) => setState(() => status = val!),
                          ),
                          _buildDropdownClass(),
                          _buildTextField('اسم ولي الأمر', parentNameController),
                          _buildTextField('هاتف ولي الأمر', parentPhoneController),
                          _buildTextField('الهاتف', phoneController),
                          _buildTextField('البريد الإلكتروني', emailController),
                          _buildTextField('العنوان', addressController, maxLines: 2),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: isLoading
                              ? const CircularProgressIndicator()
                              : const Text('تحديث الطالب'),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return SizedBox(
      width: 430,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      void Function(String?) onChanged) {
    return SizedBox(
      width: 430,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) =>
                DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownClass() {
    return SizedBox(
      width: 430,
      child: DropdownButtonFormField<String>(
        value: selectedClassId,
        decoration: const InputDecoration(
            labelText: 'الصف الدراسي', border: OutlineInputBorder()),
        items: classes
            .map((c) => DropdownMenuItem<String>(
                  value: c['id'] as String,
                  child: Text(c['name'] as String),
                ))
            .toList(),
        onChanged: (val) => setState(() => selectedClassId = val),
        validator: (value) =>
            value == null ? 'يرجى اختيار الصف الدراسي' : null,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return SizedBox(
      width: 430,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: birthDate ?? DateTime(2010),
            firstDate: DateTime(1990),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => birthDate = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'تاريخ الميلاد',
            border: OutlineInputBorder(),
          ),
          child: Text(birthDate != null
              ? '${birthDate!.year}-${birthDate!.month}-${birthDate!.day}'
              : 'اختر التاريخ'),
        ),
      ),
    );
  }
}
