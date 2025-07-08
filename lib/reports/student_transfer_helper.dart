import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/student_discount.dart';
import 'package:school_app_flutter/localdatabase/student_payment.dart';
import 'package:school_app_flutter/main.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/class.dart';
import '../localdatabase/income.dart';
import '../localdatabase/income_category.dart';

class StudentTransferHelper {
  final Isar isar;

  StudentTransferHelper(this.isar);

  /// ترحيل طالب إلى صف أعلى مع إدارة الديون
  Future<bool> transferStudent({
    required Student student,
    required SchoolClass newClass,
    required double newAnnualFee,
    required String newAcademicYear,
    required String currentAcademicYear,
    required String debtHandlingAction, // 'pay_all' أو 'move_due'
  }) async {
    try {
      // جلب آخر سجل قسط للطالب (أحدث سنة دراسية) بدلاً من البحث في سنة محددة
      final allFeeStatuses = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(student.id.toString())
          .sortByAcademicYearDesc()
          .findAll();
      
      final currentFeeStatus = allFeeStatuses.isNotEmpty ? allFeeStatuses.first : null;

      debugPrint('البحث عن آخر سجل قسط للطالب ID: ${student.id}');
      debugPrint('جميع سجلات الأقساط للطالب: ${allFeeStatuses.length}');
      if (currentFeeStatus != null) {
        debugPrint('آخر سجل قسط موجود: السنة ${currentFeeStatus.academicYear}, الصف ${currentFeeStatus.className}');
      } else {
        debugPrint('لا يوجد أي سجل قسط للطالب');
      }

      // حساب المبلغ المتبقي بنفس الطريقة المستخدمة في students_list_screen_supabase.dart
      double previousDue = 0;
      if (currentFeeStatus != null) {
        final totalRequired = currentFeeStatus.annualFee + currentFeeStatus.transferredDebtAmount;
        final totalPaid = currentFeeStatus.paidAmount;
        previousDue = totalRequired - totalPaid;
        
        debugPrint('حساب الدين المتبقي:');
        debugPrint('- القسط السنوي: ${currentFeeStatus.annualFee}');
        debugPrint('- الدين المنقول السابق: ${currentFeeStatus.transferredDebtAmount}');
        debugPrint('- إجمالي المطلوب: $totalRequired');
        debugPrint('- إجمالي المدفوع: $totalPaid');
        debugPrint('- المبلغ المتبقي المحسوب: $previousDue');
        debugPrint('- dueAmount في قاعدة البيانات: ${currentFeeStatus.dueAmount}');
      }

      // التحقق من وجود سجل قسط للسنة الجديدة
      final existingFeeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(student.id.toString())
          .academicYearEqualTo(newAcademicYear)
          .findFirst();

      if (existingFeeStatus != null) {
        throw Exception('الطالب لديه سجل قسط لنفس السنة الدراسية بالفعل!');
      }

      // التحقق من أن السنة الجديدة مختلفة عن السنة الحالية
      if (currentFeeStatus != null && currentFeeStatus.academicYear == newAcademicYear) {
        throw Exception('السنة الدراسية الجديدة يجب أن تكون مختلفة عن السنة الحالية!');
      }

      await isar.writeTxn(() async {
        // تحديث بيانات الطالب
        student.schoolclass.value = newClass;
        student.annualFee = newAnnualFee;
        await isar.students.put(student);
        await student.schoolclass.save();

        if (previousDue > 0) {
          if (debtHandlingAction == 'pay_all') {
            debugPrint('اختيار دفع جميع الديون - سيتم إنشاء فاتورة إيراد');
            
            // اعتبار الدين السابق مدفوع وإنشاء فاتورة إيراد
            await _handlePayAllDebts(currentFeeStatus!, previousDue);

            // إنشاء سجل جديد بدون دين منقول
            await _createNewFeeStatus(
              student: student,
              newClass: newClass,
              newAcademicYear: newAcademicYear,
              newAnnualFee: newAnnualFee,
              transferredDebt: 0,
              originalAcademicYear: null,
              originalClassName: null,
            );

        
          } else if (debtHandlingAction == 'move_due') {
            // تحديث dueAmount في السجل الحالي ليعكس الحساب الصحيح
            currentFeeStatus!.dueAmount = previousDue;
            
            // استخدام السنة الدراسية الفعلية للسجل الموجود
            final actualCurrentAcademicYear = currentFeeStatus.academicYear;
            
            // نقل الدين إلى السنة الجديدة
            await _moveDebtsToNewYear(
              currentFeeStatus: currentFeeStatus,
              student: student,
              newClass: newClass,
              newAcademicYear: newAcademicYear,
              newAnnualFee: newAnnualFee,
              currentAcademicYear: actualCurrentAcademicYear,
              previousDue: previousDue,
            );
          }
        } else {
          // ترحيل عادي بدون ديون
          await _createNewFeeStatus(
            student: student,
            newClass: newClass,
            newAcademicYear: newAcademicYear,
            newAnnualFee: newAnnualFee,
            transferredDebt: 0,
            originalAcademicYear: null,
            originalClassName: null,
          );
        }
      });

      return true;
    } catch (e) {
      print('خطأ في ترحيل الطالب: $e');
      return false;
    }
  }

