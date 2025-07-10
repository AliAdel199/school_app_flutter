import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_discount.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/student_payment.dart';
import '../localdatabase/discount_type.dart';

/// معالج الخصومات التلقائية المبسط
class AutoDiscountProcessor {
  final Isar isar;
  
  AutoDiscountProcessor(this.isar);
  
  /// معالجة خصومات الأشقاء للطالب
  Future<StudentDiscount?> processSiblingDiscount(Student student, String academicYear) async {
    debugPrint('معالجة خصم الأشقاء للطالب: ${student.fullName}');
    
    try {
      // فحص إذا كان الخصم مطبق مسبقاً
      final existingDiscount = await isar.studentDiscounts
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (existingDiscount != null) {
        debugPrint('خصم موجود مسبقاً للطالب');
        return null;
      }
      
      // البحث عن الأشقاء بناءً على اسم الوالد
      final siblings = await findSiblings(student);
      final siblingCount = siblings.length + 1; // +1 للطالب نفسه
      
      if (siblingCount < 2) {
        debugPrint('لا يوجد أشقاء للطالب');
        return null;
      }
      
      // حساب نسبة الخصم بناءً على ترتيب الطالب
      final discountPercentage = calculateSiblingDiscountPercentage(student, siblings);
      
      if (discountPercentage == 0) {
        debugPrint('لا يحق للطالب خصم أشقاء');
        return null;
      }
      
      // جلب حالة القسط
      final feeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (feeStatus == null) {
        debugPrint('لا توجد حالة قسط للطالب');
        return null;
      }
      
      // حساب مبلغ الخصم
      final discountAmount = feeStatus.annualFee * (discountPercentage / 100);
      
      // تطبيق الخصم
      return await applySiblingDiscount(student, academicYear, discountAmount, discountPercentage);
      
    } catch (e) {
      debugPrint('خطأ في معالجة خصم الأشقاء: $e');
      return null;
    }
  }
  
  /// البحث عن الأشقاء بناءً على اسم الوالد
  Future<List<Student>> findSiblings(Student student) async {
    if (student.parentName == null || student.parentName!.isEmpty) {
      return [];
    }
    
    return await isar.students
        .filter()
        .parentNameEqualTo(student.parentName!)
        .and()
        .not()
        .idEqualTo(student.id)
        .findAll();
  }
  
  /// حساب نسبة خصم الأشقاء بناءً على ترتيب الطالب
  double calculateSiblingDiscountPercentage(Student student, List<Student> siblings) {
    // ترتيب الطلاب بناءً على تاريخ الميلاد (الأكبر أولاً)
    final allSiblings = [student, ...siblings];
    allSiblings.sort((a, b) {
      if (a.birthDate == null || b.birthDate == null) {
        return 0;
      }
      return a.birthDate!.compareTo(b.birthDate!);
    });
    
    // تحديد ترتيب الطالب
    final studentIndex = allSiblings.indexWhere((s) => s.id == student.id);
    
    // تحديد نسبة الخصم
    switch (studentIndex) {
      case 0: // الطالب الأول (الأكبر)
        return 0.0; // لا خصم
      case 1: // الطالب الثاني
        return 10.0;
      case 2: // الطالب الثالث
        return 15.0;
      default: // الطالب الرابع فما فوق
        return 20.0;
    }
  }
  
