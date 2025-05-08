
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

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
      home: const LoginScreen(),
    );
  }
}
