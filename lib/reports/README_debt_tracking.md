## نظام تتبع الديون المنقولة

تم تطوير نظام محسن لإدارة وتتبع الديون المنقولة بين السنوات الدراسية مع الحفاظ على دقة التقارير السنوية.

### الحقول الجديدة المضافة إلى `StudentFeeStatus`:

```dart
// حقول لتتبع الديون المنقولة من سنوات سابقة
double transferredDebtAmount = 0; // المبلغ المنقول من سنة سابقة
String? originalDebtAcademicYear; // السنة الدراسية الأصلية للدين
String? originalDebtClassName; // الصف الأصلي للدين
```

### المميزات الجديدة:

#### 1. ترحيل محسن للطلاب:
- **تتبع أصل الدين**: عند نقل دين من سنة سابقة، يتم تسجيل السنة والصف الأصلي
- **خيارات المعالجة**: 
  - دفع الدين السابق بالكامل
  - نقل الدين مع القسط الجديد
- **حفظ التسلسل**: الحفاظ على رابط الدين بسنته الأصلية

#### 2. تقارير مالية دقيقة:
```dart
// مثال على استخدام DebtTrackingHelper
final helper = DebtTrackingHelper(isar);

// حساب المحصل الفعلي للسنة (بدون الديون المنقولة)
final collectedThisYear = await helper.getTotalCollectedForYear('2024-2025');

// حساب الديون المنقولة المحصلة من سنة معينة
final transferredCollected = await helper.getTransferredDebtCollectedFromYear('2023-2024');

// تقرير شامل للسنة
final report = await helper.getYearlyFinancialReport('2024-2025');
```

#### 3. إدارة الدفعات المحسنة:
- **توزيع الدفعات**: عند دفع قسط، يتم توزيع المبلغ بين القسط الحالي والدين المنقول
- **تتبع المصدر**: معرفة من أي سنة تم تحصيل كل جزء من الدفعة

#### 4. تقارير متخصصة:
- **تقرير الديون المنقولة**: عرض جميع الديون المنقولة مع تفاصيل مصادرها
- **تقرير التحصيل السنوي**: فصل التحصيل من السنة الحالية عن المنقول

### كيفية الاستخدام:

#### 1. ترحيل طالب:
```dart
final transferHelper = StudentTransferHelper(isar);
final success = await transferHelper.transferStudent(
  student: student,
  newClass: newClass,
  newAnnualFee: newFee,
  newAcademicYear: '2024-2025',
  currentAcademicYear: '2023-2024',
  debtHandlingAction: 'move_due', // أو 'pay_all'
);
```

#### 2. عرض تقرير الديون المنقولة:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TransferredDebtsReportScreen(isar: isar),
  ),
);
```

#### 3. عرض التقرير المالي السنوي:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => YearlyFinancialReportScreen(isar: isar),
  ),
);
```

### الفوائد:

1. **دقة التقارير**: كل سنة دراسية لها تقرير مالي دقيق منفصل
2. **تتبع المصدر**: معرفة مصدر كل دين ومتى نشأ
3. **مرونة الإدارة**: خيارات متعددة للتعامل مع الديون عند الترحيل
4. **تقارير متخصصة**: تقارير منفصلة للديون المنقولة والتحصيل السنوي
5. **حفظ البيانات التاريخية**: عدم فقدان معلومات الديون الأصلية

### مثال عملي:

إذا كان طالب في الصف الأول لعام 2023-2024 وعليه دين 50,000 د.ع، وتم ترحيله للصف الثاني في عام 2024-2025:

- **السجل الجديد** سيحتوي على:
  - `annualFee`: 100,000 (قسط الصف الثاني)
  - `transferredDebtAmount`: 50,000
  - `originalDebtAcademicYear`: "2023-2024"
  - `originalDebtClassName`: "الصف الأول"
  - `dueAmount`: 150,000 (القسط الجديد + الدين المنقول)

- **التقارير** ستظهر:
  - تقرير 2023-2024: دين متبقي 0 (تم نقله)
  - تقرير 2024-2025: دين أصلي 100,000 + دين منقول 50,000
  - تقرير الديون المنقولة: 50,000 من 2023-2024

هذا النظام يضمن دقة المحاسبة ويسهل متابعة الأداء المالي لكل سنة دراسية بشكل منفصل.