  /// معالجة دفع جميع الديون مع إنشاء فاتورة وإيراد
  Future<void> _handlePayAllDebts(StudentFeeStatus currentFeeStatus, double previousDue) async {
    // تحديث سجل القسط
    currentFeeStatus.paidAmount = (currentFeeStatus.paidAmount) + previousDue;
    currentFeeStatus.dueAmount = 0;
    await isar.studentFeeStatus.put(currentFeeStatus);

    // إنشاء إيراد لتسوية الديون
    await _createDebtSettlementIncome(currentFeeStatus, previousDue);
    
    debugPrint('✅ تم دفع جميع الديون وإنشاء فاتورة الإيراد بمبلغ: $previousDue');
  }

  Future<void> _createDebtSettlementIncome(StudentFeeStatus feeStatus, double amount) async {
    // جلب تصنيف الإيراد "تسوية ديون" أو إنشاؤه إذا لم يكن موجوداً
    IncomeCategory? debtSettlementCategory = await isar.incomeCategorys
        .filter()
        .identifierEqualTo('debt_settlement')
        .findFirst();

    if (debtSettlementCategory == null) {
      debtSettlementCategory = IncomeCategory()
        ..name = 'تسوية ديون الطلاب'
        ..identifier = 'debt_settlement';
      debtSettlementCategory.id = await isar.incomeCategorys.put(debtSettlementCategory);
    }

    // تحميل بيانات الطالب
    await feeStatus.student.load();
    final student = feeStatus.student.value;
    final studentName = student?.fullName ?? 'طالب غير معروف';
    final currentDateTime = DateTime.now();

    // إنشاء سجل الإيراد
    final income = Income()
      ..title = 'تسوية ديون الطالب $studentName'
      ..amount = amount
      ..incomeDate = currentDateTime
      ..academicYear = feeStatus.academicYear
      ..note = 'تسوية ديون عند ترحيل الطالب $studentName من ${feeStatus.className} - السنة ${feeStatus.academicYear}'
      ..archived = false
      ..category.value = debtSettlementCategory;

    await isar.incomes.put(income);
    await income.category.save();

    // إنشاء دفعة للطالب لتسجيل عملية دفع الدين
    if (student != null) {
      final studentPayment = StudentPayment()
        ..studentId = student.id.toString()
        ..amount = amount
        ..paidAt = currentDateTime
        ..notes = 'تسوية ديون عند الترحيل - دفع كامل المتبقي'
        ..academicYear = feeStatus.academicYear
        
        // ..paymentMethod = 'تسوية ديون' // أو يمكن استخدام 'نقدي' حسب نظامك
        ..receiptNumber = 'DEBT-${currentDateTime.millisecondsSinceEpoch}'
        ..isDebtSettlement = true // إضافة حقل للتمييز أن هذه دفعة تسوية ديون
        ..student.value = student;

      await isar.studentPayments.put(studentPayment);
      await studentPayment.student.save();

      debugPrint('✅ إنشاء دفعة تسوية ديون للطالب:');
      debugPrint('- رقم الإيصال: ${studentPayment.receiptNumber}');
      debugPrint('- المبلغ: $amount د.ع');
      // debugPrint('- طريقة الدفع: ${studentPayment.paymentMethod}');
    }

    debugPrint('إنشاء إيراد تسوية ديون:');
    debugPrint('- الطالب: $studentName');
    debugPrint('- المبلغ: $amount د.ع');
    debugPrint('- السنة الدراسية: ${feeStatus.academicYear}');
    debugPrint('- الصف: ${feeStatus.className}');
  }
  // /// إنشاء إيراد لتسوية الديون
  // Future<void> _createDebtSettlementIncome(StudentFeeStatus feeStatus, double amount) async {
  //   // جلب تصنيف الإيراد "تسوية ديون" أو إنشاؤه إذا لم يكن موجوداً
  //   IncomeCategory? debtSettlementCategory = await isar.incomeCategorys
  //       .filter()
  //       .identifierEqualTo('debt_settlement')
  //       .findFirst();

