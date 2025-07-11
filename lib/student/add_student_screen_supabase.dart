import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '/localdatabase/student_crud.dart';
import '/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../localdatabase/class.dart';
import '../localdatabase/grade.dart';
import '../localdatabase/student.dart';

// شاشة إضافة أو تعديل طالب
// ignore: must_be_immutable
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
  final parentNameFocus = FocusNode();
  final fullNameFocus = FocusNode();
  final nationalIdFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();
  final addressFocus = FocusNode();
  final parentPhoneFocus = FocusNode();
  final registrationYearFocus = FocusNode();
  final annualFeeFocus = FocusNode();

  // متغيرات الحالة
  String gender = 'male';
  String status = 'active';

  DateTime? birthDate;
  String? selectedClassId;

  bool isLoading = false;
  List<Map<String, dynamic>> classOptions = [];
  List<Map<String, dynamic>> classes = [];
  double annualFee = 0;

  // دالة لتحديث بيانات الطالب في Isar بنفس ترتيب الحقول
  Future<void> updateStudentDataIsar(Student student) async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      await isar.writeTxn(() async {
        student
          ..fullName = fullNameController.text.trim()
          ..gender = gender
          ..birthDate = birthDate
          ..nationalId = nationalIdController.text.trim()
          ..parentName = parentNameController.text.trim()
          ..parentPhone = parentPhoneController.text.trim()
          ..address = addressController.text.trim()
          ..email = emailController.text.trim()
          ..phone = phoneController.text.trim()
          ..status = status
          ..registrationYear = registrationYearController.text.trim()
          ..annualFee = double.tryParse(annualFeeController.text.trim()) ?? 0;

        // تحديث الصف المرتبط إذا تغير
        if (selectedClassId != null) {
          final classId = int.tryParse(selectedClassId!);
          if (classId != null) {
            final schoolClass = await isar.schoolClass.get(classId);
            if (schoolClass != null) {
              student.schoolclass.value = schoolClass;
            }
          }
        }

        await isar.students.put(student);
        await student.schoolclass.save();
      });
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error updating student in Isar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء تحديث بيانات الطالب: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
    loadAcademicYear();
    fetchClasses();
    fetchGradesIsar();
    registrationYearController.text = academicYear;
    // إذا كان هناك طالب موجود، قم بملء الحقول  
    if (widget.student != null) {
      final s = widget.student!;
      fullNameController.text = s.fullName;
      nationalIdController.text = s.nationalId ?? '';
      parentNameController.text = s.parentName ?? '';
      parentPhoneController.text = s.parentPhone ?? '';
      addressController.text = s.address ?? '';
      emailController.text = s.email ?? '';
      phoneController.text = s.phone ?? '';
      registrationYearController.text = s.registrationYear ?? '';
      gender = s.gender ?? 'male';
      status = s.status;
      // ربط الصف المختار
      if (s.schoolclass.value != null) {
        selectedClassId = s.schoolclass.value!.id.toString();
        annualFee = s.schoolclass.value!.annualFee ?? 0;
        annualFeeController.text = annualFee.toString();
      } else {
        annualFeeController.text = (s.annualFee ?? 0).toString();
      }
      // ربط المرحلة الدراسية إذا كانت موجودة
      if (s.schoolclass.value?.grade.value != null) {
        selectedGradeId = s.schoolclass.value!.grade.value!.id.toString();
      }
      birthDate = s.birthDate;
    }
  }

  List<SchoolClass> schoolClassesIsar = [];

  Future<void> fetchClasses() async {
    try {
      final result = await isar.schoolClass.where().sortByName().findAll();

      setState(() {
        schoolClassesIsar = result;
      });
    } catch (e) {
      debugPrint('خطأ في جلب الصفوف من Isar:\n$e');
    }
  }

  double getAnnualFeeForSelectedClassIsar() {
    final selectedClass = schoolClassesIsar.firstWhere(
      (c) => c.id.toString() == selectedClassId,
      orElse: () => SchoolClass()..annualFee = 0,
    );
    return selectedClass.annualFee ?? 0.0;
  }

  // قائمة المراحل الدراسية
  List<Map<String, dynamic>> grades = [];

  List<Grade> gradesIsar = [];
  Grade? selectedGrade;
  String? selectedGradeId;

  Future<void> fetchGradesIsar() async {
    try {
      final result = await isar.grades.where().sortByName().findAll();

      setState(() {
        gradesIsar = result;
      });
    } catch (e) {
      debugPrint('خطأ في جلب المراحل الدراسية من Isar:\n$e');
    }
  }

  SchoolClass? selectedClass;

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
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: field,
      ),
    );
  }

  // تحسين تجربة المستخدم: إظهار رسالة خطأ عند عدم اختيار صف أو مرحلة، وتوضيح الحقول المطلوبة
  String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  // التحقق من صحة الاسم الكامل
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم الكامل مطلوب';
    }
    final parts = value.trim().split(' ');
    if (parts.length < 2) {
      return 'يرجى إدخال الاسم الثلاثي على الأقل';
    }
    return null;
  }

  // التحقق من صحة الرقم الوطني
  String? _validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم الوطني مطلوب';
    }
    // تحقق من أن الرقم يحتوي على أرقام فقط وطوله مناسب
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
    }
    if (value.trim().length < 10) {
      return 'الرقم الوطني يجب أن يكون 10 أرقام على الأقل';
    }
    return null;
  }

  // التحقق من صحة رقم الهاتف
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    // تحقق من صيغة رقم الهاتف
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value.trim())) {
      return 'صيغة رقم الهاتف غير صحيحة';
    }
    return null;
  }

  // التحقق من صحة البريد الإلكتروني
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // البريد الإلكتروني اختياري
    }
    // تحقق من صيغة البريد الإلكتروني
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  // ملء اسم ولي الأمر تلقائياً من اسم الطالب
  void _autoFillParentName() {
    List<String> parts = fullNameController.text.trim().split(" ");
    if (parts.length >= 2) {
      parentNameController.text = parts.sublist(1).join(" ");
    } else {
      parentNameController.text = '';
    }
    FocusScope.of(context).requestFocus(parentNameFocus);
  }

  // بناء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  // دالة موحدة لحفظ الطالب
  Future<void> _saveStudent() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة جميع الحقول المطلوبة بشكل صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.student == null) {
        // إضافة طالب جديد
        await addStudent(
          isar,
          Student()
            ..fullName = fullNameController.text.trim()
            ..nationalId = nationalIdController.text.trim()
            ..gender = gender
            ..birthDate = birthDate
            ..parentName = parentNameController.text.trim()
            ..parentPhone = parentPhoneController.text.trim()
            ..phone = phoneController.text.trim()
            ..email = emailController.text.trim()
            ..address = addressController.text.trim()
            ..registrationYear = registrationYearController.text.trim()
            ..annualFee = double.tryParse(annualFeeController.text.trim()) ?? 0
            ..status = status
            ..schoolclass.value = selectedClass
            ..createdAt = DateTime.now(),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الطالب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // إرجاع true للإشارة إلى نجاح العملية
        }
      } else {
        // تحديث بيانات طالب موجود
        await updateStudentDataIsar(widget.student!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث بيانات الطالب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Form(
                key: formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // قسم البيانات الشخصية
                            _buildSectionTitle('البيانات الشخصية'),
                            
                            buildInputField(TextFormField(
                              controller: fullNameController,
                              focusNode: fullNameFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => _autoFillParentName(),
                              decoration: const InputDecoration(
                                labelText: 'الاسم الكامل *',
                                prefixIcon: Icon(Icons.person),
                                hintText: 'أدخل الاسم الثلاثي أو الرباعي',
                              ),
                              validator: _validateFullName,
                            )),

                            buildInputField(TextFormField(
                              controller: nationalIdController,
                              focusNode: nationalIdFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(phoneFocus),
                              decoration: const InputDecoration(
                                labelText: 'الرقم الوطني *',
                                prefixIcon: Icon(Icons.badge),
                                hintText: 'أدخل 10-12 رقم',
                              ),
                              validator: _validateNationalId,
                            )),

                            buildInputField(DropdownButtonFormField<String>(
                              value: gender,
                              decoration: const InputDecoration(
                                labelText: 'الجنس *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('ذكر')),
                                DropdownMenuItem(value: 'female', child: Text('أنثى')),
                              ],
                              onChanged: (val) => setState(() => gender = val!),
                            )),

                            Card(
                              elevation: 2,
                              margin: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range, color: Colors.teal),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        birthDate == null
                                            ? 'اختر تاريخ الميلاد'
                                            : DateFormat('dd/MM/yyyy').format(birthDate!),
                                        style: TextStyle(
                                          color: birthDate == null ? Colors.grey.shade600 : Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 200,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: birthDate ?? DateTime(2010),
                                            firstDate: DateTime(1990),
                                            lastDate: DateTime.now(),
                                            helpText: 'اختر تاريخ الميلاد',
                                            cancelText: 'إلغاء',
                                            confirmText: 'موافق',
                                          );
                                          if (picked != null) {
                                            setState(() => birthDate = picked);
                                          }
                                        },
                                        icon: const Icon(Icons.calendar_today, size: 16),
                                        label: const Text('اختيار'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal.shade100,
                                          foregroundColor: Colors.teal.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // البيانات الأكاديمية
                            _buildSectionTitle('البيانات الأكاديمية'),
                            
                            buildInputField(
                              DropdownButtonFormField<String>(
                                value: selectedGradeId,
                                decoration: const InputDecoration(
                                  labelText: 'المرحلة الدراسية *',
                                  prefixIcon: Icon(Icons.school),
                                  border: OutlineInputBorder(),
                                ),
                                items: gradesIsar
                                    .map((g) => DropdownMenuItem<String>(
                                          value: g.id.toString(),
                                          child: Text(g.name),
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() {
                                  selectedGradeId = val;
                                }),
                                validator: requiredValidator,
                                hint: const Text('اختر المرحلة'),
                              ),
                            ),

                            buildInputField(
                              DropdownButtonFormField<String>(
                                value: selectedClassId,
                                decoration: const InputDecoration(
                                  labelText: 'الصف *',
                                  prefixIcon: Icon(Icons.class_),
                                  border: OutlineInputBorder(),
                                ),
                                items: schoolClassesIsar.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c.id.toString(),
                                    child: Text(c.name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedClassId = val;
                                    selectedClass = schoolClassesIsar.firstWhere((c) => c.id.toString() == val);
                                    annualFee = getAnnualFeeForSelectedClassIsar();
                                    annualFeeController.text = annualFee.toString();
                                  });
                                },
                                validator: requiredValidator,
                                hint: const Text('اختر الصف'),
                              ),
                            ),

                            buildInputField(TextFormField(
                              controller: registrationYearController,
                              focusNode: registrationYearFocus,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'سنة التسجيل *',
                                prefixIcon: Icon(Icons.date_range),
                                hintText: 'مثال: 2024-2025',
                              ),
                              validator: requiredValidator,
                            )),

                            buildInputField(TextFormField(
                              controller: annualFeeController,
                              focusNode: annualFeeFocus,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: 'القسط السنوي',
                                prefixIcon: const Icon(Icons.money),
                                suffixText: 'د.ع',
                                fillColor: Colors.grey.shade100,
                                filled: true,
                              ),
                              validator: requiredValidator,
                              readOnly: true,
                            )),

                            buildInputField(DropdownButtonFormField<String>(
                              value: status,
                              decoration: const InputDecoration(
                                labelText: 'حالة الطالب',
                                prefixIcon: Icon(Icons.info),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('نشط')),
                                DropdownMenuItem(value: 'inactive', child: Text('غير نشط')),
                                DropdownMenuItem(value: 'graduated', child: Text('متخرج')),
                                DropdownMenuItem(value: 'transferred', child: Text('منقول')),
                                DropdownMenuItem(value: 'withdrawn', child: Text('منسحب')),
                                DropdownMenuItem(value: 'dropout', child: Text('تارك')),
                              ],
                              onChanged: (val) => setState(() => status = val!),
                            )),

                            const SizedBox(height: 20),

                            // بيانات التواصل وولي الأمر
                            _buildSectionTitle('بيانات التواصل وولي الأمر'),
                            
                            buildInputField(TextFormField(
                              controller: parentNameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم ولي الأمر *',
                                prefixIcon: Icon(Icons.family_restroom),
                                hintText: 'سيتم ملؤه تلقائياً من اسم الطالب',
                              ),
                              textInputAction: TextInputAction.next,
                              focusNode: parentNameFocus,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(parentPhoneFocus),
                              validator: requiredValidator,
                            )),

                            buildInputField(TextFormField(
                              controller: parentPhoneController,
                              focusNode: parentPhoneFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(phoneFocus),
                              decoration: const InputDecoration(
                                labelText: 'هاتف ولي الأمر *',
                                prefixIcon: Icon(Icons.phone),
                                hintText: 'رقم هاتف ولي الأمر',
                              ),
                              validator: _validatePhoneNumber,
                            )),

                            buildInputField(TextFormField(
                              controller: phoneController,
                              focusNode: phoneFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(emailFocus),
                              decoration: const InputDecoration(
                                labelText: 'هاتف الطالب',
                                prefixIcon: Icon(Icons.smartphone),
                                hintText: 'رقم هاتف الطالب (اختياري)',
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return _validatePhoneNumber(value);
                                }
                                return null;
                              },
                            )),

                            buildInputField(TextFormField(
                              controller: emailController,
                              focusNode: emailFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(addressFocus),
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                prefixIcon: Icon(Icons.email),
                                hintText: 'البريد الإلكتروني (اختياري)',
                              ),
                              validator: _validateEmail,
                            )),

                            buildInputField(TextFormField(
                              controller: addressController,
                              focusNode: addressFocus,
                              textInputAction: TextInputAction.done,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'العنوان',
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'عنوان السكن',
                              ),
                            )),

                            const SizedBox(height: 30),

                            // زر الحفظ أو مؤشر التحميل
                            isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ElevatedButton.icon(
                                      onPressed: _saveStudent,
                                      icon: const Icon(Icons.save),
                                      label: Text(widget.student == null ? 'حفظ الطالب' : 'تحديث بيانات الطالب'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
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
