import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/user.dart';
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
        title: Text(user == null ? 'إضافة مستخدم' : 'تعديل مستخدم'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
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
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showUserDialog(user: user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () => deleteUser(user),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