  //   if (debtSettlementCategory == null) {
  //     debtSettlementCategory = IncomeCategory()
  //       ..name = 'تسوية ديون الطلاب'
  //       ..identifier = 'debt_settlement';
  //     debtSettlementCategory.id = await isar.incomeCategorys.put(debtSettlementCategory);
  //   }

  //   // تحميل بيانات الطالب
  //   await feeStatus.student.load();
  //   final student = feeStatus.student.value;
  //   final studentName = student?.fullName ?? 'طالب غير معروف';

  //   // إنشاء سجل الإيراد
  //   final income = Income()
  //     ..title = 'تسوية ديون الطالب $studentName'
  //     ..amount = amount
  //     ..incomeDate = DateTime.now()
  //     ..academicYear = feeStatus.academicYear
  //     ..note = 'تسوية ديون عند ترحيل الطالب $studentName من ${feeStatus.className} - السنة ${feeStatus.academicYear}'
  //     ..archived = false
  //     ..category.value = debtSettlementCategory;

  //   await isar.incomes.put(income);
  //   await income.category.save();

  //   debugPrint('إنشاء إيراد تسوية ديون:');
  //   debugPrint('- الطالب: $studentName');
  //   debugPrint('- المبلغ: $amount د.ع');
  //   debugPrint('- السنة الدراسية: ${feeStatus.academicYear}');
  //   debugPrint('- الصف: ${feeStatus.className}');
  // }

