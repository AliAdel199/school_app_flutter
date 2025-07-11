import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_discount.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/student_payment.dart';
import '../localdatabase/discount_type.dart';

/// معالج الخصومات التلقائية المحسن
class AutoDiscountProcessor {
  final Isar isar;
  
  AutoDiscountProcessor(this.isar);

  /// إنشاء سجل القسط للطالب إذا لم يكن موجوداً
  Future<StudentFeeStatus?> createFeeStatusIfNotExists(Student student, String academicYear) async {
    try {
      // التحقق من وجود سجل القسط
      final existingFeeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (existingFeeStatus != null) {
        return existingFeeStatus;
      }
      
      // تحميل بيانات الصف
      await student.schoolclass.load();
      final annualFee = student.annualFee ?? student.schoolclass.value?.annualFee ?? 0.0;
      
      // إنشاء سجل قسط جديد
      final newFeeStatus = StudentFeeStatus()
        ..studentId = student.id.toString()
        ..academicYear = academicYear
        ..annualFee = annualFee
        ..paidAmount = 0.0
        ..discountAmount = 0.0
        ..transferredDebtAmount = 0.0
        ..dueAmount = annualFee
        ..className = student.schoolclass.value?.name ?? 'غير محدد'
        ..createdAt = DateTime.now()
        ..student.value = student;

      await isar.writeTxn(() async {
        await isar.studentFeeStatus.put(newFeeStatus);
        await newFeeStatus.student.save();
      });

      debugPrint('✅ تم إنشاء سجل قسط جديد للطالب ${student.fullName} في السنة $academicYear');
      return newFeeStatus;
      
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء سجل القسط: $e');
      return null;
    }
  }

