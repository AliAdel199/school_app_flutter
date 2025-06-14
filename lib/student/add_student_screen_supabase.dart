import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/datamangermodel.dart';
import 'package:school_app_flutter/localdatabase/StudentService.dart';
import 'package:school_app_flutter/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../localdatabase/student.dart';

// شاشة إضافة أو تعديل طالب
class AddEditStudentScreen extends StatefulWidget {
  Student? student;

  // إذا تم تمرير student، سيتم تعديل بياناته، وإلا سيتم إضافة طالب جديد
   AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  // متحكمات الحقول النصية
  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final annualFeeController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final registrationYearController = TextEditingController();

  // متغيرات الحالة
  String gender = 'male';
  String status = 'active';
  
  DateTime? birthDate;
  String? selectedClassId;

  bool isLoading = false;
  List<Map<String, dynamic>> classOptions = [];
  List<Map<String, dynamic>> classes = [];
  double annualFee = 0;
  
  // جلب قائمة الصفوف من قاعدة البيانات
  Future<void> fetchClasses() async {
    final result = await supabase.from('classes').select('id, name, annual_fee').order('name');
    setState(() {
      classes = List<Map<String, dynamic>>.from(result);
    });
  }

  // جلب القسط السنوي للصف المحدد
  double getAnnualFeeForSelectedClass() {
    final selectedClass = classes.firstWhere(
      (c) => c['id'] == selectedClassId,
      orElse: () => {},
    );
    return (selectedClass['annual_fee'] ?? 0).toDouble();
  }

  // دالة تهيئة الحالة عند فتح الشاشة
  @override
  void initState() {
    super.initState();
    fetchClasses();
    fetchGrades();
    // إذا كان هناك طالب موجود، قم بملء الحقول  
    if (widget.student != null) {
      final s = widget.student!;
      fullNameController.text = s.fullName ?? '';
      nationalIdController.text = s.nationalId ?? '';
      // annualFeeController.text = s.studentId ?? '';
      parentNameController.text = s.parentName ?? '';
      parentPhoneController.text = s.parentPhone ?? '';
      addressController.text = s.address ?? '';
      emailController.text = s.email ?? '';
      phoneController.text = s.phone ?? '';
      registrationYearController.text = s.registrationYear ?? '';
      gender = s.gender ?? 'male';
      status = s.status ?? 'active';
      selectedClassId = s.classId;
      if (s.birthDate != null) {
        birthDate = DateTime.tryParse(s.birthDate!);
      }
    }
  }