  /// نقل الديون إلى السنة الجديدة مع تراكم الديون من عدة سنوات
  Future<void> _moveDebtsToNewYear({
    required StudentFeeStatus currentFeeStatus,
    required Student student,
    required SchoolClass newClass,
    required String newAcademicYear,
    required double newAnnualFee,
    required String currentAcademicYear,
    required double previousDue,
  }) async {
    // نقل كامل الدين المتبقي إلى السنة الجديدة (تراكمي)
    final totalTransferredDebt = previousDue;
    
    debugPrint('ترحيل الديون:');
    debugPrint('- الدين المتبقي الإجمالي (dueAmount): ${currentFeeStatus.dueAmount}');
    debugPrint('- المبلغ المدفوع: ${currentFeeStatus.paidAmount}');
    debugPrint('- القسط السنوي للسنة الحالية: ${currentFeeStatus.annualFee}');
    debugPrint('- الدين المنقول السابق: ${currentFeeStatus.transferredDebtAmount}');
    debugPrint('- الدين المحسوب للنقل (previousDue): $previousDue');
    debugPrint('- إجمالي الدين المنقول للسنة الجديدة: $totalTransferredDebt');
    
    // تحديد السنة والصف الأصلي للدين
    String? originalAcademicYear;
    String? originalClassName;
    
    if (totalTransferredDebt > 0) {
      if (currentFeeStatus.originalDebtAcademicYear != null && 
          currentFeeStatus.originalDebtClassName != null) {
        // إذا كان هناك دين أصلي موجود مسبقاً (دين منقول من سنة أخرى)، احتفظ به
        originalAcademicYear = currentFeeStatus.originalDebtAcademicYear!;
        originalClassName = currentFeeStatus.originalDebtClassName!;
        debugPrint('- احتفاظ بالسنة الأصلية للدين المنقول: $originalAcademicYear - $originalClassName');
      } else {
        // إذا لم يكن هناك دين أصلي (أول مرة ينقل فيها الدين)، استخدم السنة الحالية كأصل
        originalAcademicYear = currentAcademicYear;
        originalClassName = currentFeeStatus.className;
        debugPrint('- تعيين السنة الحالية كأصل للدين الجديد: $originalAcademicYear - $originalClassName');
      }
    } else {
      // لا يوجد دين منقول - تصفير القيم
      originalAcademicYear = null;
      originalClassName = null;
      debugPrint('- لا يوجد دين منقول');
    }

    // إنشاء سجل جديد مع الدين المتراكم
    await _createNewFeeStatus(
      student: student,
      newClass: newClass,
      newAcademicYear: newAcademicYear,
      newAnnualFee: newAnnualFee,
      transferredDebt: totalTransferredDebt,
      originalAcademicYear: originalAcademicYear,
      originalClassName: originalClassName,
    );

    // تصفير الدين في السجل القديم
    currentFeeStatus.dueAmount = 0;
    await isar.studentFeeStatus.put(currentFeeStatus);
    
    debugPrint('✅ تم ترحيل الديون بنجاح');
    debugPrint('- تم تصفير دين السنة السابقة');
    debugPrint('- تم نقل إجمالي $totalTransferredDebt إلى السنة الجديدة');
    if (originalAcademicYear != null) {
      debugPrint('- أصل الدين: $originalAcademicYear - $originalClassName');
    }
  }

  /// إنشاء سجل قسط جديد
  Future<void> _createNewFeeStatus({
    required Student student,
    required SchoolClass newClass,
    required String newAcademicYear,
    required double newAnnualFee,
    required double transferredDebt,
    String? originalAcademicYear,
    String? originalClassName,
  }) async {
    final totalDue = newAnnualFee + transferredDebt;
    
    debugPrint('إنشاء سجل قسط جديد:');
    debugPrint('- الطالب: ${student.fullName}');
    debugPrint('- الصف الجديد: ${newClass.name}');
    debugPrint('- السنة الدراسية: $newAcademicYear');
    debugPrint('- القسط السنوي: $newAnnualFee');
    debugPrint('- الدين المنقول: $transferredDebt');
    debugPrint('- إجمالي المطلوب: $totalDue');
    debugPrint('- السنة الأصلية للدين: $originalAcademicYear');
    debugPrint('- الصف الأصلي للدين: $originalClassName');
    
    final newFeeStatus = StudentFeeStatus()
      ..studentId = student.id.toString()
      ..className = newClass.name
      ..academicYear = newAcademicYear
      ..annualFee = newAnnualFee
      ..dueAmount = totalDue
      ..paidAmount = 0
      ..transferredDebtAmount = transferredDebt
      ..originalDebtAcademicYear = originalAcademicYear
      ..originalDebtClassName = originalClassName
      ..student.value = student
      ..createdAt = DateTime.now();
    
    await isar.studentFeeStatus.put(newFeeStatus);
    await newFeeStatus.student.save();
    
    debugPrint('✅ تم إنشاء سجل القسط الجديد بنجاح');
  }

