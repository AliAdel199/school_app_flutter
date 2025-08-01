import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_app_flutter/localdatabase/subject_mark.dart';
import 'package:school_app_flutter/localdatabase/attendance.dart';
import 'package:school_app_flutter/localdatabase/license_status_view.dart';
import 'package:school_app_flutter/localdatabase/license_stats_view.dart';
import '/localdatabase/expense.dart';
import '/localdatabase/expense_category.dart';
import '/localdatabase/income.dart';
import '/localdatabase/income_category.dart';
import '/localdatabase/invoice_serial.dart';
import '/localdatabase/log.dart';
import '/localdatabase/user.dart';
import '/student/PaymentsListScreen.dart';
import '../employee/employee_list_screen.dart';
import '../income_expeness/incomes.dart';
import 'classes/classes_list_screen.dart';
import '../reports/reportsscreen.dart';
import '../reports/student_payment_status_report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'LicenseCheckScreen.dart';
import 'LogsScreen.dart';
import 'UsersScreen.dart';
import 'screens/database_test_screen.dart';
import 'screens/system_test_screen.dart';
import 'tests/quick_system_test.dart';
import 'income_expeness/ExpenseListScreen.dart';
import 'income_expeness/addexpenesscreen.dart';
import 'license_manager.dart';
import 'localdatabase/class.dart';
import 'localdatabase/discount_type.dart';
import 'localdatabase/grade.dart';
import 'localdatabase/school.dart';
import 'localdatabase/student.dart';
import 'localdatabase/student_discount.dart';
import 'localdatabase/student_fee_status.dart';
import 'localdatabase/student_payment.dart';
import 'localdatabase/subject.dart';
import 'localdatabase/auto_discount_settings.dart';
import 'reports/SalaryReportScreen.dart';
import 'employee/add_edit_employee.dart';
import 'employee/monthlysalaryscreen.dart';
import 'schoolregstristion.dart';
import 'services/services.dart';
import 'student/add_student_screen_supabase.dart';
import 'classes/addclassscreen.dart';
import 'dashboard_screen.dart';
import 'classes/edit_class_screen.dart';
import 'reports/financialreportsscreen.dart';
import 'reports/login_screen.dart';
import 'student/auto_discount_screen.dart';
import 'student/discount_management_screen.dart';
import 'student/simple_marks_management_screen.dart';
import 'student/attendance_management_screen.dart';
import 'student/student_discounts_screen.dart';
import 'student/studentpaymentscreen.dart';
import 'student/students_list_screen_supabase.dart';
import 'reports/subjectslistscreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'student/subject_marks_management_screen.dart';
import 'student/student_grades_report_screen.dart';
import 'student/class_grades_report_screen.dart';

late Isar isar; // تعريف متغير Isar عالمي يمكن استخدامه في أي مكان

String academicYear = '';

bool isCloud = true; // تحديد ما إذا كان التطبيق يعمل في بيئة سحابية

Future<void> loadAcademicYear() async {
  final prefs = await SharedPreferences.getInstance();
  academicYear = prefs.getString('academicYear') ?? '';
  
  // إذا لم تكن السنة الدراسية محفوظة، أنشئ قيمة افتراضية
  if (academicYear.isEmpty) {
    final currentDate = DateTime.now();
    final currentYear = currentDate.year;
    final currentMonth = currentDate.month;
    
    // إذا كان الشهر بين سبتمبر وديسمبر، فالسنة الدراسية تبدأ من السنة الحالية
    // إذا كان بين يناير وأغسطس، فالسنة الدراسية بدأت من السنة السابقة
    if (currentMonth >= 9) {
      academicYear = '$currentYear-${currentYear + 1}';
    } else {
      academicYear = '${currentYear - 1}-$currentYear';
    }
    
    // حفظ السنة الدراسية الافتراضية
    await saveAcademicYear(academicYear);
    debugPrint('تم إنشاء سنة دراسية افتراضية: $academicYear');
  }
}

Future<void> saveAcademicYear(String year) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('academicYear', year);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
    final dir2 = await getApplicationSupportDirectory();
