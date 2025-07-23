# دليل نظام الاشتراكات ومزامنة التقارير

## نظرة عامة

تم تطوير نظام شامل لإدارة الاشتراكات ومزامنة التقارير السحابية. النظام يوفر:

- **الميزات الأساسية**: مجانية ومتاحة دائماً
- **مزامنة التقارير**: خدمة مدفوعة (50 ريال شهرياً)
- **الفحص التلقائي**: للاشتراكات المنتهية
- **المزامنة الاختيارية**: حسب الطلب وحالة الاشتراك

## الملفات المنشأة/المحدثة

### 1. خدمة الاشتراكات
**الملف**: `lib/services/subscription_service.dart`

#### الدوال الرئيسية:
- `getReportsSyncStatus()`: فحص حالة اشتراك مزامنة التقارير
- `activateReportsSync()`: تفعيل اشتراك جديد
- `cancelReportsSync()`: إلغاء الاشتراك
- `renewReportsSync()`: تجديد الاشتراك
- `checkExpiredSubscriptions()`: فحص الاشتراكات المنتهية
- `getSubscriptionsInfo()`: معلومات شاملة عن الاشتراكات

### 2. خدمة مزامنة التقارير
**الملف**: `lib/services/reports_sync_service.dart`

#### الدوال الرئيسية:
- `syncReportsWithSupabase()`: مزامنة التقارير (تتطلب اشتراك)
- `getCloudReports()`: الحصول على التقارير من السحابة
- `uploadReportToCloud()`: رفع تقرير للسحابة
- `canSyncReports()`: فحص إمكانية المزامنة
- `getSyncStatusReport()`: تقرير حالة المزامنة
- `periodicSubscriptionCheck()`: فحص دوري للاشتراكات

### 3. واجهة إدارة الاشتراكات
**الملف**: `lib/screens/subscription_management_screen.dart`

#### المكونات:
- عرض معلومات المدرسة
- بطاقة الميزات الأساسية (مجانية)
- بطاقة مزامنة التقارير (مدفوعة)
- بطاقة حالة المزامنة
- أزرار التفعيل/الإلغاء/التجديد/المزامنة

### 4. تحديثات قاعدة البيانات
**الملف**: `lib/localdatabase/school.dart`

#### الحقول الجديدة:
```dart
String? reportsSyncSubscription; // JSON للتفاصيل
bool reportsSyncActive = false;
DateTime? reportsSyncExpiryDate;
```

### 5. تحديثات خدمة Supabase
**الملف**: `lib/services/supabase_service.dart`

#### الدوال الجديدة:
- `createSubscription()`: إنشاء اشتراك جديد
- `getSubscriptionStatus()`: الحصول على حالة الاشتراك
- `cancelSubscription()`: إلغاء الاشتراك
- `getOrganizationSubscriptions()`: جميع اشتراكات المؤسسة
- `getOrganizationReports()`: التقارير من السحابة
- `uploadReportToCloud()`: رفع تقرير للسحابة

### 6. قاعدة بيانات Supabase
**الملف**: `subscription_database_setup.sql`

#### الجداول الجديدة:
- `organization_subscriptions`: جدول الاشتراكات
- `subscription_status_view`: عرض حالة الاشتراكات
- `subscription_stats_view`: إحصائيات الاشتراكات

#### الدوال:
- `get_subscription_status()`: حالة اشتراك محدد
- `get_subscription_stats()`: إحصائيات شاملة
- `update_expired_subscriptions()`: تحديث المنتهية
- `get_expiring_subscriptions()`: الاشتراكات التي تنتهي قريباً
- `renew_subscription()`: تجديد الاشتراك

## كيفية الاستخدام

### 1. إعداد قاعدة البيانات
```sql
-- تشغيل الملف في محرر SQL في Supabase
\i subscription_database_setup.sql
```

### 2. في التطبيق - فحص حالة الاشتراك
```dart
final status = await SubscriptionService.getReportsSyncStatus();
if (status.isActive) {
  print('اشتراك مزامنة التقارير نشط');
  print('ينتهي في: ${status.daysRemaining} يوم');
} else {
  print('الاشتراك غير نشط: ${status.message}');
}
```

### 3. تفعيل اشتراك مزامنة التقارير
```dart
final result = await SubscriptionService.activateReportsSync(
  paymentMethod: 'credit_card',
  transactionId: 'TX123456',
  paymentDetails: {'card_last4': '1234'},
);

if (result.success) {
  print('تم تفعيل الاشتراك بنجاح');
} else {
  print('فشل التفعيل: ${result.message}');
}
```