  /// تطبيق خصم الأشقاء
  Future<StudentDiscount?> applySiblingDiscount(
    Student student, 
    String academicYear, 
    double discountAmount, 
    double discountPercentage
  ) async {
    try {
      // البحث عن نوع خصم الأشقاء أو إنشاؤه
      DiscountType? discountType = await isar.discountTypes
          .filter()
          .nameEqualTo('خصم الأشقاء')
          .findFirst();
      
      if (discountType == null) {
        discountType = DiscountType()
          ..name = 'خصم الأشقاء'
          ..description = 'خصم تلقائي للأشقاء في المدرسة'
          ..isActive = true;
        
        await isar.writeTxn(() async {
          await isar.discountTypes.put(discountType!);
        });
      }
      
      // إنشاء خصم الطالب
      final studentDiscount = StudentDiscount()
        ..studentId = student.id.toString()
        ..academicYear = academicYear
        ..discountType = 'خصم الأشقاء'
        ..discountValue = discountAmount
        ..isPercentage = false
        ..notes = 'خصم تلقائي للأشقاء - ${discountPercentage.toStringAsFixed(1)}%'
        ..createdAt = DateTime.now()
        ..isActive = true;
      
      await isar.writeTxn(() async {
        await isar.studentDiscounts.put(studentDiscount);
      });
      
      // تحديث حالة القسط
      await updateFeeStatusWithDiscount(student.id.toString(), academicYear, discountAmount);
      
      debugPrint('تم تطبيق خصم الأشقاء: ${discountAmount} د.ع (${discountPercentage}%)');
      return studentDiscount;
      
    } catch (e) {
      debugPrint('خطأ في تطبيق خصم الأشقاء: $e');
      return null;
    }
  }
  
  /// معالجة خصم الدفع المبكر
  Future<StudentDiscount?> processEarlyPaymentDiscount(Student student, String academicYear) async {
    debugPrint('معالجة خصم الدفع المبكر للطالب: ${student.fullName}');
    
    try {
      // فحص إذا كان الخصم مطبق مسبقاً
      final existingDiscount = await isar.studentDiscounts
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (existingDiscount != null) {
        return null;
      }
      
      // البحث عن أول دفعة للطالب
      final firstPayment = await isar.studentPayments
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .sortByPaidAt()
          .findFirst();
      
      if (firstPayment == null) {
        return null;
      }
      
      // تحديد تاريخ بداية العام الدراسي
      final yearParts = academicYear.split('-');
      final startYear = int.parse(yearParts[0]);
      final schoolStart = DateTime(startYear, 9, 1);
      
      // فحص إذا كان الدفع قبل بداية العام بـ 30 يوم
      final earlyPaymentDeadline = schoolStart.subtract(const Duration(days: 30));
      
      if (!firstPayment.paidAt.isBefore(earlyPaymentDeadline)) {
        debugPrint('الدفع ليس مبكراً بما فيه الكفاية');
        return null;
      }
      
      // جلب حالة القسط
      final feeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (feeStatus == null) {
        return null;
      }
      
      // حساب مبلغ الخصم (5% من القسط)
      final discountAmount = feeStatus.annualFee * 0.05;
      
      return await applyEarlyPaymentDiscount(student, academicYear, discountAmount);
      
    } catch (e) {
      debugPrint('خطأ في معالجة خصم الدفع المبكر: $e');
      return null;
    }
  }
  
  /// تطبيق خصم الدفع المبكر
  Future<StudentDiscount?> applyEarlyPaymentDiscount(
    Student student, 
    String academicYear, 
    double discountAmount
  ) async {
    try {
      // البحث عن نوع خصم الدفع المبكر أو إنشاؤه
      DiscountType? discountType = await isar.discountTypes
          .filter()
          .nameEqualTo('خصم الدفع المبكر')
          .findFirst();
      
      if (discountType == null) {
        discountType = DiscountType()
          ..name = 'خصم الدفع المبكر'
          ..description = 'خصم للطلاب الذين يدفعون مبكراً'
          ..isActive = true;
        
        await isar.writeTxn(() async {
          await isar.discountTypes.put(discountType!);
        });
      }
      
      // إنشاء خصم الطالب
      final studentDiscount = StudentDiscount()
        ..studentId = student.id.toString()
        ..academicYear = academicYear
        ..discountType = 'خصم الدفع المبكر'
        ..discountValue = discountAmount
        ..isPercentage = false
        ..notes = 'خصم تلقائي للدفع المبكر - 5%'
        ..createdAt = DateTime.now()
        ..isActive = true;
      
      await isar.writeTxn(() async {
        await isar.studentDiscounts.put(studentDiscount);
      });
      
      // تحديث حالة القسط
      await updateFeeStatusWithDiscount(student.id.toString(), academicYear, discountAmount);
      
      debugPrint('تم تطبيق خصم الدفع المبكر: ${discountAmount} د.ع');
      return studentDiscount;
      
    } catch (e) {
      debugPrint('خطأ في تطبيق خصم الدفع المبكر: $e');
      return null;
    }
  }
  
