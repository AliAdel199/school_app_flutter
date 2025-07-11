import 'package:isar/isar.dart';

import '../helpers/simple_auto_discount_processor.dart';
import '../localdatabase/student.dart';
import '../main.dart';

/// مثال على كيفية استخدام النظام المحسن لتحديد الأشقاء
class SiblingAccuracyExample {
  
  /// مثال 1: اختبار دقة تحديد الأشقاء
  static Future<void> testSiblingAccuracy() async {
    final processor = AutoDiscountProcessor(isar);
    
    // تشغيل اختبار الدقة
    await processor.testSiblingDetection();
    
    // الحصول على الإحصائيات
    final stats = await processor.getSiblingStatistics();
    
    print('=== إحصائيات الأشقاء ===');
    print('إجمالي الطلاب: ${stats['totalStudents']}');
    print('الطلاب الذين لديهم أشقاء: ${stats['studentsWithSiblings']}');
    print('نسبة الطلاب الذين لديهم أشقاء: ${stats['percentageWithSiblings']}%');
    print('أكبر مجموعة أشقاء: ${stats['largestSiblingGroup']} طلاب');
  }
  
  /// مثال 2: إصلاح مشاكل تحديد الأشقاء
  static Future<void> fixSiblingIssues() async {
    final processor = AutoDiscountProcessor(isar);
    
    // تحديد وإصلاح المشاكل
    final result = await processor.identifyAndFixSiblingIssues();
    
    print('=== نتائج الإصلاح ===');
    print('إجمالي المشاكل: ${result['totalIssues']}');
    print('المشاكل المحلولة: ${result['fixedIssues']}');
    print('المشاكل المتبقية: ${result['remainingIssues']}');
    
    // عرض المشاكل المتبقية
    if (result['remainingIssues'] > 0) {
      print('\n=== المشاكل المتبقية ===');
      final issues = result['issues'] as List<Map<String, dynamic>>;
      
      for (var issue in issues) {
        if (issue['fixed'] != true) {
          print('--- مشكلة في مجموعة: ${issue['parentName']} ---');
          print('الطلاب: ${issue['student1']} و ${issue['student2']}');
          
          if (issue['missingData'] != null) {
            print('بيانات مفقودة: ${issue['missingData']}');
          }
          
          if (issue['conflictingData'] != null) {
            print('بيانات متضاربة: ${issue['conflictingData']}');
          }
          
          print('');
        }
      }
    }
  }
  
  /// مثال 3: فحص طالب محدد
  static Future<void> checkSpecificStudent(int studentId) async {
    final processor = AutoDiscountProcessor(isar);
    
    // جلب الطالب
    final student = await isar.students.get(studentId);
    if (student == null) {
      print('الطالب غير موجود');
      return;
    }
    
    // البحث عن الأشقاء
    final siblings = await processor.findSiblings(student);
    
    print('=== فحص الطالب: ${student.fullName} ===');
    print('اسم الوالد: ${student.parentName}');
    print('العنوان: ${student.address ?? 'غير متوفر'}');
    print('رقم الهاتف: ${student.parentPhone ?? 'غير متوفر'}');
    print('تاريخ الميلاد: ${student.birthDate?.toString().split(' ')[0] ?? 'غير متوفر'}');
    
    if (siblings.isEmpty) {
      print('لا يوجد أشقاء للطالب');
    } else {
      print('الأشقاء (${siblings.length}):');
      for (var sibling in siblings) {
        print('  - ${sibling.fullName}');
      }
      
      // حساب نسبة الخصم
      final discountPercentage = processor.calculateSiblingDiscountPercentage(student, siblings);
      print('نسبة خصم الأشقاء: $discountPercentage%');
    }
  }
  
  /// مثال 4: إضافة طالب جديد مع فحص دقة البيانات
  static Future<void> addStudentWithSiblingCheck({
    required String fullName,
    required String parentName,
    String? address,
    String? parentPhone,
    DateTime? birthDate,
  }) async {
    final processor = AutoDiscountProcessor(isar);
    
    // إنشاء طالب جديد
    final newStudent = Student()
      ..fullName = fullName
      ..parentName = parentName
      ..address = address
      ..parentPhone = parentPhone
      ..birthDate = birthDate;
    
    // حفظ الطالب
    await isar.writeTxn(() async {
      await isar.students.put(newStudent);
    });
    
    print('=== تم إضافة الطالب: $fullName ===');
    
    // فحص الأشقاء المحتملين
    final siblings = await processor.findSiblings(newStudent);
    
    if (siblings.isNotEmpty) {
      print('تم العثور على أشقاء محتملين:');
      for (var sibling in siblings) {
        print('  - ${sibling.fullName}');
      }
      
      // تحذير إذا كانت البيانات ناقصة
      if (address == null || address.isEmpty) {
        print('⚠ تحذير: العنوان مفقود. هذا قد يؤثر على دقة تحديد الأشقاء.');
      }
      
      if (parentPhone == null || parentPhone.isEmpty) {
        print('⚠ تحذير: رقم هاتف الوالد مفقود. هذا قد يؤثر على دقة تحديد الأشقاء.');
      }
      
      if (birthDate == null) {
        print('⚠ تحذير: تاريخ الميلاد مفقود. هذا قد يؤثر على دقة تحديد الأشقاء.');
      }
    } else {
      print('لا يوجد أشقاء لهذا الطالب');
    }
  }
  
