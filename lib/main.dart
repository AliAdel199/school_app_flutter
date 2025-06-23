
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/expense.dart';
import 'package:school_app_flutter/localdatabase/expense_category.dart';
import 'package:school_app_flutter/localdatabase/income.dart';
import 'package:school_app_flutter/localdatabase/income_category.dart';
import 'package:school_app_flutter/localdatabase/log.dart';
import 'package:school_app_flutter/localdatabase/user.dart';
import '../employee/employee_list_screen.dart';
import '../income_expeness/incomes.dart';
import '../reports/classes_list_screen.dart';
import '../reports/reportsscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

late Isar isar; // تعريف متغير Isar عالمي يمكن استخدامه في أي مكان
bool isCloud = true; // تحديد ما إذا كان التطبيق يعمل في بيئة سحابية


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null); // ← هذا السطر الجديد

  final isLicensed = await LicenseManager.verifyLicense();
  if (!isLicensed) {
    await LicenseManager.createLicenseFile(); // أول مرة فقط
  }
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
    IncomeSchema,IncomeCategorySchema,
    LogSchema
    ,ExpenseSchema,ExpenseCategorySchema
  ], directory: dir.path,inspector: true,name: 'school_app_flutter',);
    final schools = await isar.schools.where().findAll();

  runApp( SchoolApp(showInitialSetup: schools.isEmpty,));
}

class SchoolApp extends StatelessWidget {
    final bool showInitialSetup;

   SchoolApp({super.key, required this.showInitialSetup});

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
      // home: const LoginScreen(),

         initialRoute: '/',
      routes: {
        '/': (context) => showInitialSetup?InitialSetupScreen(): LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/students': (context) => const StudentsListScreen(),
        '/add-student': (context) =>  AddEditStudentScreen(),
        '/classes': (context) => const ClassesListScreen(),
        '/add-class': (context) => const AddClassScreen(),
        '/edit-class': (context) => EditClassScreen(
          classData: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
        ),
        '/subjects': (context) => const SubjectsListScreen(),
        '/studentpayments': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return StudentPaymentsScreen(
            studentId: args['studentId'],
            fullName: args['fullName'],
            // className: args['className'],
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
