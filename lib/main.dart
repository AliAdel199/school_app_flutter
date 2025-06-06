
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:school_app_flutter/employee/employee_list_screen.dart';
import 'package:school_app_flutter/reports/classes_list_screen.dart';
import 'package:school_app_flutter/reports/reportsscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'employee/SalaryReportScreen.dart';
import 'employee/add_edit_employee.dart';
import 'employee/monthlysalaryscreen.dart';
import 'student/add_student_screen_supabase.dart';
import 'reports/addclassscreen.dart';
import 'dashboard_screen.dart';
import 'reports/edit_class_screen.dart';
import 'reports/financialreportsscreen.dart';
import 'reports/login_screen.dart';
import 'student/studentpaymentscreen.dart';
import 'student/students_list_screen_supabase.dart';
import 'reports/subjectslistscreen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('ar', null); // ← هذا السطر الجديد

  await Supabase.initialize(
    url: 'https://lhzujcquhgxhsmmjwgdq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoenVqY3F1aGd4aHNtbWp3Z2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MjQ4NjQsImV4cCI6MjA2MTQwMDg2NH0.u7qPHRu_TdmNjPQJhMeXMZVI37xJs8IoX5Dcrg7fxV8',
  );

  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

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
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/students': (context) => const StudentsListScreen(),
        '/add-student': (context) => const AddEditStudentScreen(),
        '/classes': (context) => const ClassesListScreen(),
        '/add-class': (context) => const AddClassScreen(),
        '/edit-class': (context) => EditClassScreen(
          classData: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
        ),
        '/subjects': (context) => const SubjectsListScreen(),
        '/studentpayments': (context) => StudentPaymentsScreen(
          student: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
        ),
        '/financial-reports': (context) => const FinancialReportsScreen(),
        '/reportsscreen': (context) => const ReportsScreen(),
        '/add-edit-employee': (context) => AddEditEmployeeScreen(
          employee: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?,
        ),
        '/employee-list': (context) => const EmployeeListScreen(),
        '/monthly-salary': (context) => const MonthlySalaryScreen(),
        '/salary-report': (context) => const SalaryReportScreen(),
      },
    );
  }
}
