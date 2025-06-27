import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '/localdatabase/user.dart';
import '../../main.dart';
import 'auth_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    users = await isar.users.where().findAll();
    setState(() {});
  }

  Future<void> showUserDialog({User? user}) async {
    final usernameController = TextEditingController(text: user?.username);
    final emailController = TextEditingController(text: user?.email);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          user == null ? 'إضافة مستخدم' : 'تعديل مستخدم',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (val) => user == null && (val == null || val.length < 4)
                    ? 'كلمة المرور مطلوبة (4 أحرف على الأقل)' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              if (user == null) {
                await registerUser(
                  usernameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              } else {
                user.username = usernameController.text.trim();
                user.email = emailController.text.trim();
                if (passwordController.text.trim().isNotEmpty) {
                  user.password = hashPassword(passwordController.text.trim());
                }
                await isar.writeTxn(() async {
                  await isar.users.put(user);
                });
              }

              Navigator.pop(context);
              fetchUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(user == null ? 'تمت الإضافة' : 'تم التحديث')),
              );
            },
            child: Text(user == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(User user) async {
    await isar.writeTxn(() async {
      await isar.users.delete(user.id);
    });
    fetchUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف المستخدم')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: users.isEmpty
            ? const Center(child: Text('لا يوجد مستخدمون'))
            : ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      title: Text(
                        user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => showUserDialog(user: user),
                            tooltip: 'تعديل',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteUser(user),
                            tooltip: 'حذف',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserDialog(),
        backgroundColor:Colors.blue.shade100,
        child: const Icon(Icons.add),
        tooltip: 'إضافة مستخدم',
      ),
    );
  }
}
