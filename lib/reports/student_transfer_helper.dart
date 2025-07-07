import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
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

  /// إنشاء إيراد لتسوية الديون
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

    // إنشاء سجل الإيراد
    final income = Income()
      ..title = 'تسوية ديون الطالب $studentName'
      ..amount = amount
      ..incomeDate = DateTime.now()
      ..academicYear = feeStatus.academicYear
      ..note = 'تسوية ديون عند ترحيل الطالب $studentName من ${feeStatus.className} - السنة ${feeStatus.academicYear}'
      ..archived = false
      ..category.value = debtSettlementCategory;

    await isar.incomes.put(income);
    await income.category.save();

    debugPrint('إنشاء إيراد تسوية ديون:');
    debugPrint('- الطالب: $studentName');
    debugPrint('- المبلغ: $amount د.ع');
    debugPrint('- السنة الدراسية: ${feeStatus.academicYear}');
    debugPrint('- الصف: ${feeStatus.className}');
  }

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
}
