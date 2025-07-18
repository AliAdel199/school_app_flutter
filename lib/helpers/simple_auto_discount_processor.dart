import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_discount.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/student_payment.dart';
import '../localdatabase/discount_type.dart';
import 'auto_discount_settings_manager.dart';

/// معالج الخصومات التلقائية المحسن
class AutoDiscountProcessor {
  final Isar isar;
  late final AutoDiscountSettingsManager settingsManager;
  
  AutoDiscountProcessor(this.isar) {
    settingsManager = AutoDiscountSettingsManager(isar);
  }

  /// فحص ما إذا كان النظام مفعل قبل معالجة أي خصم
  Future<bool> _isSystemEnabled() async {
    return await settingsManager.isGloballyEnabled();
  }

  /// فحص ما إذا كان نوع خصم معين مفعل
  Future<bool> _isDiscountTypeEnabled(String discountType) async {
    return await settingsManager.isDiscountTypeEnabled(discountType);
  }

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
      // فحص ما إذا كان النظام وخصم الأشقاء مفعلين
      if (!await _isSystemEnabled()) {
        debugPrint('❌ نظام الخصومات التلقائية معطل');
        return null;
      }
      
      if (!await _isDiscountTypeEnabled('sibling')) {
        debugPrint('❌ خصم الأشقاء معطل');
        return null;
      }
      
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
      
      // حساب نسبة الخصم بناءً على ترتيب الطالب من الإعدادات
      final discountRates = await settingsManager.getSiblingDiscountRates();
      final discountPercentage = calculateSiblingDiscountPercentageFromSettings(student, siblings, discountRates);
      
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

  /// حساب نسبة خصم الأشقاء بناءً على الإعدادات
  double calculateSiblingDiscountPercentageFromSettings(Student student, List<Student> siblings, Map<int, double> discountRates) {
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
    
    // تحديد نسبة الخصم من الإعدادات
    final position = studentIndex + 1; // +1 لأن المؤشر يبدأ من 0
    
    if (position <= 1) {
      return discountRates[1] ?? 0.0; // الطالب الأول
    } else if (position == 2) {
      return discountRates[2] ?? 10.0; // الطالب الثاني
    } else if (position == 3) {
      return discountRates[3] ?? 15.0; // الطالب الثالث
    } else {
      return discountRates[4] ?? 20.0; // الطالب الرابع فما فوق
    }
  }

  /// حساب نسبة خصم الأشقاء بناءً على ترتيب الطالب (الطريقة القديمة)
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
      // فحص ما إذا كان النظام وخصم الدفع المبكر مفعلين
      if (!await _isSystemEnabled()) {
        debugPrint('❌ نظام الخصومات التلقائية معطل');
        return null;
      }
      
      if (!await _isDiscountTypeEnabled('earlyPayment')) {
        debugPrint('❌ خصم الدفع المبكر معطل');
        return null;
      }
      
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
      
      // الحصول على عدد الأيام من الإعدادات
      final earlyPaymentDays = await settingsManager.getEarlyPaymentDays();
      
      // فحص إذا كان الدفع قبل بداية العام بالأيام المحددة
      final earlyPaymentDeadline = schoolStart.subtract(Duration(days: earlyPaymentDays));
      
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
      
      // حساب مبلغ الخصم من الإعدادات
      final discountRate = await settingsManager.getEarlyPaymentDiscountRate();
      final discountAmount = feeStatus.annualFee * (discountRate / 100);
      
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
      // فحص إذا كان النظام مفعل
      if (!await _isSystemEnabled()) {
        debugPrint('نظام الخصومات التلقائية معطل');
        return null;
      }

      // فحص إذا كان خصم الدفع الكامل مفعل
      if (!await _isDiscountTypeEnabled('full_payment')) {
        debugPrint('خصم الدفع الكامل معطل');
        return null;
      }
      
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
      
      // حساب مبلغ الخصم من الإعدادات
      final discountRate = await settingsManager.getFullPaymentDiscountRate();
      final discountAmount = feeStatus.annualFee * (discountRate / 100);
      
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
    
    // فحص إذا كان نظام الخصومات التلقائية مفعل
    if (!await _isSystemEnabled()) {
      debugPrint('نظام الخصومات التلقائية معطل');
      return appliedDiscounts;
    }
    
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
      // فحص إذا كان نظام الخصومات التلقائية مفعل
      if (!await _isSystemEnabled()) {
        debugPrint('نظام الخصومات التلقائية معطل');
        return results;
      }
      
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

