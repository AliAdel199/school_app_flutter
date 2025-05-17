import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dialogs/payment_dialog_ui.dart';

class StudentPaymentsScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentPaymentsScreen({super.key, required this.student});

  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> payments = [];
  Map<String, dynamic>? feeStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() => isLoading = true);
    try {
      final paymentRes = await supabase
          .from('student_payments')
          .select()
          .eq('student_id', widget.student['id'])
          .order('paid_at', ascending: false);

      final feeRes = await supabase
          .from('student_fee_status')
          .select()
          .eq('student_id', widget.student['id'])
          .maybeSingle();

      payments = List<Map<String, dynamic>>.from(paymentRes);
      feeStatus = feeRes;
    } catch (e) {
      debugPrint('فشل في تحميل الدفعات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء تحميل البيانات: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final fee = feeStatus?['annual_fee'] ?? 0;
    final paid = feeStatus?['paid_amount'] ?? 0;
    final due = feeStatus?['due_amount'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('دفعات الطالب: ${widget.student['full_name']}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showAddPaymentDialog(
            context: context,
            studentId: widget.student['id'],
            academicYear: feeStatus?['academic_year'] ?? 'غير معروف',
            onSuccess: fetchPayments,
          );
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatCard('القسط السنوي', '${formatter.format(fee)} د.ع', Colors.blue),
                          _buildStatCard('المدفوع', '${formatter.format(paid)} د.ع', Colors.green),
                          _buildStatCard('المتبقي', '${formatter.format(due)} د.ع', Colors.red),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('سجل الدفعات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: payments.isEmpty
                            ? const Center(child: Text('لا توجد دفعات مسجلة'))
                            : ListView.separated(
                                itemCount: payments.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final p = payments[index];
                                  return ListTile(
                                    title: Text('${formatter.format(p['amount'])} د.ع'),
                                    subtitle: Text('تاريخ: ${p['paid_at'].toString().split('T').first}'),
                                    trailing: Text(p['receipt_number'] ?? 'بدون رقم'),
                                  );
                                },
                              ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
