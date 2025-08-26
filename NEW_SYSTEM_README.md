# نظام إدارة المدارس - الإصدار المحسن 2.0

## 🚀 نظرة عامة

تم إعادة تصميم نظام إدارة المدارس بالكامل ليكون أكثر تنظيماً وموثوقية وسهولة في الصيانة. النظام الجديد يتبع مبادئ البرمجة النظيفة ويوفر خدمات منفصلة لكل وظيفة.

## 📁 هيكل النظام الجديد

### خدمات النظام (`lib/services/`)

#### 1. `database_service.dart` - خدمة قاعدة البيانات الأساسية
- إدارة الاتصال مع Supabase
- آلية إعادة المحاولة عند فشل الشبكة
- تشفير كلمات المرور
- فحص حالة قاعدة البيانات

```dart
// استخدام الخدمة
await DatabaseService.initialize();
final isConnected = DatabaseService.isEnabled;
```

#### 2. `device_service.dart` - خدمة إدارة الأجهزة
- جمع معلومات الجهاز (Android, iOS, Windows, Linux, macOS)
- إنشاء بصمة فريدة للجهاز
- التحقق من أن الجهاز حقيقي وليس محاكي

```dart
// استخدام الخدمة
final deviceInfo = await DeviceService.getDisplayInfo();
final fingerprint = await DeviceService.generateDeviceFingerprint();
```

#### 3. `organization_service.dart` - خدمة المؤسسات التعليمية
- إنشاء المؤسسات والمدارس والمستخدمين
- إدارة بيانات الطلاب
- إنشاء مؤسسة متكاملة بعملية واحدة

```dart
// إنشاء مؤسسة متكاملة
final result = await OrganizationService.createCompleteOrganization(
  organizationName: "مدرسة النهضة",
  organizationEmail: "admin@school.edu",
  schoolName: "الإعدادية المركزية",
  schoolType: "مختلط",
  adminName: "أحمد محمد",
  adminEmail: "ahmed@school.edu",
  adminPassword: "securepassword",
);
```

#### 4. `subscription_service.dart` - خدمة الاشتراكات والتراخيص
- إدارة حالة الاشتراكات
- شراء الميزات الإضافية
- التحقق من صلاحيات الوصول

```dart
// التحقق من الاشتراك
final status = await SubscriptionService.checkOrganizationSubscriptionStatus(orgId);
final hasOnlineReports = status['has_online_reports'];
```

#### 5. `reports_service.dart` - خدمة التقارير
- رفع التقارير إلى قاعدة البيانات
- جلب التقارير المحفوظة
- إحصائيات التقارير
- التحقق من صلاحيات التقارير الأونلاين

```dart
// رفع تقرير
final result = await ReportsService.uploadOrganizationReport(
  organizationId: 1,
  reportType: "financial",
  reportTitle: "التقرير المالي الشهري",
  reportData: reportData,
  period: "2024-01",
  generatedBy: "النظام",
);
```

#### 6. `unified_service.dart` - الخدمة الموحدة
- تهيئة النظام بالكامل
- فحص حالة جميع الخدمات
- تشخيص شامل للنظام
- إعادة تعيين النظام

```dart
// تهيئة النظام
final result = await UnifiedService.initializeSystem();
if (result['success']) {
  print('تم تهيئة النظام بنجاح');
}

// تشخيص شامل
final diagnostic = await UnifiedService.performSystemDiagnostic();
print('مستوى الصحة: ${diagnostic['health_level']}');
```

#### 7. `system_bridge.dart` - جسر التوافق
- ربط النظام الجديد بالكود القديم
- توفير واجهات متوافقة للخلف
- تسهيل عملية الانتقال

### الشاشات الجديدة (`lib/screens/`)

#### 1. `system_status_screen.dart` - شاشة حالة النظام
- عرض حالة جميع الخدمات
- نتائج التشخيص الشامل
- إحصائيات النظام

### الاختبارات (`lib/tests/`)

#### 1. `quick_system_test_screen.dart` - اختبار سريع للنظام
- اختبار تهيئة النظام
- فحص حالة الخدمات
- تشخيص شامل
- عرض ملخص النظام

## 🔧 المميزات الجديدة