  /// مثال 5: تحديث بيانات طالب لتحسين دقة تحديد الأشقاء
  static Future<void> updateStudentForBetterAccuracy({
    required int studentId,
    String? newAddress,
    String? newParentPhone,
    DateTime? newBirthDate,
  }) async {
    final processor = AutoDiscountProcessor(isar);
    
    // جلب الطالب
    final student = await isar.students.get(studentId);
    if (student == null) {
      print('الطالب غير موجود');
      return;
    }
    
    print('=== تحديث بيانات الطالب: ${student.fullName} ===');
    
    // الأشقاء قبل التحديث
    final siblingsBeforeUpdate = await processor.findSiblings(student);
    print('الأشقاء قبل التحديث: ${siblingsBeforeUpdate.length}');
    
    // تحديث البيانات
    bool updated = false;
    
    if (newAddress != null) {
      student.address = newAddress;
      updated = true;
      print('تم تحديث العنوان: $newAddress');
    }
    
    if (newParentPhone != null) {
      student.parentPhone = newParentPhone;
      updated = true;
      print('تم تحديث رقم الهاتف: $newParentPhone');
    }
    
    if (newBirthDate != null) {
      student.birthDate = newBirthDate;
      updated = true;
      print('تم تحديث تاريخ الميلاد: ${newBirthDate.toString().split(' ')[0]}');
    }
    
    if (updated) {
      // حفظ التحديثات
      await isar.writeTxn(() async {
        await isar.students.put(student);
      });
      
      // الأشقاء بعد التحديث
      final siblingsAfterUpdate = await processor.findSiblings(student);
      print('الأشقاء بعد التحديث: ${siblingsAfterUpdate.length}');
      
      if (siblingsAfterUpdate.length != siblingsBeforeUpdate.length) {
        print('✅ تحسن في دقة تحديد الأشقاء!');
      } else {
        print('ℹ️ لم يتغير عدد الأشقاء');
      }
    } else {
      print('لم يتم تحديث أي بيانات');
    }
  }
  
  /// مثال 6: تقرير شامل عن حالة نظام الأشقاء
  static Future<void> generateSiblingSystemReport() async {
    final processor = AutoDiscountProcessor(isar);
    
    print('=== تقرير شامل عن نظام الأشقاء ===');
    print('تاريخ التقرير: ${DateTime.now()}');
    print('');
    
    // 1. الإحصائيات العامة
    final stats = await processor.getSiblingStatistics();
    print('--- الإحصائيات العامة ---');
    print('إجمالي الطلاب: ${stats['totalStudents']}');
    print('الطلاب الذين لديهم أشقاء: ${stats['studentsWithSiblings']}');
    print('نسبة الطلاب الذين لديهم أشقاء: ${stats['percentageWithSiblings']}%');
    print('عدد مجموعات الآباء: ${stats['parentGroups']}');
    print('عدد مجموعات الأشقاء: ${stats['siblingGroups']}');
    print('أكبر مجموعة أشقاء: ${stats['largestSiblingGroup']} طلاب');
    print('');
    
    // 2. فحص المشاكل
    print('--- فحص المشاكل ---');
    final issues = await processor.identifyAndFixSiblingIssues();
    print('إجمالي المشاكل المكتشفة: ${issues['totalIssues']}');
    print('المشاكل المحلولة تلقائياً: ${issues['fixedIssues']}');
    print('المشاكل المتبقية: ${issues['remainingIssues']}');
    
    if (issues['remainingIssues'] > 0) {
      final accuracy = ((issues['totalIssues'] - issues['remainingIssues']) / issues['totalIssues'] * 100);
      print('نسبة دقة النظام: ${accuracy.toStringAsFixed(1)}%');
    } else {
      print('نسبة دقة النظام: 100%');
    }
    
    print('');
    
    // 3. توصيات
    print('--- التوصيات ---');
    if (issues['remainingIssues'] > 0) {
      print('• راجع المشاكل المتبقية يدوياً');
      print('• أضف البيانات المفقودة (العنوان، رقم الهاتف، تاريخ الميلاد)');
      print('• صحح البيانات المتضاربة');
    }
    
    final incompleteDataCount = await _countIncompleteData();
    if (incompleteDataCount > 0) {
      print('• أكمل البيانات الناقصة لـ $incompleteDataCount طالب');
    }
    
    print('• شغل اختبار الدقة بانتظام');
    print('• راجع الإحصائيات شهرياً');
    
    print('');
    print('=== انتهى التقرير ===');
  }
  
  /// عدد الطلاب الذين لديهم بيانات ناقصة
  static Future<int> _countIncompleteData() async {
    final students = await isar.students.where().findAll();
    
    int count = 0;
    for (var student in students) {
      if (student.address == null || student.address!.isEmpty ||
          student.parentPhone == null || student.parentPhone!.isEmpty ||
          student.birthDate == null) {
        count++;
      }
    }
    
    return count;
  }
}