  /// معالجة خصومات الأشقاء للطالب
  Future<StudentDiscount?> processSiblingDiscount(Student student, String academicYear) async {
    debugPrint('معالجة خصم الأشقاء للطالب: ${student.fullName}');
    
    try {
      // فحص إذا كان الخصم مطبق مسبقاً
      final existingDiscount = await isar.studentDiscounts
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(academicYear)
          .discountTypeEqualTo('خصم الأشقاء')
          .isActiveEqualTo(true)
          .findFirst();
      
      if (existingDiscount != null) {
        debugPrint('خصم الأشقاء مطبق مسبقاً للطالب');
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
      
      // إنشاء أو جلب حالة القسط
      final feeStatus = await createFeeStatusIfNotExists(student, academicYear);
      
      if (feeStatus == null) {
        debugPrint('لا يمكن إنشاء حالة قسط للطالب');
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
      debugPrint('لا يوجد اسم والد للطالب ${student.fullName}');
      return [];
    }
    
    // البحث الأولي بناءً على اسم الوالد
    final candidateSiblings = await isar.students
        .filter()
        .parentNameEqualTo(student.parentName!)
        .findAll();
    
    // إزالة الطالب نفسه من النتائج
    candidateSiblings.removeWhere((s) => s.id == student.id);
    
    if (candidateSiblings.isEmpty) {
      debugPrint('لا توجد مطابقات لاسم الوالد');
      return [];
    }
    
    // فحص دقيق للتأكد من أنهم أشقاء حقيقيين
    final confirmedSiblings = <Student>[];
    
    for (var sibling in candidateSiblings) {
      if (_areActualSiblings(student, sibling)) {
        confirmedSiblings.add(sibling);
      }
    }
    
    debugPrint('تم تأكيد ${confirmedSiblings.length} أشقاء للطالب ${student.fullName}');
    
    return confirmedSiblings;
  }

  /// التحقق من أن الطلاب أشقاء حقيقيين
  bool _areActualSiblings(Student student1, Student student2) {
    // المعيار 1: نفس اسم الوالد (مطلوب)
    if (student1.parentName != student2.parentName) {
      return false;
    }
    
    // عدد المعايير المطابقة
    int matchingCriteria = 0;
    int totalCriteria = 0;
    
    // المعيار 2: نفس العنوان (إذا كان متوفراً)
    if (student1.address != null && 
        student2.address != null && 
        student1.address!.isNotEmpty && 
        student2.address!.isNotEmpty) {
      totalCriteria++;
      if (_normalizeAddress(student1.address!) == _normalizeAddress(student2.address!)) {
        matchingCriteria++;
      }
    }
    
    // المعيار 3: نفس رقم هاتف الوالد (إذا كان متوفراً)
    if (student1.parentPhone != null && 
        student2.parentPhone != null && 
        student1.parentPhone!.isNotEmpty && 
        student2.parentPhone!.isNotEmpty) {
      totalCriteria++;
      if (_normalizePhone(student1.parentPhone!) == _normalizePhone(student2.parentPhone!)) {
        matchingCriteria++;
      }
    }
    
    // المعيار 4: فحص المنطقية في الأعمار (فرق أقل من 20 سنة)
    if (student1.birthDate != null && student2.birthDate != null) {
      totalCriteria++;
      final ageDifference = (student1.birthDate!.difference(student2.birthDate!)).inDays.abs();
      final yearsDifference = ageDifference / 365;
      
      if (yearsDifference <= 20) {
        matchingCriteria++;
      }
    }
    
    // تحديد ما إذا كانوا أشقاء أم لا
    bool areSiblings = false;
    
    if (totalCriteria == 0) {
      // لا توجد معايير إضافية متوفرة، نعتمد على اسم الوالد فقط
      areSiblings = true;
    } else if (matchingCriteria == totalCriteria) {
      // جميع المعايير المتوفرة متطابقة
      areSiblings = true;
    } else if (matchingCriteria >= (totalCriteria * 0.6)) {
      // على الأقل 60% من المعايير متطابقة
      areSiblings = true;
    }
    
    return areSiblings;
  }

  /// تطبيع العنوان لمقارنة أفضل
  String _normalizeAddress(String address) {
    return address.toLowerCase()
        .replaceAll(RegExp(r'[^\u0600-\u06FF\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  /// تطبيع رقم الهاتف لمقارنة أفضل
  String _normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (normalized.startsWith('0')) {
      normalized = normalized.substring(1);
    }
    
    if (normalized.startsWith('964')) {
      normalized = normalized.substring(3);
    }
    
    return normalized;
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
      await updateFeeStatusWithDiscount(student.id.toString(), academicYear);
      
      debugPrint('تم تطبيق خصم الأشقاء: $discountAmount د.ع ($discountPercentage%)');
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
          .discountTypeEqualTo('خصم الدفع المبكر')
          .isActiveEqualTo(true)
          .findFirst();
      
      if (existingDiscount != null) {
        debugPrint('خصم الدفع المبكر مطبق مسبقاً للطالب');
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
        debugPrint('لا توجد دفعات للطالب');
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
      
      // إنشاء أو جلب حالة القسط
      final feeStatus = await createFeeStatusIfNotExists(student, academicYear);
      
      if (feeStatus == null) {
        debugPrint('لا يمكن إنشاء حالة قسط للطالب');
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
      await updateFeeStatusWithDiscount(student.id.toString(), academicYear);
      
      debugPrint('تم تطبيق خصم الدفع المبكر: $discountAmount د.ع');
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
          .discountTypeEqualTo('خصم الدفع الكامل')
          .isActiveEqualTo(true)
          .findFirst();
      
      if (existingDiscount != null) {
        debugPrint('خصم الدفع الكامل مطبق مسبقاً للطالب');
        return null;
      }
      
      // إنشاء أو جلب حالة القسط
      final feeStatus = await createFeeStatusIfNotExists(student, academicYear);
      
      if (feeStatus == null) {
        debugPrint('لا يمكن إنشاء حالة قسط للطالب');
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
      await updateFeeStatusWithDiscount(student.id.toString(), academicYear);
      
      debugPrint('تم تطبيق خصم الدفع الكامل: $discountAmount د.ع');
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

  /// تحديث حالة القسط بالخصومات - نسخة محسنة
  Future<void> updateFeeStatusWithDiscount(String studentId, String academicYear) async {
    try {
      final feeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(studentId)
          .academicYearEqualTo(academicYear)
          .findFirst();
      
      if (feeStatus != null) {
        // إعادة حساب إجمالي الخصومات من جميع خصومات الطالب النشطة
        final totalDiscount = await calculateTotalDiscount(
          studentId: studentId,
          academicYear: academicYear,
          originalFee: feeStatus.annualFee,
        );

        await isar.writeTxn(() async {
          feeStatus.discountAmount = totalDiscount;
          feeStatus.dueAmount = feeStatus.annualFee + feeStatus.transferredDebtAmount - totalDiscount - feeStatus.paidAmount;
          if (feeStatus.dueAmount! < 0) feeStatus.dueAmount = 0;
          await isar.studentFeeStatus.put(feeStatus);
        });

        debugPrint('✅ تم تحديث حالة القسط:');
        debugPrint('- القسط الأصلي: ${feeStatus.annualFee} د.ع');
        debugPrint('- إجمالي الخصم: $totalDiscount د.ع');
        debugPrint('- المبلغ المتبقي الجديد: ${feeStatus.dueAmount} د.ع');
      }
    } catch (e) {
      debugPrint('خطأ في تحديث حالة القسط: $e');
    }
  }

  /// حساب إجمالي الخصومات لطالب في سنة دراسية محددة
  Future<double> calculateTotalDiscount({
    required String studentId,
    required String academicYear,
    required double originalFee,
  }) async {
    final discounts = await isar.studentDiscounts
        .filter()
        .studentIdEqualTo(studentId)
        .academicYearEqualTo(academicYear)
        .isActiveEqualTo(true)
        .findAll();

    double totalDiscount = 0;
    
    for (final discount in discounts) {
      // تحقق من انتهاء صلاحية الخصم
      if (discount.expiryDate != null && 
          discount.expiryDate!.isBefore(DateTime.now())) {
        continue;
      }

      if (discount.isPercentage) {
        // خصم نسبة مئوية
        totalDiscount += (originalFee * discount.discountValue / 100);
      } else {
        // خصم مبلغ ثابت
        totalDiscount += discount.discountValue;
      }
    }

    return totalDiscount;
  }

  /// حذف خصم تلقائي
  Future<bool> removeAutoDiscount(String studentId, String academicYear, String discountType) async {
    try {
      final discount = await isar.studentDiscounts
          .filter()
          .studentIdEqualTo(studentId)
          .academicYearEqualTo(academicYear)
          .discountTypeEqualTo(discountType)
          .isActiveEqualTo(true)
          .findFirst();
      
      if (discount != null) {
        await isar.writeTxn(() async {
          await isar.studentDiscounts.delete(discount.id!);
        });
        
        // تحديث حالة القسط بإعادة حساب جميع الخصومات
        await updateFeeStatusWithDiscount(studentId, academicYear);
        
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
          .isActiveEqualTo(true)
          .findAll();
      
      final siblingDiscounts = allDiscounts.where((d) => d.discountType == 'خصم الأشقاء').length;
      final earlyPaymentDiscounts = allDiscounts.where((d) => d.discountType == 'خصم الدفع المبكر').length;
      final fullPaymentDiscounts = allDiscounts.where((d) => d.discountType == 'خصم الدفع الكامل').length;
      
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