  /// اختبار دقة تحديد الأشقاء - للاستخدام في التطوير والاختبار
  Future<void> testSiblingDetection() async {
    debugPrint('=== اختبار دقة تحديد الأشقاء ===');
    
    final allStudents = await isar.students.where().findAll();
    
    // تجميع الطلاب حسب اسم الوالد
    final Map<String, List<Student>> studentsGroupedByParent = {};
    
    for (var student in allStudents) {
      if (student.parentName != null && student.parentName!.isNotEmpty) {
        final parentName = student.parentName!;
        if (!studentsGroupedByParent.containsKey(parentName)) {
          studentsGroupedByParent[parentName] = [];
        }
        studentsGroupedByParent[parentName]!.add(student);
      }
    }
    
    // فحص المجموعات التي تحتوي على أكثر من طالب
    int totalGroups = 0;
    int confirmedSiblingGroups = 0;
    int questionableGroups = 0;
    
    for (var entry in studentsGroupedByParent.entries) {
      final parentName = entry.key;
      final studentsWithSameParent = entry.value;
      
      if (studentsWithSameParent.length > 1) {
        totalGroups++;
        debugPrint('\n--- مجموعة: $parentName (${studentsWithSameParent.length} طلاب) ---');
        
        bool allAreSiblings = true;
        
        for (int i = 0; i < studentsWithSameParent.length; i++) {
          for (int j = i + 1; j < studentsWithSameParent.length; j++) {
            final student1 = studentsWithSameParent[i];
            final student2 = studentsWithSameParent[j];
            
            if (!_areActualSiblings(student1, student2)) {
              allAreSiblings = false;
              debugPrint('تحذير: ${student1.fullName} و ${student2.fullName} لديهما نفس اسم الوالد ولكن قد لا يكونان أشقاء');
            }
          }
        }
        
        if (allAreSiblings) {
          confirmedSiblingGroups++;
          debugPrint('✓ مجموعة مؤكدة: جميع الطلاب أشقاء');
        } else {
          questionableGroups++;
          debugPrint('⚠ مجموعة مشكوك فيها: قد تحتوي على طلاب غير أشقاء');
        }
      }
    }
    
    debugPrint('\n=== ملخص نتائج الاختبار ===');
    debugPrint('إجمالي المجموعات: $totalGroups');
    debugPrint('المجموعات المؤكدة: $confirmedSiblingGroups');
    debugPrint('المجموعات المشكوك فيها: $questionableGroups');
    if (totalGroups > 0) {
      debugPrint('نسبة الدقة: ${((confirmedSiblingGroups / totalGroups) * 100).toStringAsFixed(1)}%');
    }
  }

  /// الحصول على إحصائيات مفصلة عن الأشقاء في النظام
  Future<Map<String, dynamic>> getSiblingStatistics() async {
    final allStudents = await isar.students.where().findAll();
    
    final Map<String, List<Student>> studentsGroupedByParent = {};
    int totalStudents = 0;
    int studentsWithSiblings = 0;
    int largestSiblingGroup = 0;
    
    for (var student in allStudents) {
      if (student.parentName != null && student.parentName!.isNotEmpty) {
        totalStudents++;
        final parentName = student.parentName!;
        if (!studentsGroupedByParent.containsKey(parentName)) {
          studentsGroupedByParent[parentName] = [];
        }
        studentsGroupedByParent[parentName]!.add(student);
      }
    }
    
    for (var entry in studentsGroupedByParent.entries) {
      final studentsWithSameParent = entry.value;
      
      if (studentsWithSameParent.length > 1) {
        // فحص كل طالب مع الآخرين في نفس المجموعة
        final confirmedSiblings = <Student>[];
        for (var student in studentsWithSameParent) {
          final siblings = await findSiblings(student);
          if (siblings.isNotEmpty) {
            confirmedSiblings.add(student);
          }
        }
        
        studentsWithSiblings += confirmedSiblings.length;
        if (studentsWithSameParent.length > largestSiblingGroup) {
          largestSiblingGroup = studentsWithSameParent.length;
        }
      }
    }
    
    return {
      'totalStudents': totalStudents,
      'studentsWithSiblings': studentsWithSiblings,
      'parentGroups': studentsGroupedByParent.length,
      'siblingGroups': studentsGroupedByParent.values.where((group) => group.length > 1).length,
      'largestSiblingGroup': largestSiblingGroup,
      'percentageWithSiblings': totalStudents > 0 ? (studentsWithSiblings / totalStudents * 100).toStringAsFixed(1) : '0',
    };
  }

