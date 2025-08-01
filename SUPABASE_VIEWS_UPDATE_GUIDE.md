# تحديث البيانات في Supabase - دليل التطبيق

## 🎯 الهدف
إنشاء Views في Supabase وتحديث البيانات بها لتوفير إحصائيات شاملة وحالة الترخيص المحدثة.

## 📋 الخطوات المطلوبة

### 1. إنشاء الـ Views في Supabase
```sql
-- تشغيل الملف في Supabase SQL Editor
supabase_views_setup.sql
```

### 2. استخدام خدمة تحديث البيانات
```dart
import 'package:your_app/services/supabase_data_updater.dart';

// تحديث جميع البيانات
await SupabaseDataUpdater.updateAllDataInSupabase();

// جلب الإحصائيات الشاملة
final stats = await SupabaseDataUpdater.getComprehensiveStats();

// طباعة تقرير شامل
await SupabaseDataUpdater.printComprehensiveReport();

// اختبار شامل للنظام
await SupabaseDataUpdater.runCompleteSystemTest();
```

### 3. استخدام Views Supabase الجديدة
```dart
import 'package:your_app/services/supabase_license_service.dart';

// جلب الإحصائيات العامة
final generalStats = await SupabaseLicenseService.getAllLicenseStats();

// جلب حالة الترخيص للمؤسسة
final licenseStatus = await SupabaseLicenseService.getLicenseStatusView(schoolId);

// جلب جميع حالات التراخيص
final allStatuses = await SupabaseLicenseService.getAllLicenseStatusViews();

// البحث في حالات الترخيص
final searchResults = await SupabaseLicenseService.searchLicenseStatus("اسم المدرسة");
```

## 🔧 الميزات المتوفرة

### Views المنشأة
1. **license_status_view**: عرض حالة الترخيص مع معلومات الجهاز والمزامنة
2. **license_stats_view**: إحصائيات شاملة لجميع التراخيص

### الطرق الجديدة
- `getAllLicenseStats()`: جلب إحصائيات شاملة
- `getLicenseStatusView()`: جلب حالة ترخيص مؤسسة محددة
- `getAllLicenseStatusViews()`: جلب جميع حالات التراخيص
- `searchLicenseStatus()`: البحث في حالات الترخيص
- `updateLastDeviceSync()`: تحديث وقت المزامنة

### خدمة التحديث الشاملة
- `updateAllDataInSupabase()`: تحديث جميع البيانات
- `scheduleDataUpdate()`: جدولة التحديث الدوري
- `getComprehensiveStats()`: جلب إحصائيات شاملة
- `printComprehensiveReport()`: طباعة تقرير مفصل
- `runCompleteSystemTest()`: اختبار شامل للنظام

## 📊 البيانات المتوفرة في Views

### license_status_view
```sql
- id: معرف المؤسسة
- organization_name: اسم المؤسسة
- email: البريد الإلكتروني
- subscription_status: حالة الاشتراك
- subscription_plan: خطة الاشتراك
- trial_expires_at: تاريخ انتهاء التجربة
- device_fingerprint: بصمة الجهاز
- device_status: حالة الجهاز (مُعرَّف/غير مُعرَّف)
- activation_code_status: حالة كود التفعيل (موجود/غير موجود)
- last_device_sync: آخر مزامنة للجهاز
- sync_freshness: حداثة المزامنة (حديث/متوسط/قديم/لم يتم المزامنة)
- created_at: تاريخ الإنشاء
- updated_at: تاريخ آخر تحديث
```

### license_stats_view
```sql
- total_organizations: إجمالي المؤسسات
- active_count: عدد المؤسسات النشطة
- trial_count: عدد المؤسسات التجريبية
- expired_count: عدد المؤسسات المنتهية الصلاحية
- devices_registered: عدد الأجهزة المسجلة
- recently_synced: عدد المؤسسات المتزامنة حديثاً
- avg_days_since_sync: متوسط أيام عدم المزامنة
```

## 🔄 التحديث الدوري
```dart
// بدء التحديث الدوري (كل 5 دقائق)
SupabaseDataUpdater.scheduleDataUpdate();
```

## 🧪 الاختبار
```dart
// اختبار شامل للنظام
await SupabaseDataUpdater.runCompleteSystemTest();
```

## ⚠️ ملاحظات مهمة
1. تأكد من تشغيل `supabase_views_setup.sql` في Supabase SQL Editor أولاً
2. الخدمة تعمل في وضع offline-first مع المزامنة عند توفر الإنترنت
3. يمكن استخدام القيم الافتراضية للإحصائيات حتى يتم ربط البيانات الحقيقية
4. التحديث الدوري اختياري ويمكن إيقافه حسب الحاجة

## 🎉 الاستخدام السريع
```dart
// للبدء السريع
await SupabaseDataUpdater.updateAllDataInSupabase();
await SupabaseDataUpdater.printComprehensiveReport();
```
