import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '/localdatabase/student_crud.dart';
import '/main.dart';

import '../localdatabase/class.dart';
import '../localdatabase/grade.dart';
import '../localdatabase/student.dart';

// شاشة إضافة أو تعديل طالب محسنة
class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
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
  String? selectedGradeId;
  bool isLoading = false;

  List<SchoolClass> schoolClassesIsar = [];
  List<Grade> gradesIsar = [];
  SchoolClass? selectedClass;

  @override
  void initState() {
    super.initState();
    loadAcademicYear();
    fetchClasses();
    fetchGradesIsar();
    registrationYearController.text = academicYear;
    
    // ملء البيانات إذا كان هناك طالب موجود
    if (widget.student != null) {
      _populateFields();
    }
  }

  void _populateFields() {
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
    birthDate = s.birthDate;

    if (s.schoolclass.value != null) {
      selectedClassId = s.schoolclass.value!.id.toString();
      annualFeeController.text = (s.schoolclass.value!.annualFee ?? 0).toString();
      
      if (s.schoolclass.value?.grade.value != null) {
        selectedGradeId = s.schoolclass.value!.grade.value!.id.toString();
      }
    } else {
      annualFeeController.text = (s.annualFee ?? 0).toString();
    }
  }

  Future<void> fetchClasses() async {
    try {
      final result = await isar.schoolClass.where().sortByName().findAll();
      setState(() => schoolClassesIsar = result);
    } catch (e) {
      debugPrint('خطأ في جلب الصفوف من Isar: $e');
    }
  }

  Future<void> fetchGradesIsar() async {
    try {
      final result = await isar.grades.where().sortByName().findAll();
      setState(() => gradesIsar = result);
    } catch (e) {
      debugPrint('خطأ في جلب المراحل الدراسية من Isar: $e');
    }
  }

  double getAnnualFeeForSelectedClass() {
    if (selectedClassId == null) return 0.0;
    final selectedClass = schoolClassesIsar.firstWhere(
      (c) => c.id.toString() == selectedClassId,
      orElse: () => SchoolClass()..annualFee = 0,
    );
    return selectedClass.annualFee ?? 0.0;
  }

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

  // دوال التحقق المحسنة
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

  String? _validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم الوطني مطلوب';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
    }
    if (value.trim().length < 10) {
      return 'الرقم الوطني يجب أن يكون 10 أرقام على الأقل';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value.trim())) {
      return 'صيغة رقم الهاتف غير صحيحة';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // البريد الإلكتروني اختياري
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  void _autoFillParentName() {
    List<String> parts = fullNameController.text.trim().split(" ");
    if (parts.length >= 2) {
      parentNameController.text = parts.sublist(1).join(" ");
    } else {
      parentNameController.text = '';
    }
  }

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

  Widget buildInputField(Widget field) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: field,
      ),
    );
  }

  Widget _buildResponsiveRow(bool isWide, List<Widget> children) {
    if (isWide && children.length > 1) {
      return Row(
        children: children.map((child) => Expanded(child: child)).toList(),
      );
    } else {
      return Column(children: children);
    }
  }

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
          Navigator.pop(context, true);
        }
      } else {
        // تحديث بيانات طالب موجود
        await _updateStudentData(widget.student!);
        
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

  Future<void> _updateStudentData(Student student) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'إضافة طالب جديد' : 'تعديل بيانات الطالب'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Form(
                key: formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // قسم البيانات الشخصية
                            _buildSectionTitle('البيانات الشخصية'),
                            _buildResponsiveRow(isWide, [
                              buildInputField(TextFormField(
                                controller: fullNameController,
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
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'الرقم الوطني *',
                                  prefixIcon: Icon(Icons.badge),
                                  hintText: 'أدخل 10-12 رقم',
                                ),
                                validator: _validateNationalId,
                              )),
                            ]),

                            _buildResponsiveRow(isWide, [
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

                              buildInputField(Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
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
                                    ElevatedButton.icon(
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
                                  ],
                                ),
                              )),
                            ]),

                            const SizedBox(height: 20),

                            // البيانات الأكاديمية
                            _buildSectionTitle('البيانات الأكاديمية'),
                            _buildResponsiveRow(isWide, [
                              buildInputField(
                                DropdownButtonFormField<String>(
                                  value: selectedGradeId,
                                  decoration: const InputDecoration(
                                    labelText: 'المرحلة الدراسية *',
                                    prefixIcon: Icon(Icons.school),
                                  ),
                                  items: gradesIsar
                                      .map((g) => DropdownMenuItem<String>(
                                            value: g.id.toString(),
                                            child: Text(g.name),
                                          ))
                                      .toList(),
                                  onChanged: (val) => setState(() => selectedGradeId = val),
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
                                      final fee = getAnnualFeeForSelectedClass();
                                      annualFeeController.text = fee.toString();
                                    });
                                  },
                                  validator: requiredValidator,
                                  hint: const Text('اختر الصف'),
                                ),
                              ),
                            ]),

                            _buildResponsiveRow(isWide, [
                              buildInputField(TextFormField(
                                controller: registrationYearController,
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
                            ]),

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
                            _buildResponsiveRow(isWide, [
                              buildInputField(TextFormField(
                                controller: parentNameController,
                                decoration: const InputDecoration(
                                  labelText: 'اسم ولي الأمر *',
                                  prefixIcon: Icon(Icons.family_restroom),
                                  hintText: 'سيتم ملؤه تلقائياً من اسم الطالب',
                                ),
                                textInputAction: TextInputAction.next,
                                validator: requiredValidator,
                              )),

                              buildInputField(TextFormField(
                                controller: parentPhoneController,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'هاتف ولي الأمر *',
                                  prefixIcon: Icon(Icons.phone),
                                  hintText: 'رقم هاتف ولي الأمر',
                                ),
                                validator: _validatePhoneNumber,
                              )),
                            ]),

                            _buildResponsiveRow(isWide, [
                              buildInputField(TextFormField(
                                controller: phoneController,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
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
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  prefixIcon: Icon(Icons.email),
                                  hintText: 'البريد الإلكتروني (اختياري)',
                                ),
                                validator: _validateEmail,
                              )),
                            ]),

                            buildInputField(TextFormField(
                              controller: addressController,
                              textInputAction: TextInputAction.done,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'العنوان',
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'عنوان السكن',
                              ),
                            )),

                            const SizedBox(height: 30),

                            // زر الحفظ
                            isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : SizedBox(
                                    width: 200,
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
