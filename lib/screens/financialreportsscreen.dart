import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() => isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final profile = await supabase
          .from('profiles')
          .select('school_id')
          .eq('id', userId)
          .single();

      final schoolId = profile['school_id'];

      final data = await supabase
          .from('student_fee_status')
          .select('id, academic_year, annual_fee, paid_amount, last_payment_date, students:student_id(full_name, student_id, class_id, classes(name), school_id)')
          .eq('students.school_id', schoolId);

      final formatted = data.map<Map<String, dynamic>>((entry) {
        final student = entry['students'];
        final annualFee = entry['annual_fee'] ?? 0;
        final paid = entry['paid_amount'] ?? 0;
        final due = annualFee - paid;
        final lastDate = entry['last_payment_date'] != null
            ? DateTime.tryParse(entry['last_payment_date'])
            : null;

        String status;
        if (due == 0) {
          status = 'مكتمل';
        } else if (lastDate != null && lastDate.isBefore(DateTime.now())) {
          status = 'متأخر';
        } else {
          status = 'غير مكتمل';
        }

        return {
          'full_name': student['full_name'],
          'class_name': student['classes']?['name'] ?? '-',
          'academic_year': entry['academic_year'] ?? '-',
          'annual_fee': annualFee,
          'paid_amount': paid,
          'due_amount': due,
          'last_payment_date': lastDate != null
              ? DateFormat('yyyy-MM-dd').format(lastDate)
              : '-',
          'status': status,
        };
      }).toList();

      setState(() {
        reports = formatted;
      });
    } catch (e) {
      debugPrint('خطأ في تحميل التقارير: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'متأخر':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير المالية')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = reports[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['full_name'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('الصف: ${r['class_name']}'),
                        Text('السنة الدراسية: ${r['academic_year']}'),
                        Text('القسط السنوي: ${r['annual_fee']} د.ع'),
                        Text('المدفوع: ${r['paid_amount']} د.ع'),
                        Text('المتبقي: ${r['due_amount']} د.ع'),
                        Text('آخر دفعة: ${r['last_payment_date']}'),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(r['status']),
                          backgroundColor:
                              statusColor(r['status']).withOpacity(0.2),
                          labelStyle:
                              TextStyle(color: statusColor(r['status'])),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
