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

        final allowanceData = await supabase
            .from('employee_allowances')
            .select('amount')
            .eq('employee_id', employeeId);

        final totalAllowances = (allowanceData as List)
            .fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());

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

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.blueAccent),
            const SizedBox(width: 8),
            const Text('الشهر:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            DropdownButton<DateTime>(
              value: selectedMonth,
              borderRadius: BorderRadius.circular(12),
              items: List.generate(12, (index) {
                final date = DateTime(DateTime.now().year, index + 1);
                return DropdownMenuItem(
                  value: date,
                  child: Text(DateFormat('MMMM yyyy', 'ar').format(date)),
                );
              }),
              onChanged: (val) => setState(() => selectedMonth = val!),
            ),
            const Spacer(),
            SizedBox(
              height: 40,width: 160,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('إعداد الرواتب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading ? null : generateSalaries,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(Map<String, dynamic> s, int index) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    s['full_name'].toString().substring(0, 1),
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s['full_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile('الراتب الاسمي', s['base_salary']),
                _infoTile('المخصصات', s['total_allowances']),
                _infoTile('الاستقطاعات', s['total_deductions']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: s['extra_deduction'].toString(),
                    decoration: InputDecoration(
                      labelText: 'خصم إضافي',
                      prefixIcon: const Icon(Icons.remove_circle_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {
                      salaries[index]['extra_deduction'] = double.tryParse(val) ?? 0;
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: s['extra_allowance'].toString(),
                    decoration: InputDecoration(
                      labelText: 'مكافأة',
                      prefixIcon: const Icon(Icons.add_circle_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {
                      salaries[index]['extra_allowance'] = double.tryParse(val) ?? 0;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: s['notes'],
              decoration: InputDecoration(
                labelText: 'ملاحظات',
                prefixIcon: const Icon(Icons.note_alt_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (val) => setState(() {
                salaries[index]['notes'] = val;
              }),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الصافي: ${calculateNetSalary(s).toStringAsFixed(2)} د.ع',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => saveSalary(index),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('إعداد الرواتب الشهرية'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildHeader(),
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!isLoading && salaries.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: salaries.length,
                  itemBuilder: (context, index) => _buildSalaryCard(salaries[index], index),
                ),
              ),
            if (!isLoading && salaries.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'لا توجد بيانات للعرض.\nيرجى اختيار شهر ثم الضغط على "إعداد الرواتب".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
