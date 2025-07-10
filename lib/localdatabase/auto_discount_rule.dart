import 'package:isar/isar.dart';

@collection
class AutoDiscountRule {
  Id id = Isar.autoIncrement;
  
  late String name;
  
  @enumerated
  late AutoDiscountType type;
  
  late double percentage;
  
  late double fixedAmount;
  
  late String conditions; // JSON string للشروط
  
  late bool isActive;
  
  late DateTime validFrom;
  
  late DateTime validTo;
  
  late DateTime createdAt;
  
  late DateTime updatedAt;
  
  String? description;
  
  int priority = 0; // أولوية التطبيق
  
  bool applyToExistingStudents = false;
  
  double? maxDiscountAmount; // حد أقصى للخصم
  
  List<String> applicableGrades = []; // الصفوف المطبقة عليها
  
  List<String> applicableClasses = []; // الفصول المطبقة عليها
}

enum AutoDiscountType {
  sibling,
  earlyPayment,
  fullPayment,
  academicPerformance,
  financialNeed,
  loyalty,
  bulkPayment,
  custom
}

// نموذج الشروط - مبسط
class DiscountConditions {
  // شروط خصم الأشقاء
  int? minSiblings;
  int? maxSiblings;
  
  // شروط الدفع المبكر
  int? daysBeforeStart;
  DateTime? paymentDeadline;
  
  // شروط الدفع الكامل
  bool? requiresFullPayment;
  int? paymentInstallments;
  
  // شروط الأداء الأكاديمي
  double? minGPA;
  int? minRank;
  
  // شروط مالية
  double? minAnnualFee;
  double? maxAnnualFee;
  
  // شروط الولاء
  int? minYearsInSchool;
  
  DiscountConditions({
    this.minSiblings,
    this.maxSiblings,
    this.daysBeforeStart,
    this.paymentDeadline,
    this.requiresFullPayment,
    this.paymentInstallments,
    this.minGPA,
    this.minRank,
    this.minAnnualFee,
    this.maxAnnualFee,
    this.minYearsInSchool,
  });
  
  factory DiscountConditions.fromJson(Map<String, dynamic> json) {
    return DiscountConditions(
      minSiblings: json['minSiblings'],
      maxSiblings: json['maxSiblings'],
      daysBeforeStart: json['daysBeforeStart'],
      paymentDeadline: json['paymentDeadline'] != null 
          ? DateTime.parse(json['paymentDeadline']) 
          : null,
      requiresFullPayment: json['requiresFullPayment'],
      paymentInstallments: json['paymentInstallments'],
      minGPA: json['minGPA']?.toDouble(),
      minRank: json['minRank'],
      minAnnualFee: json['minAnnualFee']?.toDouble(),
      maxAnnualFee: json['maxAnnualFee']?.toDouble(),
      minYearsInSchool: json['minYearsInSchool'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'minSiblings': minSiblings,
      'maxSiblings': maxSiblings,
      'daysBeforeStart': daysBeforeStart,
      'paymentDeadline': paymentDeadline?.toIso8601String(),
      'requiresFullPayment': requiresFullPayment,
      'paymentInstallments': paymentInstallments,
      'minGPA': minGPA,
      'minRank': minRank,
      'minAnnualFee': minAnnualFee,
      'maxAnnualFee': maxAnnualFee,
      'minYearsInSchool': minYearsInSchool,
    };
  }
}

// نموذج تطبيق الخصم - مبسط
class DiscountApplication {
  String ruleId;
  String studentId;
  String academicYear;
  double calculatedAmount;
  double appliedAmount;
  DateTime appliedAt;
  String? reason;
  Map<String, dynamic>? metadata;
  
  DiscountApplication({
    required this.ruleId,
    required this.studentId,
    required this.academicYear,
    required this.calculatedAmount,
    required this.appliedAmount,
    required this.appliedAt,
    this.reason,
    this.metadata,
  });
  
  factory DiscountApplication.fromJson(Map<String, dynamic> json) {
    return DiscountApplication(
      ruleId: json['ruleId'],
      studentId: json['studentId'],
      academicYear: json['academicYear'],
      calculatedAmount: json['calculatedAmount'].toDouble(),
      appliedAmount: json['appliedAmount'].toDouble(),
      appliedAt: DateTime.parse(json['appliedAt']),
      reason: json['reason'],
      metadata: json['metadata'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'studentId': studentId,
      'academicYear': academicYear,
      'calculatedAmount': calculatedAmount,
      'appliedAmount': appliedAmount,
      'appliedAt': appliedAt.toIso8601String(),
      'reason': reason,
      'metadata': metadata,
    };
  }
}
