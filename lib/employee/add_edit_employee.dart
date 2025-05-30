import 'package:flutter/material.dart';

import '../dialogs/payment_dialog_ui.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;
  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _salaryController = TextEditingController();

  List<Map<String, dynamic>> allowances = [];
  List<Map<String, dynamic>> deductions = [];

Future<void> saveEmployeeData() async {
  try {
    final userId = supabase.auth.currentUser!.id;

    // جلب school_id من جدول profiles
    final profileResponse = await supabase
        .from('profiles')
        .select('school_id')
        .eq('id', userId)
        .single();

    if (profileResponse == null || profileResponse['school_id'] == null) {
      throw Exception('لم يتم العثور على معرف المدرسة.');
    }

    final schoolId = profileResponse['school_id'];

    final employeeData = {
      'full_name': _nameController.text,
      'school_id': schoolId,
      'email': supabase.auth.currentUser!.email,
      'department': 'General',
      'job_title': 'Employee',
      'phone': _phoneController.text,
      'status': 'active',
      'base_salary': double.tryParse(_salaryController.text) ?? 0,
    };

    dynamic employeeId = widget.employee != null
        ? widget.employee!['id']
        : null;

    if (employeeId == null) {
      // إدخال موظف جديد
      final insertResponse = await supabase
          .from('employees')
          .insert(employeeData)
          .select()
          .single();

      if (insertResponse == null || insertResponse['id'] == null) {
        throw Exception('فشل في إنشاء الموظف.');
      }

      employeeId = insertResponse['id'];
    } else {
      // تحديث موظف موجود
      final updateResponse = await supabase
          .from('employees')
          .update(employeeData)
          .eq('id', employeeId)
          .select()
          .single();

      if (updateResponse == null || updateResponse['id'] == null) {
        throw Exception('فشل في تحديث بيانات الموظف.');
      }
    }

    // حذف المخصصات القديمة
    await supabase
        .from('employee_allowances')
        .delete()
        .eq('employee_id', employeeId);

    // إدخال المخصصات الجديدة
    for (final allowance in allowances) {
      final title = allowance['title'] ?? allowance['name'];
      if ((title as String).trim().isNotEmpty) {
        await supabase.from('employee_allowances').insert({
          'employee_id': employeeId,
          'title': title,
          'amount': allowance['amount'] is String
              ? double.tryParse(allowance['amount']) ?? 0
              : allowance['amount'],
        });
      }
    }

    // حذف الاستقطاعات القديمة
    await supabase
        .from('employee_deductions')
        .delete()
        .eq('employee_id', employeeId);

    // إدخال الاستقطاعات الجديدة
    for (final deduction in deductions) {
      final title = deduction['title'] ?? deduction['name'];
      if ((title as String).trim().isNotEmpty) {
        await supabase.from('employee_deductions').insert({
          'employee_id': employeeId,
          'title': title,
          'amount': deduction['amount'] is String
              ? double.tryParse(deduction['amount']) ?? 0
              : deduction['amount'],
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ بيانات الموظف بنجاح')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
    );
    print('حدث خطأ أثناء الحفظ: $e');
  }
}


  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!['full_name'] ?? '';
      _nationalIdController.text = widget.employee!['department'] ?? '';
      _phoneController.text = widget.employee!['phone'] ?? '';
      _addressController.text = widget.employee!['job_title'] ?? '';
      _salaryController.text = widget.employee!['base_salary']?.toString() ?? '';
   fetchAllowances() ;
      fetchDeductions();
    } else {
      allowances = [{'title': '', 'amount': ''}];
      deductions = [{'title': '', 'amount': ''}];
    }
  }

  void _addAllowanceField() {
    setState(() => allowances.add({'title': '', 'amount': ''}));
  }

  void _addDeductionField() {
    setState(() => deductions.add({'title': '', 'amount': ''}));
  }
Future<void> fetchAllowances() async {
  try {
    final response = await supabase
        .from('employee_allowances')
        .select('title, amount')
        .eq('employee_id', widget.employee!['id']);

    setState(() {
      allowances = (response as List)
          .map((e) => {
                'title': e['title'],
                'amount': (e['amount'] as num).toDouble(),
              })
          .toList();
    });
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل تحميل المخصصات: $error')),
    );
  }
}

Future<void> fetchDeductions() async {
  try {
    final response = await supabase
        .from('employee_deductions')
        .select('title, amount')
        .eq('employee_id', widget.employee!['id']);

    setState(() {
      deductions = (response as List)
          .map((e) => {
                'title': e['title'],
                'amount': (e['amount'] as num).toDouble(),
              })
          .toList();
    });
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل تحميل الاستقطاعات: $error')),
    );
  }
}


  Widget _buildAllowanceFields() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text('المخصصات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _addAllowanceField,
                  tooltip: 'إضافة مخصص',
                )
              ],
            ),
            const Divider(),
            ...allowances.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item['title'],
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) => allowances[i]['title'] = val,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: item['amount'].toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'القيمة',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) => allowances[i]['amount'] = double.tryParse(val) ?? 0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => setState(() => allowances.removeAt(i)),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionFields() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text('الاستقطاعات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _addDeductionField,
                  tooltip: 'إضافة استقطاع',
                )
              ],
            ),
            const Divider(),
            ...deductions.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item['title'],
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) => deductions[i]['title'] = val,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: item['amount'].toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'القيمة',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) => deductions[i]['amount'] = double.tryParse(val) ?? 0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => setState(() => deductions.removeAt(i)),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.employee == null ? 'إضافة موظف' : 'تعديل موظف')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(controller: _nameController, label: 'الاسم الكامل'),
              _buildTextField(controller: _nationalIdController, label: 'الرقم الوطني'),
              _buildTextField(controller: _phoneController, label: 'رقم الهاتف'),
              _buildTextField(controller: _addressController, label: 'العنوان'),
              _buildTextField(
                  controller: _salaryController,
                  label: 'الراتب الأساسي',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _buildAllowanceFields(),
              _buildDeductionFields(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveEmployeeData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم الحفظ مؤقتًا')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
