import 'package:isar/isar.dart';
import '../localdatabase/student_discount.dart';
import '../localdatabase/discount_type.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_fee_status.dart';

class DiscountHelper {
  final Isar isar;

  DiscountHelper(this.isar);

  /// إضافة خصم لطالب وتحديث حالة القسط
  Future<bool> addDiscountToStudent({
    required String studentId,
    required String discountType,
    required double discountValue,
    required bool isPercentage,
    required String academicYear,
    String? notes,
    String? addedBy,
    DateTime? expiryDate,
  }) async {
    try {
      // التحقق من وجود خصم مسبق لنفس الطالب ونفس النوع ونفس السنة
      final existingDiscount = await isar.studentDiscounts
          .filter()
          .studentIdEqualTo(studentId)
          .discountTypeEqualTo(discountType)
          .academicYearEqualTo(academicYear)
          .isActiveEqualTo(true)
          .findFirst();

      if (existingDiscount != null) {
        // تحديث الخصم الموجود
        await isar.writeTxn(() async {
          existingDiscount.discountValue = discountValue;
          existingDiscount.isPercentage = isPercentage;
          existingDiscount.notes = notes;
          existingDiscount.addedBy = addedBy;
          existingDiscount.expiryDate = expiryDate;
          await isar.studentDiscounts.put(existingDiscount);
        });
      } else {
        // إنشاء خصم جديد
        final discount = StudentDiscount()
          ..studentId = studentId
          ..discountType = discountType
          ..discountValue = discountValue
          ..isPercentage = isPercentage
          ..academicYear = academicYear
          ..notes = notes
          ..addedBy = addedBy
          ..expiryDate = expiryDate
          ..isActive = true
          ..createdAt = DateTime.now();

        await isar.writeTxn(() async {
          await isar.studentDiscounts.put(discount);
          
          // ربط الخصم بالطالب
          final student = await isar.students.get(int.parse(studentId));
          if (student != null) {
            discount.student.value = student;
            await discount.student.save();
          }
        });
      }

      // تحديث حالة القسط بالخصم الجديد مع إعادة حساب إجمالي الخصومات
      await _updateFeeStatusWithDiscount(studentId, academicYear);
      
      return true;
    } catch (e) {
      print('خطأ في إضافة الخصم: $e');
      return false;
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

  /// تحديث حالة القسط بالخصومات
  Future<void> _updateFeeStatusWithDiscount(String studentId, String academicYear) async {
    try {
      final feeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(studentId)
          .academicYearEqualTo(academicYear)
          .findFirst();

      if (feeStatus != null) {
        final originalFee = feeStatus.annualFee;
        final totalDiscount = await calculateTotalDiscount(
          studentId: studentId,
          academicYear: academicYear,
          originalFee: originalFee,
        );

        await isar.writeTxn(() async {
          feeStatus.discountAmount = totalDiscount;
          feeStatus.dueAmount = (originalFee + feeStatus.transferredDebtAmount) - 
                               totalDiscount - feeStatus.paidAmount;
          await isar.studentFeeStatus.put(feeStatus);
        });

        print('✅ تم تحديث حالة القسط:');
        print('- القسط الأصلي: $originalFee د.ع');
        print('- إجمالي الخصم: $totalDiscount د.ع');
        print('- المبلغ المتبقي الجديد: ${feeStatus.dueAmount} د.ع');
      } else {
        print('⚠️ لم يتم العثور على سجل قسط للطالب $studentId في السنة $academicYear');
      }
    } catch (e) {
      print('خطأ في تحديث حالة القسط: $e');
    }
  }

  /// جلب الخصومات النشطة لطالب في سنة دراسية محددة
  Future<List<StudentDiscount>> getActiveDiscounts({
    required String studentId,
    required String academicYear,
  }) async {
    return await isar.studentDiscounts
        .filter()
        .studentIdEqualTo(studentId)
        .academicYearEqualTo(academicYear)
        .isActiveEqualTo(true)
        .findAll();
  }

  /// إلغاء تفعيل خصم
  Future<bool> deactivateDiscount(int discountId) async {
    try {
      final discount = await isar.studentDiscounts.get(discountId);
      if (discount != null) {
        await isar.writeTxn(() async {
          discount.isActive = false;
          await isar.studentDiscounts.put(discount);
        });

        // تحديث حالة القسط
        await _updateFeeStatusWithDiscount(discount.studentId, discount.academicYear);
        return true;
      }
      return false;
    } catch (e) {
      print('خطأ في إلغاء تفعيل الخصم: $e');
      return false;
    }
  }

  /// إنشاء أنواع خصومات افتراضية
  Future<void> createDefaultDiscountTypes() async {
    final defaultTypes = [
      {
        'name': 'طلاب متفوقين',
        'description': 'خصم للطلاب المتفوقين دراسياً',
        'defaultValue': 10.0,
        'defaultIsPercentage': true,
        'color': '#4CAF50',
      },
      {
        'name': 'أيتام',
        'description': 'خصم للطلاب الأيتام',
        'defaultValue': 50.0,
        'defaultIsPercentage': true,
        'color': '#FF9800',
      },
      {
        'name': 'ذوي إعاقة',
        'description': 'خصم للطلاب ذوي الاحتياجات الخاصة',
        'defaultValue': 30.0,
        'defaultIsPercentage': true,
        'color': '#9C27B0',
      },
      {
        'name': 'أبناء موظفين',
        'description': 'خصم لأبناء موظفي المدرسة',
        'defaultValue': 25.0,
        'defaultIsPercentage': true,
        'color': '#2196F3',
      },
      {
        'name': 'أكثر من طالب من نفس العائلة',
        'description': 'خصم عند وجود أكثر من طالب من نفس العائلة',
        'defaultValue': 15.0,
        'defaultIsPercentage': true,
        'color': '#607D8B',
      },
      {
        'name': 'خصم خاص',
        'description': 'خصم خاص لحالات استثنائية',
        'defaultValue': 0.0,
        'defaultIsPercentage': false,
        'color': '#F44336',
      },
    ];

    await isar.writeTxn(() async {
      for (int i = 0; i < defaultTypes.length; i++) {
        final type = defaultTypes[i];
        
        // تحقق من عدم وجود النوع مسبقاً
        final existing = await isar.discountTypes
            .filter()
            .nameEqualTo(type['name'] as String)
            .findFirst();

        if (existing == null) {
          final discountType = DiscountType()
            ..name = type['name'] as String
            ..description = type['description'] as String
            ..defaultValue = type['defaultValue'] as double
            ..defaultIsPercentage = type['defaultIsPercentage'] as bool
            ..color = type['color'] as String
            ..sortOrder = i
            ..isActive = true
            ..createdAt = DateTime.now();

          await isar.discountTypes.put(discountType);
        }
      }
    });
  }

  /// جلب جميع أنواع الخصومات النشطة
  Future<List<DiscountType>> getActiveDiscountTypes() async {
    return await isar.discountTypes
        .filter()
        .isActiveEqualTo(true)
        .sortBySortOrder()
        .findAll();
  }

  /// إضافة نوع خصم جديد
  Future<bool> addDiscountType({
    required String name,
    String? description,
    double? defaultValue,
    bool defaultIsPercentage = false,
    String? color,
  }) async {
    try {
      // تحقق من عدم وجود اسم مشابه
      final existing = await isar.discountTypes
          .filter()
          .nameEqualTo(name)
          .findFirst();

      if (existing != null) {
        return false; // الاسم موجود مسبقاً
      }

      // جلب أكبر ترتيب موجود
      final lastType = await isar.discountTypes
          .where()
          .sortBySortOrderDesc()
          .findFirst();

      final newSortOrder = (lastType?.sortOrder ?? -1) + 1;

      final discountType = DiscountType()
        ..name = name
        ..description = description
        ..defaultValue = defaultValue
        ..defaultIsPercentage = defaultIsPercentage
        ..color = color ?? '#2196F3'
        ..sortOrder = newSortOrder
        ..isActive = true
        ..createdAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.discountTypes.put(discountType);
      });

      return true;
    } catch (e) {
      print('خطأ في إضافة نوع الخصم: $e');
      return false;
    }
  }

