# دليل مزامنة الترخيص مع Supabase

## نظرة عامة

تم إضافة نظام شامل لمزامنة معلومات الترخيص مع قاعدة بيانات Supabase. يقوم النظام بحفظ ومزامنة:

- **بصمة الجهاز**: معرف فريد للجهاز المثبت عليه التطبيق
- **كود التفعيل**: الكود المشفر للتفعيل
- **حالة الاشتراك**: حالة الترخيص الحالية (trial/active/expired)

## الملفات المضافة/المحدثة

### 1. خدمة Supabase (`services/supabase_service.dart`)
تم إضافة الدوال التالية:

#### `createOrganizationWithSchool()`
- **محدثة**: تحفظ الآن بصمة الجهاز وكود التفعيل وحالة الاشتراك
- **معلومات إضافية**: 
  - `device_fingerprint`: بصمة الجهاز الحالي
  - `activation_code`: كود التفعيل المشفر
  - `subscription_status`: حالة الاشتراك (trial/active/expired)

#### `updateOrganizationLicense()`
- **جديدة**: تحديث معلومات الترخيص للمؤسسة
- **المعاملات**:
  - `organizationId`: معرف المؤسسة
  - `newSubscriptionStatus`: حالة الاشتراك الجديدة (اختياري)
  - `updateDeviceInfo`: تحديث بصمة الجهاز وكود التفعيل (اختياري)

#### `getOrganizationLicenseInfo()`
- **جديدة**: الحصول على معلومات الترخيص ومقارنتها مع الجهاز الحالي
- **تُرجع**: معلومات المؤسسة + مقارنة الجهاز + حالة المزامنة

### 2. خدمة مزامنة الترخيص (`services/license_sync_service.dart`)
خدمة جديدة ومتخصصة لإدارة مزامنة الترخيص:

#### `syncLicenseWithSupabase()`
- مزامنة حالة الترخيص المحلية مع السحابة
- تحديث بصمة الجهاز وكود التفعيل
- تحديث البيانات المحلية بعد المزامنة

#### `checkLicenseSync()`
- التحقق من تطابق معلومات الترخيص
- مقارنة بصمة الجهاز الحالية مع المحفوظة
- تحديد ما إذا كانت المزامنة مطلوبة

#### `periodicLicenseSync()`
- مزامنة دورية ذكية
- تتحقق من الحاجة للمزامنة أولاً
- تطبع تقرير مفصل عن حالة المزامنة

#### `getLicenseSyncReport()`
- تقرير تفصيلي عن حالة المزامنة
- مناسب لعرض معلومات الحالة في الواجهة

### 3. أمثلة الاستخدام (`services/license_sync_examples.dart`)
ملف شامل يحتوي على أمثلة عملية لكيفية استخدام النظام.

## كيفية الاستخدام

### 1. عند بدء التطبيق (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة قاعدة البيانات
  await initializeDatabase();
  
  // مزامنة الترخيص عند بدء التطبيق
  await LicenseSyncService.periodicLicenseSync();
  
  runApp(MyApp());
}
```

### 2. بعد تفعيل التطبيق (ActivationScreen)

```dart
Future<void> activateWithCode(String code) async {
  final success = await LicenseManager.activateWithCode(code);
  if (success) {
    // مزامنة التفعيل مع السحابة
    await LicenseSyncService.syncLicenseWithSupabase();
    
    // الانتقال للشاشة الرئيسية
    Navigator.pushReplacement(context, ...);
  }
}
```

### 3. في شاشة الإعدادات

```dart
// عرض حالة المزامنة
FutureBuilder<Widget>(
  future: LicenseSyncExamples.buildLicenseStatusWidget(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return snapshot.data!;
    }
    return CircularProgressIndicator();
  },
)
```

### 4. مزامنة دورية

```dart
// يمكن استدعاؤها كل فترة معينة
Timer.periodic(Duration(hours: 1), (timer) async {
  await LicenseSyncService.scheduledLicenseSync();
});
```

## حالات المزامنة

### `synced`
- معلومات الترخيص متزامنة بالكامل
- بصمة الجهاز تتطابق مع السحابة
- حالة الاشتراك محدثة

### `needs_sync`
- يحتاج مزامنة عامة
- قد تكون معلومات الترخيص قديمة

### `device_mismatch`
- بصمة الجهاز لا تتطابق مع المحفوظة في السحابة
- قد يكون الجهاز تغير أو تم نقل التطبيق

### `no_organization`
- لا توجد مؤسسة مرتبطة
- التطبيق يعمل في وضع محلي فقط

### `error`
- خطأ في عملية المزامنة
- مشكلة في الاتصال أو البيانات

## البيانات المحفوظة في Supabase

في جدول `educational_organizations`:

```sql
ALTER TABLE educational_organizations ADD COLUMN IF NOT EXISTS device_fingerprint TEXT;
ALTER TABLE educational_organizations ADD COLUMN IF NOT EXISTS activation_code TEXT;
ALTER TABLE educational_organizations ADD COLUMN IF NOT EXISTS last_device_sync TIMESTAMP;
```

- `device_fingerprint`: بصمة الجهاز المشفرة
- `activation_code`: كود التفعيل المشفر
- `subscription_status`: حالة الاشتراك (trial/active/expired)
- `last_device_sync`: آخر وقت مزامنة لبيانات الجهاز

## التحديثات المطلوبة في قاعدة البيانات

تأكد من إضافة الأعمدة الجديدة لجدول `educational_organizations`:

```sql
-- إضافة أعمدة معلومات الترخيص
ALTER TABLE educational_organizations 
ADD COLUMN IF NOT EXISTS device_fingerprint TEXT,
ADD COLUMN IF NOT EXISTS activation_code TEXT,
ADD COLUMN IF NOT EXISTS last_device_sync TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- فهرس للبحث السريع بواسطة بصمة الجهاز
CREATE INDEX IF NOT EXISTS idx_educational_organizations_device_fingerprint 
ON educational_organizations(device_fingerprint);
```

## الفوائد

1. **تتبع الأجهزة**: معرفة الأجهزة المفعلة لكل مؤسسة
2. **مكافحة النسخ**: منع استخدام التطبيق على أجهزة غير مصرح بها
3. **المزامنة التلقائية**: تحديث حالة الترخيص تلقائياً
4. **تقارير مفصلة**: معلومات واضحة عن حالة كل مؤسسة
5. **سهولة الصيانة**: أدوات مزامنة سهلة الاستخدام

## استكشاف الأخطاء

### مشكلة عدم المزامنة
```dart
// فحص حالة المزامنة
final report = await LicenseSyncService.getLicenseSyncReport();
print('حالة المزامنة: ${report['message']}');

// إجبار المزامنة
await LicenseSyncService.syncLicenseWithSupabase();
```

### مشكلة عدم تطابق الجهاز
```dart
// تحديث معلومات الجهاز
await SupabaseService.updateOrganizationLicense(
  organizationId: orgId,
  updateDeviceInfo: true,
);
```

### مشكلة حالة الاشتراك
```dart
// تحديث حالة الاشتراك يدوياً
await SupabaseService.updateOrganizationLicense(
  organizationId: orgId,
  newSubscriptionStatus: 'active',
);
```
