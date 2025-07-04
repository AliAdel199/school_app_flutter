import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_app_flutter/ActivationScreen.dart';
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
import '../reports/classes_list_screen.dart';
import '../reports/reportsscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'LicenseCheckScreen.dart';
import 'LogsScreen.dart';
import 'UsersScreen.dart';
import 'income_expeness/ExpenseListScreen.dart';
import 'income_expeness/addexpenesscreen.dart';
import 'license_manager.dart';
import 'localdatabase/class.dart';
import 'localdatabase/grade.dart';
import 'localdatabase/school.dart';
import 'localdatabase/student.dart';
import 'localdatabase/student_fee_status.dart';
import 'localdatabase/student_payment.dart';
import 'localdatabase/subject.dart';
import 'reports/SalaryReportScreen.dart';
import 'employee/add_edit_employee.dart';
import 'employee/monthlysalaryscreen.dart';
import 'schoolregstristion.dart';
import 'student/add_student_screen_supabase.dart';
import 'reports/addclassscreen.dart';
import 'dashboard_screen.dart';
import 'reports/edit_class_screen.dart';
import 'reports/financialreportsscreen.dart';
import 'reports/login_screen.dart';
import 'student/studentpaymentscreen.dart';
import 'student/students_list_screen_supabase.dart';
import 'reports/subjectslistscreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

late Isar isar; // تعريف متغير Isar عالمي يمكن استخدامه في أي مكان

String academicYear = '';

bool isCloud = true; // تحديد ما إذا كان التطبيق يعمل في بيئة سحابية

Future<void> loadAcademicYear() async {
  final prefs = await SharedPreferences.getInstance();
  academicYear = prefs.getString('academicYear') ?? '';
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
    url: 'https://lhzujcquhgxhsmmjwgdq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoenVqY3F1aGd4aHNtbWp3Z2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MjQ4NjQsImV4cCI6MjA2MTQwMDg2NH0.u7qPHRu_TdmNjPQJhMeXMZVI37xJs8IoX5Dcrg7fxV8',
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
    ExpenseCategorySchema
  ], directory: dir.path, inspector: true, name: 'school_app_flutter');

  final archived = await LicenseManager.verifyLicense();
  final inTrial = await LicenseManager.isTrialValid();
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

  SchoolApp({super.key, required this.showInitialSetup, required this.showActivation});


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
        '/financial-reports': (context) => const FinancialReportsScreen(),
        '/reportsscreen': (context) => const ReportsScreen(),
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
        '/user-screen': (context) => const UsersScreen(),
        '/logs-screen': (context) => const LogsScreen(),
      },
    );
  }
}
