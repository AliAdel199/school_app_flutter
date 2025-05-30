import 'package:flutter/material.dart';
import 'package:school_app_flutter/employee/add_edit_employee.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<dynamic>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = fetchEmployees();
  }

  Future<List<dynamic>> fetchEmployees() async {
    final List<dynamic> response = await supabase
        .from('employees')
        .select()
        .limit(100)
        .order('id');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الموظفين')),
      body: FutureBuilder<List<dynamic>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          } else {
            final employees = snapshot.data!;
            if (employees.isEmpty) {
              return const Center(child: Text('لا يوجد موظفين'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: employees.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        (employee['full_name'] ?? ' ')[0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(employee['full_name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الوظيفة: ${employee['job_title'] ?? '-'}'),
                        Text('القسم: ${employee['department'] ?? '-'}'),
                        Text('البريد الإلكتروني: ${employee['email'] ?? '-'}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(employee['status'] ?? ''),
                      backgroundColor: (employee['status'] == 'نشط')
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                    onTap: () async {
                      // الانتقال لصفحة التعديل وتمرير بيانات الموظف
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditEmployeeScreen(
                            employee: employee,
                          )));
                      
                      if (updated == true) {
                        setState(() {
                          _employeesFuture = fetchEmployees();
                        });
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // يمكنك إضافة صفحة إضافة موظف جديد هنا
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة موظف جديد',
      ),
    );
  }
}

class EmployeeEditScreen extends StatefulWidget {
  final Map employee;
  const EmployeeEditScreen({super.key, required this.employee});

  @override
  State<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  late TextEditingController nameController;
  late TextEditingController jobController;
  late TextEditingController departmentController;
  late TextEditingController emailController;
  String status = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.employee['full_name']);
    jobController = TextEditingController(text: widget.employee['job_title']);
    departmentController = TextEditingController(text: widget.employee['department']);
    emailController = TextEditingController(text: widget.employee['email']);
    status = widget.employee['status'] ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    jobController.dispose();
    departmentController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final supabase = Supabase.instance.client;
    await supabase.from('employees').update({
      'full_name': nameController.text,
      'job_title': jobController.text,
      'department': departmentController.text,
      'email': emailController.text,
      'status': status,
    }).eq('id', widget.employee['id']);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل بيانات الموظف')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
            ),
            TextField(
              controller: jobController,
              decoration: const InputDecoration(labelText: 'الوظيفة'),
            ),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: 'القسم'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(labelText: 'الحالة'),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('نشط')),
                DropdownMenuItem(value: 'inactive', child: Text('غير نشط')),
              ],
              onChanged: (val) => setState(() => status = val ?? ''),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }
}