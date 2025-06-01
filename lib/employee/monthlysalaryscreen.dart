import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonthlySalaryScreen extends StatefulWidget {
  const MonthlySalaryScreen({super.key});

  @override
  State<MonthlySalaryScreen> createState() => _MonthlySalaryScreenState();
}

class _MonthlySalaryScreenState extends State<MonthlySalaryScreen> {
  final supabase = Supabase.instance.client;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Map<String, dynamic>> salaries = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null);
  }

  Future<void> generateSalaries() async {
    setState(() => isLoading = true);

    try {
      final employeeResponse = await supabase.from('employees').select();
      final List employees = employeeResponse;

      final List<Map<String, dynamic>> newSalaries = [];

      for (final emp in employees) {
        final employeeId = emp['id'];
        final baseSalary = (emp['base_salary'] as num?)?.toDouble() ?? 0.0;

        // جلب المخصصات
        final allowanceData = await supabase
            .from('employee_allowances')
            .select('amount')
            .eq('employee_id', employeeId);

        final totalAllowances = (allowanceData as List)
            .fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());

        // جلب الاستقطاعات
        final deductionData = await supabase
            .from('employee_deductions')
            .select('amount')
            .eq('employee_id', employeeId);

        final totalDeductions = (deductionData as List)
            .fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());

        newSalaries.add({
          'employee_id': employeeId,
          'full_name': emp['full_name'],
          'base_salary': baseSalary,
          'total_allowances': totalAllowances,
          'total_deductions': totalDeductions,
          'extra_deduction': 0.0,
          'extra_allowance': 0.0,
          'notes': '',
        });
      }

      setState(() => salaries = newSalaries);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إعداد الرواتب: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  double calculateNetSalary(Map<String, dynamic> salary) {
    final net = (salary['base_salary'] ?? 0) +
        (salary['total_allowances'] ?? 0) +
        (salary['extra_allowance'] ?? 0) -
        (salary['total_deductions'] ?? 0) -
        (salary['extra_deduction'] ?? 0);
    return net;
  }

  Future<void> saveSalary(int index) async {
    final data = salaries[index];
    final net = calculateNetSalary(data);
    final salaryMonth = DateFormat('yyyy-MM-01').format(selectedMonth);

    try {
      await supabase.from('employee_salaries').upsert({
        'employee_id': data['employee_id'],
        'salary_month': salaryMonth,
        'base_salary': data['base_salary'],
        'total_allowances': data['total_allowances'],
        'total_deductions': data['total_deductions'],
        'extra_deduction': data['extra_deduction'],
        'extra_allowance': data['extra_allowance'],
        'notes': data['notes'],
        'net_salary': net,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الراتب')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حفظ الراتب: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد الرواتب الشهرية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('الشهر:'),
                const SizedBox(width: 8),
                DropdownButton<DateTime>(
                  value: selectedMonth,
                  items: List.generate(12, (index) {
                    final date = DateTime(DateTime.now().year, index + 1);
                    return DropdownMenuItem(
                      value: date,
                      child: Text(DateFormat('MMMM yyyy', 'ar').format(date)),
                    );
                  }),
                  onChanged: (val) => setState(() => selectedMonth = val!),
                ),
                const SizedBox(width: 16),
                const Text('إعداد الرواتب'),
                SizedBox(
                  height: 40,width: 120,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : generateSalaries,
                    child: const Text('إعداد الرواتب'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!isLoading && salaries.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: salaries.length,
                  itemBuilder: (context, index) {
                    final s = salaries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('الراتب الاسمي: ${s['base_salary']}'),
                                const SizedBox(width: 16),
                                Text('المخصصات: ${s['total_allowances']}'),
                                const SizedBox(width: 16),
                                Text('الاستقطاعات: ${s['total_deductions']}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: s['extra_deduction'].toString(),
                                    decoration: const InputDecoration(labelText: 'خصم إضافي'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => salaries[index]['extra_deduction'] = double.tryParse(val) ?? 0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: s['extra_allowance'].toString(),
                                    decoration: const InputDecoration(labelText: 'مكافأة'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => salaries[index]['extra_allowance'] = double.tryParse(val) ?? 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: s['notes'],
                              decoration: const InputDecoration(labelText: 'ملاحظات'),
                              onChanged: (val) => salaries[index]['notes'] = val,
                            ),
                            const SizedBox(height: 8),
                            Text('الصافي: ${calculateNetSalary(s).toStringAsFixed(2)} د.ع',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => saveSalary(index),
                                child: const Text('حفظ'),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