  /// دالة مساعدة لإنشاء سجلات أقساط لجميع الطلاب للسنة الحالية
  Future<void> createMissingFeeStatuses(String academicYear) async {
    try {
      print('🔄 البحث عن الطلاب الذين يحتاجون سجلات أقساط...');
      
      final allStudents = await isar.students.where().findAll();
      int createdCount = 0;
      
      for (final student in allStudents) {
        final hasStatus = await isar.studentFeeStatus
            .filter()
            .studentIdEqualTo(student.id.toString())
            .academicYearEqualTo(academicYear)
            .findFirst();
            
        if (hasStatus == null) {
          final success = await createFeeStatusIfNotExists(
            student.id.toString(), 
            academicYear
          );
          if (success) {
            createdCount++;
          }
        }
      }
      
      print('✅ تم إنشاء $createdCount سجل قسط جديد');
    } catch (e) {
      print('❌ خطأ في إنشاء سجلات الأقساط: $e');
    }
  }

  /// إنشاء سجل قسط لطالب إذا لم يكن موجوداً
  Future<bool> createFeeStatusIfNotExists(String studentId, String academicYear) async {
    try {
      // التحقق من وجود سجل قسط
      final existingFeeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(studentId)
          .academicYearEqualTo(academicYear)
          .findFirst();

      if (existingFeeStatus != null) {
        return true; // السجل موجود مسبقاً
      }

      // جلب بيانات الطالب
      final student = await isar.students.get(int.parse(studentId));
      if (student == null) {
        print('❌ لم يتم العثور على الطالب $studentId');
        return false;
      }

      // تحميل بيانات الصف
      await student.schoolclass.load();
      final schoolClass = student.schoolclass.value;
      
      if (schoolClass == null) {
        print('❌ الطالب $studentId غير مرتبط بصف دراسي');
        return false;
      }

      // إنشاء سجل قسط جديد
      final feeStatus = StudentFeeStatus()
        ..studentId = studentId
        ..className = schoolClass.name
        ..academicYear = academicYear
        ..annualFee = student.annualFee ?? schoolClass.annualFee ?? 0.0
        ..dueAmount = student.annualFee ?? schoolClass.annualFee ?? 0.0
        ..paidAmount = 0.0
        ..discountAmount = 0.0
        ..transferredDebtAmount = 0.0
        ..originalDebtAcademicYear = ''
        ..originalDebtClassName = ''
        ..createdAt = DateTime.now()
        ..student.value = student;

      await isar.writeTxn(() async {
        await isar.studentFeeStatus.put(feeStatus);
        await feeStatus.student.save();
      });

      print('✅ تم إنشاء سجل قسط جديد للطالب $studentId في السنة $academicYear');
      return true;
    } catch (e) {
      print('❌ خطأ في إنشاء سجل القسط: $e');
      return false;
    }
  }
}