### 4. مزامنة التقارير
```dart
// فحص إمكانية المزامنة أولاً
final canSync = await ReportsSyncService.canSyncReports();
if (canSync) {
  // تنفيذ المزامنة
  final result = await ReportsSyncService.syncReportsWithSupabase();
  if (result.success) {
    print('تمت المزامنة بنجاح');
    print('التفاصيل: ${result.syncDetails}');
  } else {
    print('فشلت المزامنة: ${result.message}');
    if (result.requiresSubscription) {
      print('تحتاج إلى اشتراك نشط');
    }
  }
} else {
  print('المزامنة غير متاحة - تحتاج اشتراك نشط');
}
```

### 5. رفع تقرير محدد للسحابة
```dart
final reportData = {
  'school_id': 1,
  'report_type': 'students',
  'report_title': 'تقرير الطلاب الشهري',
  'report_data': {'students_count': 150},
  'report_summary': {'total': 150, 'new': 10},
  'period_start': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
  'period_end': DateTime.now().toIso8601String(),
};

final success = await ReportsSyncService.uploadReportToCloud(reportData);
if (success) {
  print('تم رفع التقرير للسحابة');
} else {
  print('فشل في رفع التقرير');
}
```

### 6. الحصول على التقارير من السحابة
```dart
try {
  final reports = await ReportsSyncService.getCloudReports(
    reportType: 'students',
    fromDate: DateTime.now().subtract(Duration(days: 30)),
    toDate: DateTime.now(),
  );
  
  print('تم الحصول على ${reports.length} تقرير من السحابة');
  for (var report in reports) {
    print('التقرير: ${report['report_title']}');
  }
} catch (e) {
  print('خطأ في الحصول على التقارير: $e');
}
```

### 7. عرض واجهة إدارة الاشتراكات
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubscriptionManagementScreen(),
  ),
);
```

### 8. بدء الفحص الدوري للاشتراكات
```dart
// في main.dart بعد تهيئة قاعدة البيانات
await ReportsSyncService.startPeriodicSubscriptionCheck();
```

## حالات الاشتراك

### `isActive: true`
- الاشتراك نشط وصالح
- يمكن مزامنة التقارير
- يظهر تاريخ الانتهاء والأيام المتبقية

### `isActive: false`
- الاشتراك غير نشط أو منتهي
- المزامنة غير متاحة
- يظهر رسالة السبب

## التحقق من الأخطاء

### خطأ "تتطلب اشتراك نشط"
```dart
final status = await SubscriptionService.getReportsSyncStatus();
if (!status.isActive) {
  // إظهار خيارات التفعيل للمستخدم
  showActivationDialog();
}
```

### خطأ "غير مرتبط بالسحابة"
```dart
final info = await SubscriptionService.getSubscriptionsInfo();
if (info['organization_id'] == null) {
  // المدرسة غير مسجلة في النظام السحابي
  showCloudRegistrationDialog();
}
```

### فحص حالة المزامنة التفصيلية
```dart
final report = await ReportsSyncService.getSyncStatusReport();
print('حالة الاشتراك: ${report['subscription_active']}');
print('الاتصال بالسحابة: ${report['cloud_connected']}');
print('إمكانية المزامنة: ${report['can_sync']}');
print('آخر مزامنة: ${report['last_sync']}');
```

## الميزات المتقدمة

### 1. إحصائيات الاستخدام
```dart
// في Supabase
SELECT * FROM subscription_stats_view;
```

### 2. الاشتراكات التي تنتهي قريباً
```sql
SELECT * FROM get_expiring_subscriptions(7); -- خلال 7 أيام
```

### 3. تجديد تلقائي
```sql
SELECT renew_subscription(
  org_id := 1,
  feature_name := 'reports_sync',
  new_payment_method := 'auto_renewal',
  new_transaction_id := 'AUTO_' || extract(epoch from now()),
  new_amount := 50.00,
  extension_days := 30
);
```

## الأمان والصلاحيات

- **RLS مفعل**: كل مؤسسة تصل لبياناتها فقط
- **تشفير البيانات**: معلومات الدفع مشفرة
- **مراجعة العمليات**: جميع العمليات مسجلة
- **صلاحيات محدودة**: حسب دور المستخدم

## الخلاصة

النظام الآن يوفر:

✅ **نظام اشتراكات مرن ومتكامل**
✅ **مزامنة اختيارية للتقارير**
✅ **واجهة سهلة الاستخدام**
✅ **فحص تلقائي للانتهاء**
✅ **أمان وموثوقية عالية**
✅ **تقارير وإحصائيات مفصلة**

🎯 **الهدف محقق**: مزامنة التقارير أصبحت اختيارية ومدفوعة حسب الطلب!
