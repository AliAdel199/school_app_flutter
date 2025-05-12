
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showDeleteStudentDialog(BuildContext context, Map<String, dynamic> student, VoidCallback onDeleted) async {
  final supabase = Supabase.instance.client;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل أنت متأكد من حذف الطالب: ${student['full_name']}؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('حذف'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            try {
              await supabase
                  .from('students')
                  .delete()
                  .eq('id', student['id']);

              Navigator.pop(context); // إغلاق الحوار
              onDeleted(); // إعادة تحميل البيانات
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الطالب بنجاح')),
              );
            } catch (e) {
              debugPrint('Delete error: \n$e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فشل في الحذف: \n$e')),
              );
            }
          },
        ),
      ],
    ),
  );
}