  /// معالجة خصم الدفع الكامل
  Future<StudentDiscount?> processFullPaymentDiscount(Student student, String academicYear) async {
    debugPrint('معالجة خصم الدفع الكامل للطالب: ${student.fullName}');
    
    try {
      // فحص إذا كان الخصم مطبق مسبقاً
      final existingDiscount = await isar.studentDiscounts
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (existingDiscount != null) {
        return null;
      }
      
      // جلب حالة القسط
      final feeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (feeStatus == null) {
        return null;
      }
      
      // فحص إذا كان القسط مدفوع بالكامل
      final totalRequired = feeStatus.annualFee + feeStatus.transferredDebtAmount - feeStatus.discountAmount;
      
      if (feeStatus.paidAmount < totalRequired) {
        debugPrint('القسط غير مدفوع بالكامل');
        return null;
      }
      
      // فحص إذا كان الدفع تم في دفعة واحدة
      final payments = await isar.studentPayments
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findAll();
      
      if (payments.length != 1) {
        debugPrint('الدفع لم يتم في دفعة واحدة');
        return null;
      }
      
      // حساب مبلغ الخصم (3% من القسط)
      final discountAmount = feeStatus.annualFee * 0.03;
      
      return await applyFullPaymentDiscount(student, academicYear, discountAmount);
      
    } catch (e) {
      debugPrint('خطأ في معالجة خصم الدفع الكامل: $e');
      return null;
    }
  }
  
  /// تطبيق خصم الدفع الكامل
  Future<StudentDiscount?> applyFullPaymentDiscount(
    Student student, 
    String academicYear, 
    double discountAmount
  ) async {
    try {
      // البحث عن نوع خصم الدفع الكامل أو إنشاؤه
      DiscountType? discountType = await isar.discountTypes
          .filter()
          .nameEqualTo('خصم الدفع الكامل')
          .findFirst();
      
      if (discountType == null) {
        discountType = DiscountType()
          ..name = 'خصم الدفع الكامل'
          ..description = 'خصم للطلاب الذين يدفعون كامل القسط دفعة واحدة'
          ..isActive = true;
        
        await isar.writeTxn(() async {
          await isar.discountTypes.put(discountType!);
        });
      }
      
      // إنشاء خصم الطالب
      final studentDiscount = StudentDiscount()
        ..studentId = student.id.toString()
        ..academicYear = academicYear
        ..discountType = 'خصم الدفع الكامل'
        ..discountValue = discountAmount
        ..isPercentage = false
        ..notes = 'خصم تلقائي للدفع الكامل - 3%'
        ..createdAt = DateTime.now()
        ..isActive = true;
      
      await isar.writeTxn(() async {
        await isar.studentDiscounts.put(studentDiscount);
      });
      
      // تحديث حالة القسط
      await updateFeeStatusWithDiscount(student.id.toString(), academicYear, discountAmount);
      
      debugPrint('تم تطبيق خصم الدفع الكامل: ${discountAmount} د.ع');
      return studentDiscount;
      
    } catch (e) {
      debugPrint('خطأ في تطبيق خصم الدفع الكامل: $e');
      return null;
    }
  }
  
