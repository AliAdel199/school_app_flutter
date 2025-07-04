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
    // إذا كان هناك طالب موجود، قم بملء الحقول  
    if (widget.student != null) {
      final s = widget.student!;
      fullNameController.text = s.fullName ?? '';
      nationalIdController.text = s.nationalId ?? '';
      parentNameController.text = s.parentName ?? '';
      parentPhoneController.text = s.parentPhone ?? '';
      addressController.text = s.address ?? '';
      emailController.text = s.email ?? '';
      phoneController.text = s.phone ?? '';
      registrationYearController.text = s.registrationYear ?? '';
      gender = s.gender ?? 'male';
      status = s.status ?? 'active';
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
                          for (final field in <Widget>[
                            buildInputField(
                              FocusTraversalGroup(
                                child: TextFormField(
                                  controller: parentNameController,
                                  decoration: const InputDecoration(labelText: 'اسم ولي الأمر'),
                                  textInputAction: TextInputAction.next,
                                  focusNode: parentNameFocus,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(nationalIdFocus);
                                    nationalIdFocus.requestFocus();
                                  },
                                  validator: requiredValidator,
                                ),
                              ),
                            ),
                            buildInputField(TextFormField(
                              controller: fullNameController,
                              focusNode: fullNameFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(parentNameFocus);
                              },
                              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                              validator: requiredValidator,
                            )),
                            buildInputField(TextFormField(
                              controller: nationalIdController,
                              focusNode: nationalIdFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(phoneFocus);
                              },
                              decoration: const InputDecoration(labelText: 'الرقم الوطني'),
                              validator: requiredValidator,
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
                              focusNode: phoneFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(emailFocus);
                              },
                              decoration: const InputDecoration(labelText: 'هاتف الطالب'),
                              validator: requiredValidator,
                            )),
                            buildInputField(TextFormField(
                              controller: emailController,
                              focusNode: emailFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(addressFocus);
                              },
                              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                            )),
                            buildInputField(TextFormField(
                              controller: addressController,
                              focusNode: addressFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(parentPhoneFocus);
                              },
                              decoration: const InputDecoration(labelText: 'العنوان'),
                            )),
                            buildInputField(TextFormField(
                              controller: parentPhoneController,
                              focusNode: parentPhoneFocus,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(registrationYearFocus);
                              },
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(labelText: 'هاتف ولي الأمر'),
                              validator: requiredValidator,
                            )),
                            buildInputField(
                              DropdownButtonFormField<String>(
                                value: selectedClassId,
                                decoration: const InputDecoration(
                                  labelText: 'الصف',
                                  border: OutlineInputBorder(),
                                ),
                                items: schoolClassesIsar.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c.id.toString(),
                                    child: Text(c.name ?? ''),
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
                            buildInputField(
                              DropdownButtonFormField<String>(
                                value: selectedGradeId,
                                decoration: const InputDecoration(
                                  labelText: 'المرحلة الدراسية',
                                  border: OutlineInputBorder(),
                                ),
                                items: gradesIsar
                                    .map((g) => DropdownMenuItem<String>(
                                          value: g.id.toString(),
                                          child: Text(g.name ?? ''),
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() {
                                  selectedGradeId = val;
                                  print('Selected class ID: $selectedClassId, Annual Fee: $annualFee');
                                }),
                                validator: requiredValidator,
                                hint: const Text('اختر المرحلة'),
                              ),
                            ),
                            buildInputField(TextFormField(
                              controller: registrationYearController,
                              focusNode: registrationYearFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(annualFeeFocus);
                              },
                              decoration: const InputDecoration(labelText: 'سنة التسجيل'),
                              validator: requiredValidator,
                            )),
                            buildInputField(TextFormField(
                              controller: annualFeeController,
                              focusNode: annualFeeFocus,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(labelText: 'القسط السنوي '),
                              validator: requiredValidator,
                              readOnly: true, // تحسين: لا يمكن تعديله يدوياً
                            )),
                            buildInputField(DropdownButtonFormField<String>(
                              value: status,
                              decoration: const InputDecoration(labelText: 'الحالة'),
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('نشط')),
                                DropdownMenuItem(value: 'inactive', child: Text('غير نشط')),
                                DropdownMenuItem(value: 'graduated', child: Text('متخرج')),
                                DropdownMenuItem(value: 'transferred', child: Text('منقول')),
                                DropdownMenuItem(value: 'transferred', child: Text('منسب')),
                                DropdownMenuItem(value: 'transferred', child: Text('تارك')),
                              ],
                              onChanged: (val) => setState(() => status = val!),
                            )),
                            buildInputField(Row(
                              children: [
                                const Icon(Icons.date_range),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    birthDate == null
                                        ? 'اختر تاريخ الميلاد'
                                        : DateFormat('yyyy-MM-dd').format(birthDate!),
                                    style: TextStyle(
                                      color: birthDate == null ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: birthDate ?? DateTime(2010),
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
                                      if (!formKey.currentState!.validate()) {
                                        // تحسين: إظهار رسالة إذا لم يتم تعبئة الحقول المطلوبة
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')),
                                        );
                                        return;
                                      }
                                      if (widget.student == null) {
                                        // إضافة طالب جديد
                                        addStudent(
                                          isar,
                                          Student()
                                            ..fullName = fullNameController.text.trim()
                                            ..address = addressController.text.trim()
                                            ..annualFee = double.tryParse(annualFeeController.text.trim()) ?? 0
                                            ..schoolclass.value = selectedClass
                                            ..birthDate = birthDate
                                            ..createdAt = DateTime.now()
                                            ..nationalId = nationalIdController.text.trim()
                                            ..email = emailController.text.trim()
                                            ..gender = gender
                                            ..status = status
                                            ..parentName = parentNameController.text.trim()
                                            ..parentPhone = parentPhoneController.text.trim()
                                            ..phone = phoneController.text.trim()
                                            ..registrationYear = registrationYearController.text.trim(),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم حفظ بيانات الطالب بنجاح ')));
                                        Navigator.pop(context);
                                      } else {
                                        // تعديل بيانات طالب موجود
                                        await updateStudentDataIsar(widget.student!);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم حفظ بيانات الطالب بنجاح ')));
                                        Navigator.pop(context);
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
