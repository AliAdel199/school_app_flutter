import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Map<String, dynamic>? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final studentIdController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final registrationYearController = TextEditingController();

  String gender = 'male';
  String status = 'active';
  
  DateTime? birthDate;
  String? selectedClassId;

  bool isLoading = false;
  List<Map<String, dynamic>> classOptions = [];

Future<void> fetchClasses() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('school_id')
        .eq('id', user!.id)
        .single();

    final schoolId = profile['school_id'];

    final response = await Supabase.instance.client
        .from('classes')
        .select('id, name')
        .eq('school_id', schoolId)
        .order('name');

    setState(() {
      classOptions = List<Map<String, dynamic>>.from(response);
    });
  } catch (e) {
    debugPrint('Error fetching classes: $e');
  }
}


  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      final s = widget.student!;
      fullNameController.text = s['full_name'] ?? '';
      nationalIdController.text = s['national_id'] ?? '';
      studentIdController.text = s['student_id'] ?? '';
      parentNameController.text = s['parent_name'] ?? '';
      parentPhoneController.text = s['parent_phone'] ?? '';
      addressController.text = s['address'] ?? '';
      emailController.text = s['email'] ?? '';
      phoneController.text = s['phone'] ?? '';
      registrationYearController.text = s['registration_year'] ?? '';
      gender = s['gender'] ?? 'male';
      status = s['status'] ?? 'active';
      selectedClassId = s['class_id'];
      if (s['birth_date'] != null) {
        birthDate = DateTime.tryParse(s['birth_date']);
      }
    }
  }

  Future<void> saveStudent() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final user = supabase.auth.currentUser;
    final profile = await supabase.from('profiles').select('school_id').eq('id', user!.id).single();

    final studentData = {
      'school_id': profile['school_id'],
      'full_name': fullNameController.text.trim(),
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'national_id': nationalIdController.text.trim(),
      'student_id': studentIdController.text.trim(),
      'class_id': selectedClassId,
      'parent_name': parentNameController.text.trim(),
      'parent_phone': parentPhoneController.text.trim(),
      'address': addressController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'status': status,
      'registration_year': registrationYearController.text.trim(),
    };

    try {
      if (widget.student == null) {
        await supabase.from('students').insert(studentData);
      } else {
        await supabase.from('students').update(studentData).eq('id', widget.student!['id']);
      }
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nationalIdController.dispose();
    studentIdController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    registrationYearController.dispose();
    super.dispose();
  }

  Widget buildInputField(Widget field) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: field,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student == null ? 'إضافة طالب' : 'تعديل طالب')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final field in [
                          buildInputField(TextFormField(
                            controller: fullNameController,
                            decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                            validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                          )),
                          buildInputField(TextFormField(
                            controller: studentIdController,
                            decoration: const InputDecoration(labelText: 'رقم الطالب'),
                          )),
                          
                          buildInputField(TextFormField(
                            controller: nationalIdController,
                            decoration: const InputDecoration(labelText: 'الرقم الوطني'),
                          )),
                          buildInputField(TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(labelText: 'هاتف الطالب'),
                          )),
                          buildInputField(TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                          )),
                          buildInputField(TextFormField(
                            controller: parentNameController,
                            decoration: const InputDecoration(labelText: 'اسم ولي الأمر'),
                          )),
                          buildInputField(TextFormField(
                            controller: parentPhoneController,
                            decoration: const InputDecoration(labelText: 'هاتف ولي الأمر'),
                          )),
                          buildInputField(TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(labelText: 'العنوان'),
                          )),
                          buildInputField(TextFormField(
                            controller: registrationYearController,
                            decoration: const InputDecoration(labelText: 'سنة التسجيل'),
                          )),
                          buildInputField(DropdownButtonFormField<String>(
                            value: gender,
                            decoration: const InputDecoration(labelText: 'الجنس'),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('ذكر')),
                              DropdownMenuItem(value: 'female', child: Text('أنثى')),
                            ],
                            onChanged: (val) => setState(() => gender = val!),
                          )),
                                  buildInputField(DropdownButtonFormField<String>(
                            value: status,
                            decoration: const InputDecoration(labelText: 'الحالة'),
                            items: classOptions
                                .map((c) => DropdownMenuItem<String>(
                                      value: c['id'].toString(),
                                      child: Text(c['name'] ?? ''),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => selectedClassId = val),
                          )),
                          buildInputField(DropdownButtonFormField<String>(
                            value: status,
                            decoration: const InputDecoration(labelText: 'الحالة'),
                            items: const [
                              DropdownMenuItem(value: 'active', child: Text('فعال')),
                              DropdownMenuItem(value: 'inactive', child: Text('غير فعال')),
                              DropdownMenuItem(value: 'graduated', child: Text('متخرج')),
                              DropdownMenuItem(value: 'transferred', child: Text('منقول')),
                            ],
                            onChanged: (val) => setState(() => status = val!),
                          )),
                          buildInputField(Row(
                            children: [
                              const Icon(Icons.date_range),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(birthDate == null
                                    ? 'اختر تاريخ الميلاد'
                                    : DateFormat('yyyy-MM-dd').format(birthDate!)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2010),
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => birthDate = picked);
                                  }
                                },
                                child: const Text('اختيار تاريخ'),
                              ),
                            ],
                          )),
                        ])
                          SizedBox(
                            width: isWide ? constraints.maxWidth * 0.45 : double.infinity,
                            child: field,
                          ),
                        const SizedBox(height: 20),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: saveStudent,
                                  icon: const Icon(Icons.save),
                                  label: const Text('حفظ الطالب'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