  /// معالجة جميع أنواع الخصومات التلقائية للطالب
  Future<List<StudentDiscount>> processAllAutoDiscounts(Student student, String academicYear) async {
    final appliedDiscounts = <StudentDiscount>[];
    
    // خصم الأشقاء
    final siblingDiscount = await processSiblingDiscount(student, academicYear);
    if (siblingDiscount != null) {
      appliedDiscounts.add(siblingDiscount);
    }
    
    // خصم الدفع المبكر
    final earlyPaymentDiscount = await processEarlyPaymentDiscount(student, academicYear);
    if (earlyPaymentDiscount != null) {
      appliedDiscounts.add(earlyPaymentDiscount);
    }
    
    // خصم الدفع الكامل
    final fullPaymentDiscount = await processFullPaymentDiscount(student, academicYear);
    if (fullPaymentDiscount != null) {
      appliedDiscounts.add(fullPaymentDiscount);
    }
    
    return appliedDiscounts;
  }
  
  /// معالجة الخصومات لجميع الطلاب
  Future<Map<String, List<StudentDiscount>>> processAllStudentsDiscounts(String academicYear) async {
    final results = <String, List<StudentDiscount>>{};
    
    try {
      final allStudents = await isar.students.where().findAll();
      
      for (var student in allStudents) {
        final appliedDiscounts = await processAllAutoDiscounts(student, academicYear);
        if (appliedDiscounts.isNotEmpty) {
          results[student.fullName] = appliedDiscounts;
        }
      }
    } catch (e) {
      debugPrint('خطأ في معالجة خصومات جميع الطلاب: $e');
    }
    
    return results;
  }
  
  /// تحديث حالة القسط بالخصم
  Future<void> updateFeeStatusWithDiscount(String studentId, String academicYear, double discountAmount) async {
    try {
      final feeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(studentId)
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (feeStatus != null) {
        await isar.writeTxn(() async {
          feeStatus.discountAmount = feeStatus.discountAmount + discountAmount;
          feeStatus.dueAmount = feeStatus.annualFee + feeStatus.transferredDebtAmount - feeStatus.discountAmount - feeStatus.paidAmount;
          if (feeStatus.dueAmount! < 0) feeStatus.dueAmount = 0;
          await isar.studentFeeStatus.put(feeStatus);
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحديث حالة القسط: $e');
    }
  }
  
  /// حذف خصم تلقائي
  Future<bool> removeAutoDiscount(String studentId, String academicYear, String discountType) async {
    try {
      final discount = await isar.studentDiscounts
          .filter()
          .studentIdEqualTo(studentId)
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (discount != null) {
        // حساب المبلغ الأصلي للخصم
        final discountAmount = discount.discountValue;
        
        await isar.writeTxn(() async {
          await isar.studentDiscounts.delete(discount.id!);
        });
        
        // تحديث حالة القسط
        await updateFeeStatusWithDiscount(studentId, academicYear, -discountAmount);
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('خطأ في حذف الخصم التلقائي: $e');
      return false;
    }
  }
  
  /// الحصول على إحصائيات الخصومات التلقائية
  Future<Map<String, dynamic>> getAutoDiscountStats(String academicYear) async {
    try {
      final allDiscounts = await isar.studentDiscounts
          .filter()
          .academicYearEqualTo(academicYear)
          .findAll();
      
      final siblingDiscounts = allDiscounts.where((d) => d.notes?.contains('خصم تلقائي للأشقاء') == true).length;
      final earlyPaymentDiscounts = allDiscounts.where((d) => d.notes?.contains('خصم تلقائي للدفع المبكر') == true).length;
      final fullPaymentDiscounts = allDiscounts.where((d) => d.notes?.contains('خصم تلقائي للدفع الكامل') == true).length;
      
      final totalDiscountAmount = allDiscounts.fold<double>(0, (sum, d) => sum + d.discountValue);
      
      return {
        'siblingDiscounts': siblingDiscounts,
        'earlyPaymentDiscounts': earlyPaymentDiscounts,
        'fullPaymentDiscounts': fullPaymentDiscounts,
        'totalDiscounts': allDiscounts.length,
        'totalDiscountAmount': totalDiscountAmount,
      };
    } catch (e) {
      debugPrint('خطأ في الحصول على إحصائيات الخصومات: $e');
      return {};
    }
  }
}