  /// تحديد وحل مشاكل دقة تحديد الأشقاء
  Future<Map<String, dynamic>> identifyAndFixSiblingIssues() async {
    debugPrint('=== تحديد وحل مشاكل تحديد الأشقاء ===');
    
    final allStudents = await isar.students.where().findAll();
    
    final Map<String, List<Student>> studentsGroupedByParent = {};
    final List<Map<String, dynamic>> issues = [];
    int totalIssues = 0;
    int fixedIssues = 0;
    
    // تجميع الطلاب حسب اسم الوالد
    for (var student in allStudents) {
      if (student.parentName != null && student.parentName!.isNotEmpty) {
        final parentName = student.parentName!;
        if (!studentsGroupedByParent.containsKey(parentName)) {
          studentsGroupedByParent[parentName] = [];
        }
        studentsGroupedByParent[parentName]!.add(student);
      }
    }
    
    // فحص المجموعات المشكوك فيها
    for (var entry in studentsGroupedByParent.entries) {
      final parentName = entry.key;
      final studentsWithSameParent = entry.value;
      
      if (studentsWithSameParent.length > 1) {
        // فحص كل زوج من الطلاب
        for (int i = 0; i < studentsWithSameParent.length; i++) {
          for (int j = i + 1; j < studentsWithSameParent.length; j++) {
            final student1 = studentsWithSameParent[i];
            final student2 = studentsWithSameParent[j];
            
            if (!_areActualSiblings(student1, student2)) {
              totalIssues++;
              
              final issue = {
                'parentName': parentName,
                'student1': student1.fullName,
                'student2': student2.fullName,
                'student1Id': student1.id,
                'student2Id': student2.id,
                'missingData': _identifyMissingData(student1, student2),
                'conflictingData': _identifyConflictingData(student1, student2),
                'canFix': _canAutoFix(student1, student2),
              };
              
              issues.add(issue);
              
              // محاولة الإصلاح التلقائي إذا كان ممكناً
              if (issue['canFix'] == true) {
                final fixed = await _attemptAutoFix(student1, student2);
                if (fixed) {
                  fixedIssues++;
                  issue['fixed'] = true;
                }
              }
            }
          }
        }
      }
    }
    
    debugPrint('تم تحديد $totalIssues مشكلة، تم إصلاح $fixedIssues منها تلقائياً');
    
    return {
      'totalIssues': totalIssues,
      'fixedIssues': fixedIssues,
      'remainingIssues': totalIssues - fixedIssues,
      'issues': issues,
    };
  }

  /// تحديد البيانات المفقودة
  Map<String, dynamic> _identifyMissingData(Student student1, Student student2) {
    final missing = <String, List<String>>{};
    
    // فحص العنوان
    if (student1.address == null || student1.address!.isEmpty) {
      missing['address'] = missing['address'] ?? [];
      missing['address']!.add(student1.fullName);
    }
    if (student2.address == null || student2.address!.isEmpty) {
      missing['address'] = missing['address'] ?? [];
      missing['address']!.add(student2.fullName);
    }
    
    // فحص رقم الهاتف
    if (student1.parentPhone == null || student1.parentPhone!.isEmpty) {
      missing['parentPhone'] = missing['parentPhone'] ?? [];
      missing['parentPhone']!.add(student1.fullName);
    }
    if (student2.parentPhone == null || student2.parentPhone!.isEmpty) {
      missing['parentPhone'] = missing['parentPhone'] ?? [];
      missing['parentPhone']!.add(student2.fullName);
    }
    
    // فحص تاريخ الميلاد
    if (student1.birthDate == null) {
      missing['birthDate'] = missing['birthDate'] ?? [];
      missing['birthDate']!.add(student1.fullName);
    }
    if (student2.birthDate == null) {
      missing['birthDate'] = missing['birthDate'] ?? [];
      missing['birthDate']!.add(student2.fullName);
    }
    
    return missing;
  }
  
