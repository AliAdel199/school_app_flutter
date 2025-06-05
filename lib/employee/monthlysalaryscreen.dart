import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String searchQuery = '';
  List<TextEditingController> extraDeductionControllers = [];
List<TextEditingController> extraAllowanceControllers = [];
List<TextEditingController> notesControllers = [];

Future<void> copyFromPreviousMonth() async {
  final previousMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
  final salaryMonth = DateFormat('yyyy-MM-01').format(selectedMonth);
  final prevSalaryMonth = DateFormat('yyyy-MM-01').format(previousMonth);

  try {
    final previousSalaries = await supabase
        .from('employee_salaries')
        .select()
        .eq('salary_month', prevSalaryMonth);

    if (previousSalaries == null || (previousSalaries is List && previousSalaries.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رواتب في الشهر السابق')),
      );
      return;
    }

    for (final salary in previousSalaries) {
      final employeeId = salary['employee_id'];

      final existing = await supabase
          .from('employee_salaries')
          .select('id')
          .eq('salary_month', salaryMonth)
          .eq('employee_id', employeeId)
          .maybeSingle();

      if (existing == null) {
        final copiedSalary = Map<String, dynamic>.from(salary);
        copiedSalary.remove('id');
        copiedSalary['salary_month'] = salaryMonth;
        await supabase.from('employee_salaries').insert(copiedSalary);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ من الشهر السابق')),
    );
    await generateSalaries();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل النسخ من الشهر السابق: $e')),
    );
  }
}


  Future<void> generateSalaries() async {
    setState(() => isLoading = true);
extraDeductionControllers.clear();
extraAllowanceControllers.clear();      
notesControllers.clear();
    try {
      final salaryMonth = DateFormat('yyyy-MM-01').format(selectedMonth);
      final existingSalaries = await supabase
          .from('employee_salaries')
          .select()
          .eq('salary_month', salaryMonth);

      final employeeResponse = await supabase.from('employees').select();
      final List employees = employeeResponse;

      final List<Map<String, dynamic>> newSalaries = [];

      for (final emp in employees) {
        final employeeId = emp['id'];
        final baseSalary = (emp['base_salary'] as num?)?.toDouble() ?? 0.0;
        final fullName = emp['full_name'] ?? '';

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

        final existing = (existingSalaries as List).firstWhere(
          (e) => e['employee_id'] == employeeId,
          orElse: () => <String, dynamic>{},
        );

        newSalaries.add({
          'employee_id': employeeId,
          'full_name': fullName,
          'base_salary': existing['base_salary'] ?? baseSalary,
          'total_allowances': existing['total_allowances'] ?? totalAllowances,
          'total_deductions': existing['total_deductions'] ?? totalDeductions,
          'extra_deduction': existing['extra_deduction'] ?? 0.0,
          'extra_allowance': existing['extra_allowance'] ?? 0.0,
          'notes': existing['notes'] ?? '',
          'isExisting': existing.isNotEmpty,
        });
        //         extraDeductionControllers.add(TextEditingController(text: newSalaries.last['extra_deduction'].toString()));
// extraAllowanceControllers.add(TextEditingController(text: newSalaries.last['extra_allowance'].toString()));
// notesControllers.add(TextEditingController(text: newSalaries.last['notes']));
        extraDeductionControllers.add(TextEditingController(text: newSalaries.last['extra_deduction'].toString()));
        extraAllowanceControllers.add(TextEditingController(text: newSalaries.last['extra_allowance'].toString()));
        notesControllers.add(TextEditingController(text: newSalaries.last['notes']));
      }

      setState(() => salaries = newSalaries);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إعداد الرواتب: $e')),
        );
      }
      debugPrint('فشل إعداد الرواتب: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

//   Future<void> generateSalaries() async {
//     setState(() => isLoading = true);

//     try {
//       final salaryMonth = DateFormat('yyyy-MM-01').format(selectedMonth);
//       final existingSalaries = await supabase
//           .from('employee_salaries')
//           .select()
//           .eq('salary_month', salaryMonth);

//       final employeeResponse = await supabase.from('employees').select();
//       final List employees = employeeResponse;

//       final List<Map<String, dynamic>> newSalaries = [];

//       for (final emp in employees) {
//         final employeeId = emp['id'];
//         final baseSalary = (emp['base_salary'] as num?)?.toDouble() ?? 0.0;
//         final fullName = emp['full_name'] ?? '';

//         final allowanceData = await supabase
//             .from('employee_allowances')
//             .select('amount')
//             .eq('employee_id', employeeId);

//         final totalAllowances = (allowanceData as List)
//             .fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());

//         final deductionData = await supabase
//             .from('employee_deductions')
//             .select('amount')
//             .eq('employee_id', employeeId);

//         final totalDeductions = (deductionData as List)
//             .fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());

//         final existing = (existingSalaries as List).firstWhere(
//           (e) => e['employee_id'] == employeeId,
//           orElse: () => <String, dynamic>{},
//         );

//         newSalaries.add({
//           'employee_id': employeeId,
//           'full_name': fullName,
//           'base_salary': existing.containsKey('base_salary') ? existing['base_salary'] : baseSalary,
//           'total_allowances': existing.containsKey('total_allowances') ? existing['total_allowances'] : totalAllowances,
//           'total_deductions': existing.containsKey('total_deductions') ? existing['total_deductions'] : totalDeductions,
//           'extra_deduction': existing.containsKey('extra_deduction') ? existing['extra_deduction'] : 0.0,
//           'extra_allowance': existing.containsKey('extra_allowance') ? existing['extra_allowance'] : 0.0,
//           'notes': existing.containsKey('notes') ? existing['notes'] : '',
//           'isExisting': existing.isNotEmpty,
//         });
//         extraDeductionControllers.add(TextEditingController(text: newSalaries.last['extra_deduction'].toString()));
// extraAllowanceControllers.add(TextEditingController(text: newSalaries.last['extra_allowance'].toString()));
// notesControllers.add(TextEditingController(text: newSalaries.last['notes']));
//       }

//       setState(() => salaries = newSalaries);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('فشل إعداد الرواتب: $e')),
//         );
//       }
//       debugPrint('فشل إعداد الرواتب: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

  double calculateNetSalary(Map<String, dynamic> salary) {
    final net = (salary['base_salary'] ?? 0) +
        (salary['total_allowances'] ?? 0) +
        (salary['extra_allowance'] ?? 0) -
        (salary['total_deductions'] ?? 0) -
        (salary['extra_deduction'] ?? 0);
    return net;
  }
  Future<List<Map<String, dynamic>>> getEmployeesWithoutSalaryForMonth() async {
  final salaryMonth = DateFormat('yyyy-MM-01').format(selectedMonth);

  final employees = await supabase.from('employees').select('id, full_name');
  final salaries = await supabase
      .from('employee_salaries')
      .select('employee_id')
      .eq('salary_month', salaryMonth);

  final paidEmployeeIds = (salaries as List).map((s) => s['employee_id']).toSet();

  return (employees as List)
      .where((emp) => !paidEmployeeIds.contains(emp['id']))
      .map((e) => {'id': e['id'], 'full_name': e['full_name']})
      .toList();
}


  Future<void> saveSalaryByEmployeeId(String employeeId) async {
    final index = salaries.indexWhere((s) => s['employee_id'] == employeeId);
    if (index == -1) return;

    final data = salaries[index];
    final net = calculateNetSalary(data);
    final salaryMonth = DateFormat('yyyy-MM-01').format(selectedMonth);

    try {
      final existing = await supabase
          .from('employee_salaries')
          .select('id')
          .eq('salary_month', salaryMonth)
          .eq('employee_id', data['employee_id'])
          .maybeSingle();

      if (existing != null) {
        await supabase.from('employee_salaries').update({
          'base_salary': data['base_salary'],
          'total_allowances': data['total_allowances'],
          'total_deductions': data['total_deductions'],
          'extra_deduction': data['extra_deduction'],
          'extra_allowance': data['extra_allowance'],
          'notes': data['notes'],
          'net_salary': net,
        }).eq('id', existing['id']);
      } else {
        await supabase.from('employee_salaries').insert({
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
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الراتب')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حفظ الراتب: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSalaries = salaries.where((s) {
      final name = (s['full_name'] ?? '').toLowerCase();
      return name.contains(searchQuery);
    }).toList();

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                  child: DropdownButton<DateTime>(
                    value: selectedMonth,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    items: List.generate(12, (index) {
                    final date = DateTime(DateTime.now().year, index + 1);
                    return DropdownMenuItem(
                      value: date,
                      child: Text(
                      DateFormat('MMMM yyyy', 'ar').format(date),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                    }),
                    onChanged: (val) => setState(() {
                    selectedMonth = val ?? DateTime.now();
                    salaries.clear();
                    extraDeductionControllers.clear();
                    extraAllowanceControllers.clear();
                    notesControllers.clear();
                    generateSalaries();
                    }),
                  ),
                  ),
                ),
                const Spacer(),
                // SizedBox(
                //   height: 40,
                //   width: 150,
                //   child: ElevatedButton(
                //     onPressed: isLoading ? null : generateSalaries,
                //     child: const Text('إعداد الرواتب'),
                //   ),
                // ),
                
                SizedBox(
                  height: 40,
                  width: 200,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isLoading ? null : copyFromPreviousMonth,
                    child: const Text('نسخ من الشهر السابق'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'ابحث عن اسم الموظف',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!isLoading && salaries.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSalaries.length,
                  itemBuilder: (context, index) {
                    final s = filteredSalaries[index];
                    final realIndex = salaries.indexWhere((e) => e['employee_id'] == s['employee_id']);
                    final real = salaries[realIndex];

                    return Card(
                      color: real['isExisting'] == true ? Colors.green[50] : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              real['full_name'] + (real['isExisting'] == true ? ' ✅' : ''),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('الراتب الاسمي: ${real['base_salary']}'),
                                const SizedBox(width: 16),
                                Text('المخصصات: ${real['total_allowances']}'),
                                const SizedBox(width: 16),
                                Text('الاستقطاعات: ${real['total_deductions']}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller:  extraDeductionControllers[realIndex],
                                    decoration: const InputDecoration(labelText: 'خصم إضافي'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => real['extra_deduction'] = double.tryParse(val) ?? 0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller:  extraAllowanceControllers[realIndex],
                                    decoration: const InputDecoration(labelText: 'مكافأة'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) => real['extra_allowance'] = double.tryParse(val) ?? 0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              // initialValue: real['notes'],4
                              controller:  notesControllers[realIndex],
                              decoration: const InputDecoration(labelText: 'ملاحظات'),
                              onChanged: (val) => real['notes'] = val,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'الصافي: ${calculateNetSalary(real).toStringAsFixed(2)} د.ع',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => saveSalaryByEmployeeId(real['employee_id']),
                                      child: const Text('حفظ'),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
