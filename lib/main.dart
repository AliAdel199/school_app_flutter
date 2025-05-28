
import 'package:flutter/material.dart';
import 'package:school_app_flutter/screens/classes_list_screen.dart';
import 'package:school_app_flutter/screens/reportsscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/add_student_screen_supabase.dart';
import 'screens/addclassscreen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edit_class_screen.dart';
import 'screens/financialreportsscreen.dart';
import 'screens/login_screen.dart';
import 'screens/studentpaymentscreen.dart';
import 'screens/students_list_screen_supabase.dart';
import 'screens/subjectslistscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      },
    );
  }
}
