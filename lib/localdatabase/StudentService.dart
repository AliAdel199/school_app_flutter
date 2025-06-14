import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/dialogs/payment_dialog_ui.dart';
import 'package:school_app_flutter/localdatabase/student.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentService {
  final Isar isar;

  StudentService(this.isar);

    // إنشاء سجل حالة القسط إذا لم يكن موجودًا
  Future<String?> createFeeStatusIfNotExists({
    required String studentId,
    required String academicYear,
  }) async {
    final supabase = Supabase.instance.client;

    // تحقق إذا كان هناك سجل مسبق
    final existing = await supabase
        .from('student_fee_status')
        .select('id')
        .eq('student_id', studentId)
        .eq('academic_year', academicYear)
        .maybeSingle();

    if (existing != null) return existing['id']?.toString(); // موجود مسبقًا

    // جلب الصف الخاص بالطالب
    final student = await supabase
        .from('students')
        .select('class_id')
        .eq('id', studentId)
        .maybeSingle();

    final classId = student?['class_id'];

    if (classId == null) throw Exception('الطالب غير مرتبط بصف.');

    // جلب القسط السنوي للصف
    final classData = await supabase
        .from('classes')
        .select('annual_fee')
        .eq('id', classId)
        .maybeSingle();

    final fee = (classData?['annual_fee'] ?? 0) as num;

    // إدراج سجل جديد
    final insertResult = await supabase.from('student_fee_status').insert({
      'student_id': studentId,
      'academic_year': academicYear,
      'annual_fee': fee.toDouble(),
      'paid_amount': 0,
      'due_amount': fee.toDouble(),
      'next_due_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    }).select('id').single();

    return insertResult['id']?.toString();
  }


  // إضافة طالب
Future<void> addStudent({required Student student,context}) async {
  try {
    // Initialize supabase client
    final supabase = Supabase.instance.client;
    // التأكد من أن الطالب لديه ID من الخادم
    final user = supabase.auth.currentUser;
    final profile = await supabase.from('profiles').select('school_id').eq('id', user!.id).single();

      final studentData = {
        'full_name': student.fullName,
        'gender': student.gender,
        'phone': student.phone,
        'birth_date': student.birthDate,
        'address': student.address,
        'status': student.status,
        'email': student.email, 
        'class_id': student.classId,
        'school_id': profile['school_id'],
        'national_id': student.nationalId,
        'annual_fee': student.annualFee ?? 0, // تم التعليق لأن العمود غير موجود في قاعدة البيانات
        // 'current_fee_status_id': student.currentFeeStatusId, // لا تعيّن "0" إذا لم تكن موجودة
        'registration_year': student.registrationYear,
        'parent_name': student.parentName,  
        'parent_phone': student.parentPhone,
        // 'created_at': student.createdAt.toIso8601String(),
      };
      
       final insertResult = await supabase.from('students').insert(studentData).select('id').single();
        final studentId = insertResult['id'];
        student.serverId = studentId;
   
   final feeStatusId = await createFeeStatusIfNotExists(
          studentId: studentId,
          academicYear: student.registrationYear ?? DateTime.now().year.toString(),
        );
        print('Created/Found fee status ID: $feeStatusId');

        // تحديث حقل current_fee_status_id في جدول الطلاب على supabase
       await supabase.from('students').update({
          'current_fee_status_id': feeStatusId,
        }).eq('id', studentId);
           // Ensure the type matches the Student model (convert to int if needed)
           student.currentFeeStatusId = feeStatusId.toString();

         await isar.writeTxn(() async {
          student.id = await isar.students.put(student);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
          content: Text('تم إضافة الطالب بنجاح: ${student.fullName} (ID: ${student.currentFeeStatusId})'),
        ) 
        );
   
       print('تم إضافة الطالب بنجاح: ${student.fullName} (ID: ${student.id})'); 
  
    } catch (e) {
      print("Error adding student: $e");
      SnackBar snackBar = SnackBar(
        content: Text('خطأ في إضافة الطالب: ${student.fullName}'),
      );
    }
  
  }

  // تحديث طالب
  Future<void> updateStudent({required Student student, context}) async {
    try {
      final supabase = Supabase.instance.client;



      // تحديث بيانات الطالب في Supabase
      final updateData = {
        'full_name': student.fullName,
        'gender': student.gender,
        'phone': student.phone,
        'birth_date': student.birthDate,
        'address': student.address,
        'status': student.status,
        'email': student.email,
        'class_id': student.classId,
        'national_id': student.nationalId,
        'registration_year': student.registrationYear,
        'parent_name': student.parentName,
        'parent_phone': student.parentPhone,
      };
      // الحصول على serverId من isar إذا لم يكن موجودًا في الكائن


      // تحديث بيانات الطالب في supabase
      await supabase.from('students').update(updateData).eq('id', student.serverId);

      // تحديث بيانات الطالب محليًا في isar
      await isar.writeTxn(() async {
        await isar.students.put(student);
      });

print('تم تحديث بيانات الطالب بنجاح: ${student.fullName} (ID: ${student.id})');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث بيانات الطالب بنجاح: ${student.fullName}'),
        ),
      );
      // Use logging instead of print
      // debugPrint('تم تحديث بيانات الطالب بنجاح: ${student.fullName} (ID: ${student.id})');
    } catch (e) {
      // Use logging instead of print
      debugPrint("Error updating student: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث بيانات الطالب: ${student.fullName}'),
        ),
      );
    }
  }

  // حذف طالب
  Future<void> deleteStudent(int id) async {
    await isar.writeTxn(() async {
      await isar.students.delete(id);
    });
  }

  // جلب كل الطلاب
  Future<List<Student>> getAllStudents() async {
    return await isar.students.where().findAll();
  }

  // جلب طالب حسب ID
  Future<Student?> getStudentById(int id) async {
    return await isar.students.get(id);
  }

  // حذف كل الطلاب
  Future<void> clearAllStudents() async {
    await isar.writeTxn(() async {
      await isar.students.clear();
    });
  }
}
