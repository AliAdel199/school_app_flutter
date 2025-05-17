import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'addstudentfeestatusscreen .dart';

class StudentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final supabase = Supabase.instance.client;
  bool hasFeeStatus = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkFeeStatus();
  }

  Future<void> checkFeeStatus() async {
    try {
      final res = await supabase
          .from('student_fee_status')
          .select()
          .eq('student_id', widget.student['id'])
          .maybeSingle();

      setState(() {
        hasFeeStatus = res != null;
      });
    } catch (e) {
      debugPrint('خطأ في التحقق من حالة القسط: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student['full_name'])),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الهوية: ${widget.student['national_id'] ?? '-'}'),
                  Text('الصف: ${widget.student['class_name'] ?? '-'}'),
                  const SizedBox(height: 20),

                  if (!hasFeeStatus)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddStudentFeeStatusScreen(
                              studentId: widget.student['id'],
                            ),
                          ),
                        );
                        await checkFeeStatus(); // إعادة التحقق بعد الإضافة
                      },
                      icon: const Icon(Icons.attach_money),
                      label: const Text('إضافة حالة القسط السنوي'),
                    ),

                  if (hasFeeStatus)
                    const Text('✓ هذا الطالب لديه حالة قسط محفوظة.'),
                ],
              ),
            ),
    );
  }
}