  // إنشاء سجل حالة القسط إذا لم يكن موجودًا
  Future<String?> createFeeStatusIfNotExists({
    required String studentId,
    required String academicYear,
  }) async {
    final supabase = Supabase.instance.client;

    // تحقق إذا كان هناك سجل مسبق
    final existing = await supabase
        .from('student_fee_status')
        .select('id')
        .eq('student_id', studentId)
        .eq('academic_year', academicYear)
        .maybeSingle();

    if (existing != null) return existing['id']?.toString(); // موجود مسبقًا

    // جلب الصف الخاص بالطالب
    final student = await supabase
        .from('students')
        .select('class_id')
        .eq('id', studentId)
        .maybeSingle();

    final classId = student?['class_id'];

    if (classId == null) throw Exception('الطالب غير مرتبط بصف.');

    // جلب القسط السنوي للصف
    final classData = await supabase
        .from('classes')
        .select('annual_fee')
        .eq('id', classId)
        .maybeSingle();

    final fee = (classData?['annual_fee'] ?? 0) as num;

    // إدراج سجل جديد
    final insertResult = await supabase.from('student_fee_status').insert({
      'student_id': studentId,
      'academic_year': academicYear,
      'annual_fee': fee.toDouble(),
      'paid_amount': 0,
      'due_amount': fee.toDouble(),
      'next_due_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    }).select('id').single();

    return insertResult['id']?.toString();
  }

  // قائمة المراحل الدراسية
  List<Map<String, dynamic>> grades = [];
  String? selectedGradeId;

  // جلب المراحل الدراسية من قاعدة البيانات
  Future<void> fetchGrades() async {
    try {
      final result = await supabase.from('grades').select('id, name').order('name');
      setState(() {
        grades = List<Map<String, dynamic>>.from(result);
      });
    } catch (e) {
      debugPrint('خطأ في جلب المراحل الدراسية: \n$e');
    }
  }

  // حفظ بيانات الطالب في قاعدة البيانات
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
      // 'student_id': annualFeeController.text.trim(),
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
        // إضافة طالب جديد
        final insertResult = await supabase.from('students').insert(studentData).select('id').single();
        final studentId = insertResult['id'];
        print( 'Inserted student ID: $studentId');
        final feeStatusId = await createFeeStatusIfNotExists(
          studentId: studentId,
          academicYear: registrationYearController.text.trim(),
        );
        print('Created/Found fee status ID: $feeStatusId');
        
      } else {
        // تعديل بيانات طالب موجود
        await supabase.from('students').update(studentData).eq('id', widget.student!.id);
      }
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الحفظ: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // التخلص من المتحكمات عند إغلاق الشاشة
  @override
  void dispose() {
    fullNameController.dispose();
    nationalIdController.dispose();
    annualFeeController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    registrationYearController.dispose();
    super.dispose();
  }

  // عنصر واجهة مستخدم لبناء حقل إدخال داخل بطاقة
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

  // بناء واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student == null ? 'إضافة طالب' : 'تعديل طالب')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          // الحقول الرئيسية لإدخال بيانات الطالب
                          for (final field in [
                            buildInputField(TextFormField(
                              controller: parentNameController,
                              decoration: const InputDecoration(labelText: 'اسم ولي الأمر'),
                            )),
                            buildInputField(TextFormField(
                              controller: fullNameController,
                              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                              validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                            )),
                            buildInputField(TextFormField(
                              controller: nationalIdController,
                              decoration: const InputDecoration(labelText: 'الرقم الوطني'),
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
                            buildInputField(TextFormField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: 'هاتف الطالب'),
                            )),
                            buildInputField(TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                            )),
                            buildInputField(TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(labelText: 'العنوان'),
                            )),
                            buildInputField(TextFormField(
                              controller: parentPhoneController,
                              decoration: const InputDecoration(labelText: 'هاتف ولي الأمر'),
                            )),
                            buildInputField(DropdownButtonFormField<String>(
                              value: selectedClassId,
                              decoration: const InputDecoration(labelText: 'الصف'),
                              items: classes
                                  .map((c) => DropdownMenuItem<String>(
                                        value: c['id'].toString(),
                                        child: Text(c['name'] ?? ''),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() {
                                selectedClassId = val;
                                  annualFee = getAnnualFeeForSelectedClass(); 
                                // تحديث القسط السنوي عند تغيير الصف
                                  annualFeeController.text = annualFee.toString();
                              }),
                            )),
                              buildInputField(DropdownButtonFormField<String>(
                              value: selectedGradeId,
                              decoration: const InputDecoration(labelText: 'المرحلة الدراسية'),
                              items: grades
                                  .map((g) => DropdownMenuItem<String>(
                                        value: g['id'].toString(),
                                        child: Text(g['name'] ?? ''),
                                      )).toList(),
                              onChanged: (val) => setState(() {
                                selectedGradeId = val;
                          
                                
                                print('Selected class ID: $selectedClassId, Annual Fee: $annualFee'); 
                              }),
                            )),
                            buildInputField(TextFormField(
                              controller: registrationYearController,
                              decoration: const InputDecoration(labelText: 'سنة التسجيل'),
                            )),
                            buildInputField(TextFormField(
                              controller: annualFeeController,
                              decoration: const InputDecoration(labelText: 'القسط السنوي '),
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
                          // عرض الحقل بشكل متجاوب حسب حجم الشاشة
                          SizedBox(
                            width: isWide ? constraints.maxWidth * 0.45 : double.infinity,
                            child: field,
                          ),
                          const SizedBox(height: 20),
                          // زر الحفظ أو مؤشر التحميل
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                        DataController dataController = DataController();
final storage = StudentService(isar);
if (!formKey.currentState!.validate()) return;
if(widget.student == null) {
  // إضافة طالب جديد    
  storage.addStudent(student:  Student()
..address=addressController.text.trim()
..gender=gender
..annualFee=annualFee.toInt()

..status=status
..birthDate=birthDate?.toIso8601String()
..classId=selectedClassId
..email=emailController.text.trim() 
..fullName=fullNameController.text.trim()
..nationalId=nationalIdController.text.trim()
..parentName=parentNameController.text.trim() 
..parentPhone=parentPhoneController.text.trim()
..phone=phoneController.text.trim()
..registrationYear=registrationYearController.text.trim()
..createdAt=DateTime.now(),context: context
 
);

fullNameController.clear();
nationalIdController.clear();
annualFeeController.clear();
parentNameController.clear();
parentPhoneController.clear();
addressController.clear();
emailController.clear();
phoneController.clear();
registrationYearController.clear();
setState(() {
  gender = 'male';
  status = 'active';
  birthDate = null;
  selectedClassId = null;
  selectedGradeId = null;
  annualFee = 0;
});}else {
  Student student=widget.student!;
  student
..address = addressController.text.trim()
..fullName = fullNameController.text.trim()
..gender = gender
..annualFee = annualFee.toInt()
..status = status
..birthDate = birthDate?.toIso8601String()
..classId = selectedClassId
..email = emailController.text.trim()
..nationalId = nationalIdController.text.trim()
..parentName = parentNameController.text.trim()
..parentPhone = parentPhoneController.text.trim()
..phone = phoneController.text.trim()
// استخدام ID الطالب الموجود
..registrationYear = registrationYearController.text.trim();
  // تعديل بيانات طالب موجود  


  storage.updateStudent(
    student: student,
// ..id = widget.student!['id'] // استخدام ID الطالب الموجود

  context: context,
  );
  // print( 'تم تحديث بيانات الطالب بنجاح' );
}
},
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
      ),
    );
  }
}