
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'add_student_payment_screen.dart';

class StudentPaymentsScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentPaymentsScreen({super.key, required this.student});

  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  final supabase = Supabase.instance.client;
  Map<String, List<Map<String, dynamic>>> paymentsByYear = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() => isLoading = true);
    try {
      final res = await supabase
          .from('student_fee_status')
          .select()
          .eq('student_id', widget.student['id'])
          .order('paid_at', ascending: false);

      final all = List<Map<String, dynamic>>.from(res);

      paymentsByYear.clear();
      for (var p in all) {
        final year = p['academic_year'] ?? 'غير محدد';
        paymentsByYear.putIfAbsent(year, () => []).add(p);
      }
    } catch (e) {
      debugPrint('خطأ في جلب الدفعات: \n$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildInfoCard({required String label, required String value, required Color color}) {
    return Expanded(
      child: Card(
        elevation: 3,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final annualFee = widget.student['annual_fee'] ?? 0;
    final allPayments = paymentsByYear.values.expand((e) => e).toList();
    final totalPaid = allPayments.fold<num>(0, (sum, item) => sum + (item['paid_amount'] ?? 0));
    final remaining = annualFee - totalPaid;

    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text('دفعات ${widget.student['full_name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddStudentFeeStatusScreen(
                    student: widget.student,
                    onSaved: fetchPayments,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      Row(
                        children: [
                          buildInfoCard(label: 'القسط السنوي', value: '$annualFee د.ع', color: Colors.teal),
                          const SizedBox(width: 12),
                          buildInfoCard(label: 'المدفوع', value: '$totalPaid د.ع', color: Colors.green),
                          const SizedBox(width: 12),
                          buildInfoCard(
                              label: 'المتبقي',
                              value: '$remaining د.ع',
                              color: remaining > 0 ? Colors.red : Colors.green),
                        ],
                      )
                    else
                      Column(
                        children: [
                          buildInfoCard(label: 'القسط السنوي', value: '$annualFee د.ع', color: Colors.teal),
                          const SizedBox(height: 12),
                          buildInfoCard(label: 'المدفوع', value: '$totalPaid د.ع', color: Colors.green),
                          const SizedBox(height: 12),
                          buildInfoCard(
                              label: 'المتبقي',
                              value: '$remaining د.ع',
                              color: remaining > 0 ? Colors.red : Colors.green),
                        ],
                      ),
                    const SizedBox(height: 24),
                    const Text('الدفعات حسب السنة الدراسية:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...paymentsByYear.entries.map((entry) {
                      final year = entry.key;
                      final items = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text('السنة: $year',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...items.map((p) => Card(
                                child: ListTile(
                                  leading: const Icon(Icons.monetization_on),
                                  title: Text('${p['amount']} د.ع'),
                                  subtitle: Text(
                                      'بتاريخ ${p['paid_at']?.toString().split("T").first ?? '-'} ${p['notes'] ?? ''}'),
                                ),
                              )),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}