### 1. إدارة أفضل للأخطاء
- آلية إعادة المحاولة عند فشل الشبكة
- رسائل خطأ واضحة ومفيدة
- تسجيل مفصل للأحداث

### 2. دعم منصات متعددة
- Android و iOS للهواتف الذكية
- Windows للحاسوب الشخصي
- Linux و macOS للأنظمة الأخرى

### 3. نظام تشخيص شامل
- فحص حالة قاعدة البيانات
- اختبار الاتصال بالشبكة
- التحقق من صحة الجهاز
- تحليل الاشتراكات والميزات

### 4. تحسينات الأمان
- تشفير كلمات المرور بـ SHA-256
- بصمة فريدة لكل جهاز
- التحقق من صحة الأجهزة

### 5. إدارة محسنة للتقارير
- رفع التقارير بأمان
- فلترة وبحث متقدم
- إحصائيات مفصلة
- تنظيف التقارير القديمة

## 🚀 كيفية الاستخدام

### 1. تهيئة النظام

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل التطبيق مع شاشة التهيئة
  runApp(SchoolManagementApp());
}
```

### 2. فحص حالة النظام

```dart
// في أي مكان في التطبيق
final systemSummary = await UnifiedService.getSystemSummary();
print('حالة النظام: ${systemSummary['system_health']}');
```

### 3. استخدام الخدمات

```dart
// إنشاء مؤسسة جديدة
final orgResult = await OrganizationService.createOrganization(
  name: "مدرستي",
  email: "info@myschool.edu",
);

// التحقق من الاشتراك
final subscription = await SubscriptionService.checkOrganizationSubscriptionStatus(orgId);

// رفع تقرير
final reportResult = await ReportsService.uploadReport(reportData);
```

## 🔄 التوافق مع النظام القديم

يوفر النظام الجديد جسر توافق (`SystemBridge`) يضمن عمل الكود القديم بدون تغييرات:

```dart
// استخدام الطرق القديمة (لا تزال تعمل)
final result = await SystemBridge.createOrganizationWithSchool(...);
final isEnabled = await SystemBridge.checkOnlineReportsSubscription();
```

## 📊 التشخيص والمراقبة

### شاشة حالة النظام
- الوصول عبر: Settings > System Status
- عرض حالة جميع الخدمات
- نتائج التشخيص الشامل

### اختبار سريع للنظام
- الوصول عبر: Settings > Quick Test
- اختبار شامل لجميع المكونات
- نتائج فورية بالألوان

### سجلات النظام
```dart
// تفعيل السجلات المفصلة
print('🔄 بدء العملية...');
print('✅ نجحت العملية');
print('❌ فشلت العملية');
```

## 🛠️ الصيانة والتطوير

### إضافة خدمة جديدة
1. إنشاء ملف خدمة في `lib/services/`
2. تنفيذ الوظائف المطلوبة
3. إضافة الخدمة إلى `UnifiedService`
4. تحديث `SystemBridge` للتوافق

### إضافة اختبار جديد
1. إنشاء ملف اختبار في `lib/tests/`
2. استخدام الخدمات الموجودة
3. إضافة نتائج ملونة للوضوح

### تحديث قاعدة البيانات
1. تحديث الـ schemas في `DatabaseService`
2. إضافة migration functions إذا لزم الأمر
3. اختبار التوافق مع البيانات الموجودة

## 🔒 الأمان

- تشفير جميع كلمات المرور
- حماية من SQL Injection
- التحقق من صحة البيانات
- حماية من الهجمات الشائعة

## 🌐 دعم اللغات

- واجهة عربية كاملة
- دعم الاتجاه من اليمين لليسار
- رسائل خطأ بالعربية
- تواريخ بالتقويم الهجري والميلادي

## 📞 الدعم

للمساعدة أو الإبلاغ عن المشاكل:
- راجع سجلات النظام أولاً
- استخدم شاشة التشخيص الشامل
- تحقق من حالة الشبكة وقاعدة البيانات

---

**ملاحظة**: هذا النظام المحسن يحافظ على جميع الوظائف الموجودة مع إضافة مميزات جديدة وتحسينات في الأداء والموثوقية.
