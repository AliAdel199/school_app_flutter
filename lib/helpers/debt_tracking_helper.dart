import 'package:isar/isar.dart';
import '../localdatabase/student_fee_status.dart';

class DebtTrackingHelper {
  final Isar isar;

  DebtTrackingHelper(this.isar);

  /// حساب إجمالي الأقساط المحصلة لسنة دراسية محددة
  /// يشمل المدفوعات المحصلة من السنة نفسها + الديون المنقولة المحصلة
  Future<double> getTotalCollectedForYear(String academicYear) async {
    // جمع المدفوعات من نفس السنة
    final sameYearPayments = await isar.studentFeeStatus
        .filter()
        .academicYearEqualTo(academicYear)
        .findAll();

    double totalCollected = 0;

    for (final feeStatus in sameYearPayments) {
      // المدفوع من قسط السنة الحالية
      final currentYearPayment = feeStatus.paidAmount - feeStatus.transferredDebtAmount;
      if (currentYearPayment > 0) {
        totalCollected += currentYearPayment;
      }
    }

    return totalCollected;
  }

  /// حساب إجمالي الديون المنقولة المحصلة من سنة محددة
  Future<double> getTransferredDebtCollectedFromYear(String originalAcademicYear) async {
    final allFeeStatuses = await isar.studentFeeStatus
        .filter()
        .originalDebtAcademicYearIsNotNull()
        .and()
        .originalDebtAcademicYearEqualTo(originalAcademicYear)
        .findAll();

    double totalTransferredDebtCollected = 0;

    for (final feeStatus in allFeeStatuses) {
      final transferredDebt = feeStatus.transferredDebtAmount;
      final totalPaid = feeStatus.paidAmount;
      
      // إذا كان المدفوع أكبر من أو يساوي القسط الحالي، فالفرق هو من الدين المنقول
      final currentYearFee = feeStatus.annualFee;
      if (totalPaid > currentYearFee) {
        final paidFromTransferredDebt = totalPaid - currentYearFee;
        totalTransferredDebtCollected += paidFromTransferredDebt;
      } else if (transferredDebt > 0 && totalPaid > 0) {
        // إذا كان هناك دين منقول وتم دفع جزء، احسب النسبة
        final paymentRatio = totalPaid / (currentYearFee + transferredDebt);
        final paidFromTransferredDebt = transferredDebt * paymentRatio;
        totalTransferredDebtCollected += paidFromTransferredDebt;
      }
    }

    return totalTransferredDebtCollected;
  }

  /// حساب إجمالي الديون المتبقية لسنة محددة
  Future<double> getRemainingDebtForYear(String academicYear) async {
    final feeStatuses = await isar.studentFeeStatus
        .filter()
        .academicYearEqualTo(academicYear)
        .findAll();

    double totalRemainingDebt = 0;

    for (final feeStatus in feeStatuses) {
      final remainingAmount = (feeStatus.dueAmount ?? 0);
      // اطرح الدين المنقول من الدين المتبقي للحصول على الدين الأصلي للسنة
      final originalDebtForYear = remainingAmount - feeStatus.transferredDebtAmount;
      if (originalDebtForYear > 0) {
        totalRemainingDebt += originalDebtForYear;
      }
    }

    return totalRemainingDebt;
  }

  /// حساب تقرير مالي شامل لسنة دراسية
  Future<Map<String, double>> getYearlyFinancialReport(String academicYear) async {
    final collectedThisYear = await getTotalCollectedForYear(academicYear);
    final transferredDebtCollected = await getTransferredDebtCollectedFromYear(academicYear);
    final remainingDebt = await getRemainingDebtForYear(academicYear);

    // حساب إجمالي الأقساط المطلوبة للسنة
    final feeStatuses = await isar.studentFeeStatus
        .filter()
        .academicYearEqualTo(academicYear)
        .findAll();

    double totalExpectedFees = 0;
    for (final feeStatus in feeStatuses) {
      totalExpectedFees += feeStatus.annualFee;
    }

    return {
      'total_expected_fees': totalExpectedFees,
      'collected_this_year': collectedThisYear,
      'transferred_debt_collected': transferredDebtCollected,
      'remaining_debt': remainingDebt,
      'collection_rate': totalExpectedFees > 0 ? (collectedThisYear / totalExpectedFees) * 100 : 0,
    };
  }

  /// عند دفع قسط، تحديد كيفية توزيع المبلغ بين القسط الحالي والدين المنقول
  Map<String, double> distributePayment(double paymentAmount, double currentYearFee, double transferredDebt) {
    double paidForCurrentYear = 0;
    double paidForTransferredDebt = 0;

    if (paymentAmount <= currentYearFee) {
      // الدفع يغطي فقط جزء من القسط الحالي
      paidForCurrentYear = paymentAmount;
    } else if (paymentAmount <= currentYearFee + transferredDebt) {
      // الدفع يغطي القسط الحالي وجزء من الدين المنقول
      paidForCurrentYear = currentYearFee;
      paidForTransferredDebt = paymentAmount - currentYearFee;
    } else {
      // الدفع يغطي كل شيء وأكثر
      paidForCurrentYear = currentYearFee;
      paidForTransferredDebt = transferredDebt;
    }

    return {
      'paid_for_current_year': paidForCurrentYear,
      'paid_for_transferred_debt': paidForTransferredDebt,
    };
  }
}
