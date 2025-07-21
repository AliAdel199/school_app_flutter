import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/income_category.dart';
import 'package:school_app_flutter/localdatabase/expense_category.dart';
import '/LogsScreen.dart';
import '/localdatabase/school.dart';
import '/localdatabase/user.dart';
import '/reports/login_screen.dart';
import '../main.dart';
import 'auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'license_manager.dart';
import 'services/supabase_service.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int currentStep = 0;

  // School controllers
  final schoolNameController = TextEditingController();
  final schoolEmailController = TextEditingController();
  final schoolPhoneController = TextEditingController();
  final schoolAddressController = TextEditingController();

  // User controllers
  final usernameController = TextEditingController();
  final userEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  File? selectedLogo;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> pickLogoImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final appDir = Directory('assets/images');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      final fileName = 'school_logo${DateTime.now().millisecondsSinceEpoch}${picked.path.split('.').last.isNotEmpty ? '.${picked.path.split('.').last}' : ''}';
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
        _showSnackBar('تم تسجيل المدرسة سابقًا.', Colors.orange);
        return;
      }

      // إنشاء ملف الفترة التجريبية
      await LicenseManager.createTrialLicenseFile();

      // إضافة المدرسة إلى Supabase أولاً
      Map<String, dynamic>? supabaseSchool;
      try {
        supabaseSchool = await SupabaseService.addSchoolToSupabase(
          name: schoolNameController.text.trim(),
          email: schoolEmailController.text.trim(),
          phone: schoolPhoneController.text.trim(),
          address: schoolAddressController.text.trim(),
          logoUrl: selectedLogo?.path,
        );
      } catch (e) {
        debugPrint('Failed to sync with Supabase: $e');
        // يمكن المتابعة حتى لو فشل Supabase
      }

      await isar.writeTxn(() async {
        final school = School()
          ..name = schoolNameController.text.trim()
          ..email = schoolEmailController.text.trim()
          ..phone = schoolPhoneController.text.trim()
          ..address = schoolAddressController.text.trim()
          ..logoUrl = selectedLogo?.path
          ..subscriptionPlan = 'basic'
          ..subscriptionStatus = 'trial'
          ..createdAt = DateTime.now()
          ..supabaseId = supabaseSchool?['id']
          ..syncedWithSupabase = supabaseSchool != null
          ..lastSyncAt = supabaseSchool != null ? DateTime.now() : null;

        await isar.schools.put(school);
      });

      await registerUser(
        usernameController.text.trim(),
        userEmailController.text.trim(),
        passwordController.text.trim(),
      );

      // إنشاء فئات الدخل الافتراضية
      await _createDefaultIncomeCategories();
      
      // إنشاء فئات المصروفات الافتراضية
      await _createDefaultExpenseCategories();

      _showSuccessDialog(hasOnlineFeatures: supabaseSchool != null);
    } catch (e) {
      debugPrint('Error: $e');
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createDefaultIncomeCategories() async {
    final defaultIncomeCategories = [
      {'name': 'قسط طالب', 'identifier': 'student_fee'},
      {'name': 'رسوم تسجيل', 'identifier': 'registration_fee'},
      {'name': 'رسوم كتب ومواد تعليمية', 'identifier': 'books_materials_fee'},
      {'name': 'رسوم أنشطة إضافية', 'identifier': 'activities_fee'},
      {'name': 'رسوم باص', 'identifier': 'transport_fee'},
      {'name': 'رسوم وجبات', 'identifier': 'meal_fee'},
      {'name': 'رسوم امتحانات', 'identifier': 'exam_fee'},
      {'name': 'دخل متنوع', 'identifier': 'miscellaneous_income'},
    ];

    await isar.writeTxn(() async {
      for (var categoryData in defaultIncomeCategories) {
        final exists = await isar.incomeCategorys
            .filter()
            .identifierEqualTo(categoryData['identifier']!)
            .findFirst();

        if (exists == null) {
          final category = IncomeCategory()
            ..name = categoryData['name']!
            ..identifier = categoryData['identifier']!;

          await isar.incomeCategorys.put(category);
        }
      }
    });
  }

  Future<void> _createDefaultExpenseCategories() async {
    final defaultExpenseCategories = [
      {'name': 'رواتب المعلمين', 'identifier': 'teacher_salaries'},
      {'name': 'رواتب الإداريين', 'identifier': 'admin_salaries'},
      {'name': 'فواتير الكهرباء', 'identifier': 'electricity_bills'},
      {'name': 'فواتير المياه', 'identifier': 'water_bills'},
      {'name': 'فواتير الهاتف والإنترنت', 'identifier': 'phone_internet_bills'},
      {'name': 'صيانة المباني', 'identifier': 'building_maintenance'},
      {'name': 'صيانة الأجهزة', 'identifier': 'equipment_maintenance'},
      {'name': 'مواد تنظيف', 'identifier': 'cleaning_supplies'},
      {'name': 'قرطاسية ومستلزمات مكتبية', 'identifier': 'office_supplies'},
      {'name': 'مواد تعليمية', 'identifier': 'teaching_materials'},
      {'name': 'أمن وحراسة', 'identifier': 'security_guard'},
      {'name': 'مصروفات متنوعة', 'identifier': 'miscellaneous_expense'},
    ];

    await isar.writeTxn(() async {
      for (var categoryData in defaultExpenseCategories) {
        // التحقق من وجود جدول ExpenseCategory
        try {
          final exists = await isar.expenseCategorys
              .filter()
              .identifierEqualTo(categoryData['identifier']!)
              .findFirst();

          if (exists == null) {
            final category = ExpenseCategory()
              ..name = categoryData['name']!
              ..identifier = categoryData['identifier']!;

            await isar.expenseCategorys.put(category);
          }
        } catch (e) {
          // إذا لم يكن جدول المصروفات موجود، تجاهل هذه الخطوة
          debugPrint('ExpenseCategory table not found: $e');
        }
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog({bool hasOnlineFeatures = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('تم الإعداد بنجاح!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تم إنشاء حسابك وإعداد النظام بنجاح.'),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎯 الفترة التجريبية نشطة لمدة 7 أيام'),
                    Text('📚 تم إنشاء الفئات الافتراضية'),
                    Text('👤 تم إنشاء حساب المدير'),
                    if (hasOnlineFeatures) ...[
                      Text('☁️ تم تفعيل المزامنة مع السحابة'),
                      Text('📊 ميزة التقارير الأونلاين متاحة'),
                    ] else ...[
                      Text('⚠️ وضع غير متصل - التقارير محليًا فقط'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('متابعة إلى تسجيل الدخول'),
            ),
          ],
        );
      },
    );
  }

  void _nextStep() {
    if (currentStep == 0) {
      // التحقق من بيانات المدرسة
      if (schoolNameController.text.trim().isEmpty) {
        _showSnackBar('يرجى إدخال اسم المدرسة', Colors.red);
        return;
      }
      if (!_isValidEmail(schoolEmailController.text.trim()) && schoolEmailController.text.trim().isNotEmpty) {
        _showSnackBar('يرجى إدخال بريد إلكتروني صحيح للمدرسة', Colors.red);
        return;
      }
    }
    
    if (currentStep < 1) {
      setState(() => currentStep++);
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9+\-\s\(\)]{10,15}$').hasMatch(phone);
  }

  InputDecoration _inputDecoration(String label, {IconData? icon, String? helperText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade600) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد النظام لأول مرة'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStepIndicator(0, 'بيانات المدرسة', Icons.school),
                ),
                Container(width: 2, height: 20, color: Colors.grey.shade300),
                Expanded(
                  child: _buildStepIndicator(1, 'بيانات المدير', Icons.person),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => currentStep = index),
              children: [
                _buildSchoolDataStep(),
                _buildAdminDataStep(),
              ],
            ),
          ),
          // Navigation Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _previousStep,
                      icon: Icon(Icons.arrow_back),
                      label: Text('السابق'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (currentStep > 0) SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: currentStep < 1 ? _nextStep : saveInitialData,
                          icon: Icon(currentStep < 1 ? Icons.arrow_forward : Icons.save),
                          label: Text(currentStep < 1 ? 'التالي' : 'حفظ وبدء الاستخدام'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, IconData icon) {
    bool isActive = currentStep >= step;
    bool isCurrent = currentStep == step;
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade600 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: Colors.blue.shade800, width: 2) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolDataStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.blue.shade600, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'بيانات المدرسة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: schoolNameController,
                  decoration: _inputDecoration(
                    'اسم المدرسة *',
                    icon: Icons.school,
                    helperText: 'أدخل الاسم الكامل للمدرسة',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'اسم المدرسة مطلوب' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: schoolEmailController,
                  decoration: _inputDecoration(
                    'البريد الإلكتروني',
                    icon: Icons.email,
                    helperText: 'البريد الإلكتروني الرسمي للمدرسة',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val != null && val.isNotEmpty && !_isValidEmail(val)) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: schoolPhoneController,
                  decoration: _inputDecoration(
                    'رقم الهاتف',
                    icon: Icons.phone,
                    helperText: 'رقم هاتف المدرسة',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                  ],
                  validator: (val) {
                    if (val != null && val.isNotEmpty && !_isValidPhone(val)) {
                      return 'يرجى إدخال رقم هاتف صحيح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: schoolAddressController,
                  decoration: _inputDecoration(
                    'عنوان المدرسة',
                    icon: Icons.location_on,
                    helperText: 'العنوان الكامل للمدرسة',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'شعار المدرسة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: pickLogoImage,
                            icon: Icon(Icons.image),
                            label: Text('اختيار شعار'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(width: 16),
                          if (selectedLogo != null) ...[
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedLogo!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() => selectedLogo = null),
                              icon: Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDataStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.blue.shade600, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'بيانات المدير الأساسي',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: _inputDecoration(
                      'اسم المستخدم *',
                      icon: Icons.person,
                      helperText: 'اسم المستخدم للدخول إلى النظام',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'اسم المستخدم مطلوب';
                      if (val.length < 3) return 'يجب أن يكون 3 أحرف على الأقل';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: userEmailController,
                    decoration: _inputDecoration(
                      'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      helperText: 'البريد الإلكتروني الشخصي للمدير',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val != null && val.isNotEmpty && !_isValidEmail(val)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      'كلمة المرور *',
                      icon: Icons.lock,
                      helperText: 'يجب أن تكون 6 أحرف على الأقل',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'كلمة المرور مطلوبة';
                      if (val.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _inputDecoration(
                      'تأكيد كلمة المرور *',
                      icon: Icons.lock_outline,
                      helperText: 'أعد كتابة كلمة المرور',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'تأكيد كلمة المرور مطلوب';
                      if (val != passwordController.text) return 'كلمة المرور غير متطابقة';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade600),
                            SizedBox(width: 8),
                            Text(
                              'معلومات مهمة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('• سيتم منحك صلاحيات المدير الكاملة'),
                        Text('• يمكنك إضافة مستخدمين آخرين لاحقًا'),
                        Text('• احتفظ ببيانات الدخول في مكان آمن'),
                        Text('• يمكنك تغيير كلمة المرور لاحقًا من الإعدادات'),
                      ],
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

  @override
  void dispose() {
    schoolNameController.dispose();
    schoolEmailController.dispose();
    schoolPhoneController.dispose();
    schoolAddressController.dispose();
    usernameController.dispose();
    userEmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
