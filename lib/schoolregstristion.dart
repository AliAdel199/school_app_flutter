import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/income_category.dart';
import '/LogsScreen.dart';
import '/localdatabase/school.dart';
import '/localdatabase/user.dart';
import '/reports/login_screen.dart';
import '../main.dart';
import 'auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'license_manager.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final formKey = GlobalKey<FormState>();

  final schoolNameController = TextEditingController();
  final schoolEmailController = TextEditingController();
  final schoolPhoneController = TextEditingController();
  final schoolAddressController = TextEditingController();

  final usernameController = TextEditingController();
  final userEmailController = TextEditingController();
  final passwordController = TextEditingController();

  File? selectedLogo;
  bool isLoading = false;

  Future<void> pickLogoImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final appDir = Directory('assets/images');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      final fileName = 'school_logo${DateTime.now().millisecondsSinceEpoch}${picked.path.split('.').last.isNotEmpty ? '.' + picked.path.split('.').last : ''}';
      final newLogoPath = '${appDir.path}/$fileName';
      final newLogoFile = await File(picked.path).copy(newLogoPath);

      setState(() {
        selectedLogo = newLogoFile;
      });
    }
  }

  Future<void> saveInitialData() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final existingSchools = await isar.schools.where().findAll();
      if (existingSchools.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل المدرسة سابقًا.')),
        );
        return;
      }

      // 🧪 إنشاء ملف الفترة التجريبية
      await LicenseManager.createTrialLicenseFile();

      await isar.writeTxn(() async {
        final school = School()
          ..name = schoolNameController.text.trim()
          ..email = schoolEmailController.text.trim()
          ..phone = schoolPhoneController.text.trim()
          ..address = schoolAddressController.text.trim()
          ..logoUrl = selectedLogo?.path
          ..subscriptionPlan = 'basic'
          ..subscriptionStatus = 'trial'
          ..createdAt = DateTime.now();

        await isar.schools.put(school);
      });

      await registerUser(
        usernameController.text.trim(),
        userEmailController.text.trim(),
        passwordController.text.trim(),
      );
         final identifier = "قسط طالب".toLowerCase().replaceAll(' ', '_');

            final exists = await isar.incomeCategorys
                .filter()
                .identifierEqualTo(identifier)
                .findFirst();

            if (exists == null) {
              final category = IncomeCategory()
                ..name = "قسط طالب"
                ..identifier = identifier;

              await isar.writeTxn(() async {
                await isar.incomeCategorys.put(category);
              });
            }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد النظام لأول مرة'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('بيانات المدرسة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: schoolNameController,
                              decoration: _inputDecoration('اسم المدرسة', icon: Icons.school),
                              validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: schoolEmailController,
                              decoration: _inputDecoration('البريد الإلكتروني', icon: Icons.email),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: schoolPhoneController,
                              decoration: _inputDecoration('رقم الهاتف', icon: Icons.phone),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: schoolAddressController,
                              decoration: _inputDecoration('عنوان المدرسة', icon: Icons.location_on),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: ElevatedButton.icon(
                                    onPressed: pickLogoImage,
                                    icon: const Icon(Icons.image),
                                    label: const Text('اختيار لوجو المدرسة'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (selectedLogo != null)
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.file(selectedLogo!, fit: BoxFit.cover),
                                  )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('بيانات المستخدم الإداري', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: usernameController,
                              decoration: _inputDecoration('اسم المستخدم', icon: Icons.person),
                              validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: userEmailController,
                              decoration: _inputDecoration('البريد الإلكتروني', icon: Icons.email_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: _inputDecoration('كلمة المرور', icon: Icons.lock),
                              validator: (val) => val == null || val.length < 4 ? 'يجب أن تكون 4 أحرف على الأقل' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: saveInitialData,
                            icon: const Icon(Icons.save),
                            label: const Text('حفظ البيانات وبدء الاستخدام', style: TextStyle(fontSize: 16)),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