  /// حساب الديون المتبقية من سنة معينة
  Future<List<Map<String, dynamic>>> getStudentsWithDebtsFromYear(String academicYear) async {
    final feeStatuses = await isar.studentFeeStatus
        .filter()
        .academicYearEqualTo(academicYear)
        .and()
        .dueAmountGreaterThan(0)
        .findAll();

    List<Map<String, dynamic>> studentsWithDebts = [];

    for (final status in feeStatuses) {
      await status.student.load();
      final student = status.student.value;
      if (student != null) {
        // حساب الدين الأصلي (بدون الديون المنقولة)
        final originalDebt = status.dueAmount! - status.transferredDebtAmount;
        if (originalDebt > 0) {
          studentsWithDebts.add({
            'student': student,
            'originalDebt': originalDebt,
            'totalDebt': status.dueAmount,
            'transferredDebt': status.transferredDebtAmount,
            'feeStatus': status,
          });
        }
      }
    }

    return studentsWithDebts;
  }

  /// تقرير الديون المنقولة
  Future<Map<String, dynamic>> getTransferredDebtsReport() async {
    final allFeeStatuses = await isar.studentFeeStatus
        .filter()
        .transferredDebtAmountGreaterThan(0)
        .findAll();

    double totalTransferredDebts = 0;
    Map<String, double> debtsByOriginalYear = {};
    List<Map<String, dynamic>> detailedReport = [];

    for (final status in allFeeStatuses) {
      await status.student.load();
      final student = status.student.value;

      if (student != null) {
        totalTransferredDebts += status.transferredDebtAmount;
        
        final originalYear = status.originalDebtAcademicYear ?? 'غير معروف';
        debtsByOriginalYear[originalYear] = 
            (debtsByOriginalYear[originalYear] ?? 0) + status.transferredDebtAmount;

        detailedReport.add({
          'studentName': student.fullName,
          'currentYear': status.academicYear,
          'currentClass': status.className,
          'originalYear': status.originalDebtAcademicYear,
          'originalClass': status.originalDebtClassName,
          'transferredAmount': status.transferredDebtAmount,
          'totalDue': status.dueAmount,
          'paidAmount': status.paidAmount,
        });
      }
    }

    return {
      'totalTransferredDebts': totalTransferredDebts,
      'debtsByOriginalYear': debtsByOriginalYear,
      'detailedReport': detailedReport,
      'studentsCount': detailedReport.length,
    };
  }

  /// تتبع تاريخ تراكم الديون لطالب معين
  Future<Map<String, dynamic>> getStudentDebtHistory(String studentId) async {
    final allFeeStatuses = await isar.studentFeeStatus
        .filter()
        .studentIdEqualTo(studentId)
        .sortByAcademicYear()
        .findAll();

    List<Map<String, dynamic>> debtHistory = [];
    double currentAccumulatedDebt = 0;

    for (final status in allFeeStatuses) {
      final yearDebt = status.annualFee;
      final transferredFromPrevious = status.transferredDebtAmount;
      final totalYearDue = status.dueAmount!;
      final paidAmount = status.paidAmount;
      final remainingDebt = totalYearDue - paidAmount;

      // إجمالي الدين المتراكم هو فقط الدين المتبقي في آخر سنة (لأن الديون تنتقل تراكمياً)
      currentAccumulatedDebt = remainingDebt;

      debtHistory.add({
        'academicYear': status.academicYear,
        'className': status.className,
        'annualFee': yearDebt,
        'transferredFromPrevious': transferredFromPrevious,
        'totalDue': totalYearDue,
        'paidAmount': paidAmount,
        'remainingDebt': remainingDebt,
        'originalDebtYear': status.originalDebtAcademicYear,
        'originalDebtClass': status.originalDebtClassName,
        'createdAt': status.createdAt,
        'isCurrentDebt': remainingDebt > 0,
      });
    }

    return {
      'studentId': studentId,
      'debtHistory': debtHistory,
      'currentAccumulatedDebt': currentAccumulatedDebt,
      'yearsCount': debtHistory.length,
    };
  }