  /// تحديد البيانات المتضاربة
  Map<String, dynamic> _identifyConflictingData(Student student1, Student student2) {
    final conflicts = <String, Map<String, String>>{};
    
    // فحص العنوان
    if (student1.address != null && student2.address != null &&
        student1.address!.isNotEmpty && student2.address!.isNotEmpty &&
        _normalizeAddress(student1.address!) != _normalizeAddress(student2.address!)) {
      conflicts['address'] = {
        student1.fullName: student1.address!,
        student2.fullName: student2.address!,
      };
    }
    
    // فحص رقم الهاتف
    if (student1.parentPhone != null && student2.parentPhone != null &&
        student1.parentPhone!.isNotEmpty && student2.parentPhone!.isNotEmpty &&
        _normalizePhone(student1.parentPhone!) != _normalizePhone(student2.parentPhone!)) {
      conflicts['parentPhone'] = {
        student1.fullName: student1.parentPhone!,
        student2.fullName: student2.parentPhone!,
      };
    }
    
    // فحص الأعمار
    if (student1.birthDate != null && student2.birthDate != null) {
      final ageDifference = (student1.birthDate!.difference(student2.birthDate!)).inDays.abs();
      final yearsDifference = ageDifference / 365;
      
      if (yearsDifference > 20) {
        conflicts['age'] = {
          student1.fullName: '${student1.birthDate.toString().split(' ')[0]} (${yearsDifference.toStringAsFixed(1)} سنة فرق)',
          student2.fullName: student2.birthDate.toString().split(' ')[0],
        };
      }
    }
    
    return conflicts;
  }
  
  /// فحص إمكانية الإصلاح التلقائي
  bool _canAutoFix(Student student1, Student student2) {
    bool canFix = false;
    
    // إصلاح العنوان المفقود
    if ((student1.address != null && student1.address!.isNotEmpty) &&
        (student2.address == null || student2.address!.isEmpty)) {
      canFix = true;
    }
    if ((student2.address != null && student2.address!.isNotEmpty) &&
        (student1.address == null || student1.address!.isEmpty)) {
      canFix = true;
    }
    
    // إصلاح رقم الهاتف المفقود
    if ((student1.parentPhone != null && student1.parentPhone!.isNotEmpty) &&
        (student2.parentPhone == null || student2.parentPhone!.isEmpty)) {
      canFix = true;
    }
    if ((student2.parentPhone != null && student2.parentPhone!.isNotEmpty) &&
        (student1.parentPhone == null || student1.parentPhone!.isEmpty)) {
      canFix = true;
    }
    
    return canFix;
  }
  
  /// محاولة الإصلاح التلقائي
  Future<bool> _attemptAutoFix(Student student1, Student student2) async {
    try {
      bool fixed = false;
      
      // إصلاح العنوان المفقود
      if ((student1.address != null && student1.address!.isNotEmpty) &&
          (student2.address == null || student2.address!.isEmpty)) {
        await isar.writeTxn(() async {
          student2.address = student1.address;
          await isar.students.put(student2);
        });
        fixed = true;
        debugPrint('تم إصلاح العنوان المفقود للطالب ${student2.fullName}');
      }
      
      if ((student2.address != null && student2.address!.isNotEmpty) &&
          (student1.address == null || student1.address!.isEmpty)) {
        await isar.writeTxn(() async {
          student1.address = student2.address;
          await isar.students.put(student1);
        });
        fixed = true;
        debugPrint('تم إصلاح العنوان المفقود للطالب ${student1.fullName}');
      }
      
      // إصلاح رقم الهاتف المفقود
      if ((student1.parentPhone != null && student1.parentPhone!.isNotEmpty) &&
          (student2.parentPhone == null || student2.parentPhone!.isEmpty)) {
        await isar.writeTxn(() async {
          student2.parentPhone = student1.parentPhone;
          await isar.students.put(student2);
        });
        fixed = true;
        debugPrint('تم إصلاح رقم الهاتف المفقود للطالب ${student2.fullName}');
      }
      
      if ((student2.parentPhone != null && student2.parentPhone!.isNotEmpty) &&
          (student1.parentPhone == null || student1.parentPhone!.isEmpty)) {
        await isar.writeTxn(() async {
          student1.parentPhone = student2.parentPhone;
          await isar.students.put(student1);
        });
        fixed = true;
        debugPrint('تم إصلاح رقم الهاتف المفقود للطالب ${student1.fullName}');
      }
      
      return fixed;
    } catch (e) {
      debugPrint('خطأ في الإصلاح التلقائي: $e');
      return false;
    }
  }
}