print(dir2.path);
  await Supabase.initialize(
    url: SupabaseService.supabaseUrl,
    anonKey: SupabaseService.supabaseAnonKey,
    debug: false, // تعطيل الـ debug في الإنتاج
  );

  final dir = Directory.current;
  isar = await Isar.open([
    StudentSchema,
    StudentPaymentSchema,
    StudentFeeStatusSchema,
    SchoolClassSchema,
    GradeSchema,
    SchoolSchema,
    SubjectSchema,
    UserSchema,
    IncomeSchema,
    IncomeCategorySchema,
    LogSchema,
    InvoiceCounterSchema,
    ExpenseSchema,
    ExpenseCategorySchema,
    SubjectMarkSchema,
    StudentDiscountSchema,      // إضافة جديدة
    DiscountTypeSchema,         // إضافة جديدة
    AutoDiscountSettingsSchema, // إضافة إعدادات الخصومات التلقائية
    AttendanceSchema,           // إضافة نموذج الحضور
    LicenseStatusViewSchema,    // إضافة نموذج حالة الترخيص
    LicenseStatsViewSchema,     // إضافة نموذج إحصائيات الترخيص
  ], directory: dir.path, inspector: true, name: 'school_app_flutter');

  // تحميل السنة الدراسية من الإعدادات
  await loadAcademicYear();
  debugPrint('السنة الدراسية المحملة: $academicYear');

  final archived = await LicenseManager.verifyLicense();
  final inTrial = await LicenseManager.isTrialValid();
  
  // إصلاح مشكلة بقاء الفترة التجريبية بعد التفعيل
  if (archived) {
    await LicenseManager.fixTrialAfterActivation();
  }
  
  final schools = await isar.schools.where().findAll();

if (schools.isEmpty && !archived && !inTrial) {
  // لا تنشئ الفترة التجريبية تلقائيًا – وجّه المستخدم لواجهة التفعيل
  // أو أنشئها فقط إذا لم يكن هناك ملف إطلاقًا (أول مرة)
  final trialExists = await LicenseManager.trialFileExists();
  if (!trialExists) {
    await LicenseManager.createTrialLicenseFile();
  }
}
  // 🔐 التحقق من الأمان قبل أي شيء
  if (!archived && !inTrial) {
    runApp(const MaterialApp(       debugShowCheckedModeBanner: false,
 home: LicenseCheckScreen()));
    return;
  }

  // ✅ بعد التأكد من الأمان
  // final schools = await isar.schools.where().findAll();
  runApp(SchoolApp(
    showInitialSetup: schools.isEmpty,
    showActivation: false,
  ));

  // runApp(SchoolApp(
  //   showInitialSetup: schools.isEmpty && (archived || inTrial),
  //   showActivation: schools.isEmpty && !archived || !inTrial,
  // ));
}

class SchoolApp extends StatelessWidget {
  final bool showInitialSetup;
  final bool showActivation;

  const SchoolApp({super.key, required this.showInitialSetup, required this.showActivation});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey.shade100,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => showActivation
            ? const LicenseCheckScreen()
            : showInitialSetup
                ? const InitialSetupScreen()
                : const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/students': (context) => const StudentsListScreen(),
        '/add-student': (context) => AddEditStudentScreen(),
        '/classes': (context) => const ClassesListScreen(),
        '/add-class': (context) => const AddClassScreen(),
'/discount-management': (context) => const DiscountManagementScreen(),
        '/auto-discount': (context) => const AutoDiscountScreen(),

        '/edit-class': (context) => EditClassScreen(
              classData: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
            ),
        '/subjects': (context) => const SubjectsListScreen(),
        '/payment-list': (context) => const PaymentsListScreen(),
        '/studentpayments': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return StudentPaymentsScreen(
            studentId: args['studentId'],
            fullName: args['fullName'],
          );
        },
        '/student-discounts': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return StudentDiscountsScreen(
            student: args['student'],
            academicYear: args['academicYear'],
          );
        },
        '/financial-reports': (context) => const FinancialReportsScreen(),
        '/reportsscreen': (context) => const ReportsScreen(),
        '/student-payment-status': (context) => const StudentPaymentStatusReport(),
        '/add-edit-employee': (context) => AddEditEmployeeScreen(
              employee: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?,
            ),
        '/employee-list': (context) => const EmployeeListScreen(),
        '/monthly-salary': (context) => const MonthlySalaryScreen(),
        '/salary-report': (context) => const SalaryReportScreen(),
        '/expense-list': (context) => const ExpensesListScreen(),
        '/add-expense': (context) => AddEditExpenseScreen(
              expense: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?,
            ),
        '/income': (context) => const IncomesListScreen(),
        '/marks-management': (context) => const MarksManagementScreen(),
        '/attendance-management': (context) => const AttendanceManagementScreen(), // إضافة جديدة
        '/student-grades-report': (context) => const StudentGradesReportScreen(),
        '/class-grades-report': (context) => const ClassGradesReportScreen(),
        '/subject-marks-advanced': (context) => const SubjectMarksManagementScreen(),
        '/user-screen': (context) => const UsersScreen(),
        '/logs-screen': (context) => const LogsScreen(),
        '/database-test': (context) => DatabaseTestScreen(),
        '/system-test': (context) => const SystemTestScreen(),
      },
    );
  }
}