  Future<void> _transferStudentFeeStatus({
  required Student student,
  required SchoolClass newClass,
  required String newAcademicYear,
}) async {
  try {
    print('🔄 ترحيل حالة القسط للطالب ${student.fullName}...');
    
    // جلب حالة القسط الحالية
    final currentFeeStatus = await isar.studentFeeStatus
        .filter()
        .studentIdEqualTo(student.id.toString())
        .academicYearEqualTo(academicYear) // السنة الحالية
        .findFirst();

    if (currentFeeStatus == null) {
      print('⚠️ لا توجد حالة قسط حالية للطالب');
      return;
    }

    print('📊 حالة القسط الحالية:');
    print('- القسط السنوي: ${currentFeeStatus.annualFee}');
    print('- المدفوع: ${currentFeeStatus.paidAmount}');
    print('- الخصم: ${currentFeeStatus.discountAmount}');
    print('- المتبقي: ${currentFeeStatus.dueAmount}');

    // حساب المبلغ الفعلي المتبقي (بعد خصم الخصومات والدفعات)
    final actualDueAmount = (currentFeeStatus.annualFee + currentFeeStatus.transferredDebtAmount) 
                           - currentFeeStatus.discountAmount 
                           - currentFeeStatus.paidAmount;

    print('💰 المبلغ الفعلي المتبقي (بعد الخصومات): $actualDueAmount');

    // إذا كان هناك دين فعلي، انقله
    if (actualDueAmount > 0) {
      // إنشاء إيراد لتسوية الجزء المدفوع والمخصوم
      final settledAmount = currentFeeStatus.paidAmount + currentFeeStatus.discountAmount;
      if (settledAmount > 0) {
        await _createDebtSettlementIncome(currentFeeStatus, settledAmount);
      }

      // إنشاء حالة قسط جديدة للسنة الجديدة مع الدين المنقول
      final newFeeStatus = StudentFeeStatus()
        ..studentId = student.id.toString()
        ..className = newClass.name
        ..academicYear = newAcademicYear
        ..annualFee = student.annualFee ?? newClass.annualFee ?? 0.0
        ..paidAmount = 0.0
        ..discountAmount = 0.0 // ستحتاج لإعادة تطبيق الخصومات إذا كانت مستمرة
        ..transferredDebtAmount = actualDueAmount // المبلغ الفعلي المتبقي فقط
        ..dueAmount = (student.annualFee ?? newClass.annualFee ?? 0.0) + actualDueAmount
        ..originalDebtAcademicYear = currentFeeStatus.academicYear
        ..originalDebtClassName = currentFeeStatus.className
        ..createdAt = DateTime.now()
        ..student.value = student;

      await isar.writeTxn(() async {
        await isar.studentFeeStatus.put(newFeeStatus);
        await newFeeStatus.student.save();
      });

      print('✅ تم إنشاء حالة قسط جديدة:');
      print('- القسط الجديد: ${newFeeStatus.annualFee}');
      print('- الدين المنقول: ${newFeeStatus.transferredDebtAmount}');
      print('- إجمالي المتبقي: ${newFeeStatus.dueAmount}');
    } else {
      print('✅ لا يوجد دين للنقل - القسط مدفوع بالكامل أو مغطى بالخصومات');
      
      // إنشاء إيراد لتسوية القسط كاملاً
      await _createDebtSettlementIncome(currentFeeStatus, currentFeeStatus.annualFee);

      // إنشاء حالة قسط جديدة بدون دين منقول
      final newFeeStatus = StudentFeeStatus()
        ..studentId = student.id.toString()
        ..className = newClass.name
        ..academicYear = newAcademicYear
        ..annualFee = student.annualFee ?? newClass.annualFee ?? 0.0
        ..paidAmount = 0.0
        ..discountAmount = 0.0
        ..transferredDebtAmount = 0.0
        ..dueAmount = student.annualFee ?? newClass.annualFee ?? 0.0
        ..originalDebtAcademicYear = ''
        ..originalDebtClassName = ''
        ..createdAt = DateTime.now()
        ..student.value = student;

      await isar.writeTxn(() async {
        await isar.studentFeeStatus.put(newFeeStatus);
        await newFeeStatus.student.save();
      });
    }

    // تطبيق الخصومات المستمرة للسنة الجديدة (إن وجدت)
    await _transferContinuousDiscounts(student, newAcademicYear,currentFeeStatus.academicYear);

  } catch (e) {
    print('❌ خطأ في ترحيل حالة القسط: $e');
    rethrow;
  }
}

/// تطبيق الخصومات المستمرة للسنة الجديدة
Future<void> _transferContinuousDiscounts(Student student, String newAcademicYear,String prevYear) async {
  try {
    // جلب الخصومات من السنة السابقة
    final previousDiscounts = await isar.studentDiscounts
        .filter()
        .studentIdEqualTo(student.id.toString())
        .academicYearEqualTo(prevYear) // السنة السابقة
        .isActiveEqualTo(true)
        .findAll();

    if (previousDiscounts.isEmpty) return;

    print('🔄 نقل الخصومات المستمرة للسنة الجديدة...');

    for (final discount in previousDiscounts) {
      // تحقق من أن الخصم لا يزال ساري المفعول
      if (discount.expiryDate != null && 
          discount.expiryDate!.isBefore(DateTime.now())) {
        continue;
      }

      // إنشاء خصم جديد للسنة الجديدة
      final newDiscount = StudentDiscount()
        ..studentId = student.id.toString()
        ..discountType = discount.discountType
        ..discountValue = discount.discountValue
        ..isPercentage = discount.isPercentage
        ..academicYear = newAcademicYear
        ..notes = '${discount.notes ?? ''} - منقول من ${discount.academicYear}'
        ..addedBy = discount.addedBy
        ..expiryDate = discount.expiryDate
        ..isActive = true
        ..createdAt = DateTime.now()
        ..student.value = student;

      await isar.writeTxn(() async {
        await isar.studentDiscounts.put(newDiscount);
        await newDiscount.student.save();
      });

      print('✅ تم نقل خصم: ${discount.discountType}');
    }

    // تحديث حالة القسط بالخصومات الجديدة
    await _updateFeeStatusWithNewDiscounts(student.id.toString(), newAcademicYear);

  } catch (e) {
    print('❌ خطأ في نقل الخصومات: $e');
  }
}

/// تحديث حالة القسط بالخصومات الجديدة
Future<void> _updateFeeStatusWithNewDiscounts(String studentId, String academicYear) async {
  try {
    final feeStatus = await isar.studentFeeStatus
        .filter()
        .studentIdEqualTo(studentId)
        .academicYearEqualTo(academicYear)
        .findFirst();

    if (feeStatus == null) return;

    // حساب إجمالي الخصومات الجديدة
    final discounts = await isar.studentDiscounts
        .filter()
        .studentIdEqualTo(studentId)
        .academicYearEqualTo(academicYear)
        .isActiveEqualTo(true)
        .findAll();

    double totalDiscount = 0;
    for (final discount in discounts) {
      if (discount.expiryDate != null && 
          discount.expiryDate!.isBefore(DateTime.now())) {
        continue;
      }

      if (discount.isPercentage) {
        totalDiscount += (feeStatus.annualFee * discount.discountValue / 100);
      } else {
        totalDiscount += discount.discountValue;
      }
    }

    // تحديث حالة القسط
    await isar.writeTxn(() async {
      feeStatus.discountAmount = totalDiscount;
      feeStatus.dueAmount = (feeStatus.annualFee + feeStatus.transferredDebtAmount) - 
                           totalDiscount - feeStatus.paidAmount;
      await isar.studentFeeStatus.put(feeStatus);
    });

    print('✅ تم تحديث حالة القسط بالخصومات:');
    print('- إجمالي الخصم: $totalDiscount');
    print('- المتبقي الجديد: ${feeStatus.dueAmount}');

  } catch (e) {
    print('❌ خطأ في تحديث حالة القسط بالخصومات: $e');
  }
}
}