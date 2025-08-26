# دليل الانتقال للنظام الجديد

## 🔄 خطوات الانتقال من النظام القديم

### الخطوة 1: النسخ الاحتياطي
```bash
# انسخ جميع الملفات المهمة
cp -r lib/services lib/services_backup
cp -r lib/localdatabase lib/localdatabase_backup
cp pubspec.yaml pubspec_backup.yaml
```

### الخطوة 2: استبدال الملفات الأساسية

#### استبدال main.dart
```dart
// من
import 'services/supabase_service.dart';

// إلى
import 'services/unified_service.dart';
import 'services/system_bridge.dart';
```

#### تحديث الاستيرادات في الملفات الموجودة
```dart
// في أي ملف يستخدم SupabaseService
// من
import '../services/supabase_service.dart';

// إلى
import '../services/system_bridge.dart';

// واستبدال الاستدعاءات
// من
SupabaseService.createOrganizationWithSchool(...)

// إلى
SystemBridge.createOrganizationWithSchool(...)
```

### الخطوة 3: تحديث pubspec.yaml
```yaml
# إضافة التبعيات الجديدة (إذا لم تكن موجودة)
dependencies:
  supabase_flutter: ^2.9.0
  device_info_plus: ^11.5.0
  connectivity_plus: ^6.1.4
  crypto: ^3.0.6
  shared_preferences: ^2.2.2
```

### الخطوة 4: اختبار النظام الجديد

#### تشغيل الاختبار السريع
```dart
// في main.dart أو أي شاشة
import 'tests/quick_system_test_screen.dart';

// إضافة زر للاختبار
ElevatedButton(
  onPressed: () {
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => QuickSystemTestScreen()));
  },
  child: Text('اختبار النظام'),
)
```

### الخطوة 5: التحقق من الوظائف

#### قائمة التحقق الأساسية
- [ ] تهيئة قاعدة البيانات
- [ ] الاتصال بالشبكة
- [ ] إنشاء المؤسسات
- [ ] إدارة المستخدمين
- [ ] رفع التقارير
- [ ] إدارة الاشتراكات

## 🛠️ إصلاح المشاكل الشائعة

### مشكلة: فشل في تهيئة قاعدة البيانات
```dart
// الحل
final status = await DatabaseService.checkStatus();
if (!status['is_enabled']) {
  print('خطأ: ${status['error']}');
  // تحقق من متغيرات الاتصال
}
```

### مشكلة: عدم وجود اتصال بالشبكة
```dart
// الحل
final networkStatus = await NetworkHelper.checkNetworkStatus();
if (!networkStatus['is_connected']) {
  // العمل في وضع محلي
  print('تم التبديل للوضع المحلي');
}
```

### مشكلة: خطأ في معلومات الجهاز
```dart
// الحل
try {
  final deviceInfo = await DeviceService.getDisplayInfo();
  if (deviceInfo.containsKey('خطأ')) {
    print('تحذير: ${deviceInfo['خطأ']}');
    // استخدام معلومات افتراضية
  }
} catch (e) {
  print('فشل في جمع معلومات الجهاز: $e');
}
```

## 📋 دليل استبدال الوظائف

### خدمات قاعدة البيانات
```dart
// القديم
SupabaseService.initialize()

// الجديد
UnifiedService.initializeSystem()
// أو للتوافق
SystemBridge.initializeSupabase()
```

### إنشاء المؤسسات
```dart
// القديم
SupabaseService.createEducationalOrganization(...)

// الجديد
OrganizationService.createOrganization(...)
// أو للتوافق
SystemBridge.createEducationalOrganization(...)
```

### إدارة التقارير
```dart
// القديم
SupabaseService.uploadOrganizationReport(...)

// الجديد
ReportsService.uploadOrganizationReport(...)
// أو للتوافق
SystemBridge.uploadReport(...)
```

### فحص الاشتراكات
```dart
// القديم
SupabaseService.checkOrganizationSubscriptionStatus(...)

// الجديد
SubscriptionService.checkOrganizationSubscriptionStatus(...)
// أو للتوافق
SystemBridge.checkOrganizationSubscriptionStatus(...)
```

## 🔍 اختبار التوافق

### اختبار شامل للوظائف الأساسية
```dart
Future<void> testSystemCompatibility() async {
  print('🧪 بدء اختبار التوافق...');
  
  // 1. اختبار التهيئة
  final initResult = await SystemBridge.initializeSupabase();
  print('تهيئة النظام: ${initResult ? '✅' : '❌'}');
  
  // 2. اختبار إنشاء المؤسسة
  try {
    final orgResult = await SystemBridge.createEducationalOrganization(
      name: 'اختبار',
      email: 'test@test.com',
    );
    print('إنشاء مؤسسة: ${orgResult != null ? '✅' : '❌'}');
  } catch (e) {
    print('إنشاء مؤسسة: ❌ - $e');
  }
  
  // 3. اختبار التقارير
  try {
    final reportsResult = await SystemBridge.checkOnlineReportsSubscription();
    print('خدمة التقارير: ${reportsResult ? '✅' : '❌'}');
  } catch (e) {
    print('خدمة التقارير: ❌ - $e');
  }
  
  print('🏁 انتهى اختبار التوافق');
}
```

## 🚨 نصائح مهمة

### 1. احتفظ بالنسخة القديمة
- لا تحذف ملفات `supabase_service.dart` فوراً
- احتفظ بنسخة احتياطية من المشروع كاملاً

### 2. اختبر تدريجياً
- اختبر كل وظيفة على حدة
- تأكد من عمل الوظائف الأساسية أولاً

### 3. راقب السجلات
```dart
// تفعيل السجلات المفصلة
void enableDetailedLogging() {
  print('🔍 تم تفعيل السجلات المفصلة');
  // إضافة المزيد من print statements
}
```

### 4. استخدم التشخيص
```dart
// تشغيل التشخيص الشامل عند المشاكل
final diagnostic = await UnifiedService.performSystemDiagnostic();
print('تقرير التشخيص:');
print('الحالة: ${diagnostic['health_level']}');
print('المشاكل: ${diagnostic['critical_issues']}');
print('التحذيرات: ${diagnostic['warnings']}');
```

## 📞 المساعدة والدعم

### عند مواجهة مشاكل:

1. **تشغيل التشخيص الشامل**
   ```dart
   final diagnostic = await UnifiedService.performSystemDiagnostic();
   ```

2. **فحص سجلات النظام**
   - ابحث عن رسائل تبدأ بـ ❌ أو ⚠️
   - راجع تفاصيل الأخطاء

3. **اختبار الشبكة وقاعدة البيانات**
   ```dart
   final status = await UnifiedService.getServicesStatus();
   ```

4. **استخدام الوضع المحلي**
   - إذا فشل الاتصال، النظام سيعمل محلياً
   - البيانات ستحفظ في قاعدة البيانات المحلية

### معلومات إضافية:
- جميع الوظائف القديمة متاحة عبر `SystemBridge`
- النظام الجديد يدعم العمل بدون إنترنت
- إمكانية العودة للنظام القديم في أي وقت

---

**مهم**: اختبر النظام الجديد في بيئة تجريبية قبل النشر في بيئة الإنتاج.
