# دليل إعدادات الخصومات التلقائية

## ملخص التحديثات

تم تطوير نظام متكامل لإعداد وإدارة الخصومات التلقائية في تطبيق المدرسة بناءً على طلبك "اعتقد لازم نخلي خيار ايقاف الخصم التلقائي".

## الملفات المحدثة

### 1. AutoDiscountSettings Model
**المسار:** `lib/localdatabase/auto_discount_settings.dart`
- نموذج البيانات لحفظ جميع إعدادات الخصومات
- يشمل التحكم العام وإعدادات كل نوع خصم
- يستخدم Isar database للتخزين

### 2. AutoDiscountSettingsManager
**المسار:** `lib/helpers/auto_discount_settings_manager.dart`
- مدير الإعدادات الذي يتعامل مع SharedPreferences
- يوفر جميع العمليات (قراءة، كتابة، تحديث)
- يدعم الإعدادات الافتراضية

### 3. Simple Auto Discount Processor (محدث)
**المسار:** `lib/helpers/simple_auto_discount_processor.dart`
- تم تحديث جميع دوال المعالجة للتحقق من الإعدادات
- إضافة التحكم العام في تفعيل/إيقاف النظام
- دعم إعدادات مخصصة لكل نوع خصم

## المزايا الجديدة

### 1. التحكم العام
```dart
// تفعيل أو إيقاف النظام بالكامل
await settingsManager.setGlobalEnabled(false);

// فحص حالة النظام
bool isEnabled = await settingsManager.isGloballyEnabled();
```

### 2. التحكم في كل نوع خصم
```dart
// إيقاف خصم الأشقاء
await settingsManager.setSiblingDiscountEnabled(false);

// إيقاف خصم الدفع المبكر
await settingsManager.setEarlyPaymentDiscountEnabled(false);

// إيقاف خصم الدفع الكامل
await settingsManager.setFullPaymentDiscountEnabled(false);
```

### 3. تخصيص النسب والقيم
```dart
// تحديث نسب خصم الأشقاء
await settingsManager.updateSiblingDiscountRates(
  rate2nd: 12.0,   // 12% للطالب الثاني
  rate3rd: 18.0,   // 18% للطالب الثالث
  rate4th: 25.0,   // 25% للطالب الرابع فما فوق
);

// تحديث إعدادات الدفع المبكر
await settingsManager.updateEarlyPaymentSettings(
  discountRate: 7.0,  // 7% خصم
  days: 45,           // 45 يوم قبل بداية العام
);

// تحديث نسبة خصم الدفع الكامل
await settingsManager.updateFullPaymentDiscountRate(4.0); // 4%
```

## كيفية الاستخدام

### 1. إنشاء مثيل من المدير
```dart
final settingsManager = AutoDiscountSettingsManager();
```

### 2. الحصول على الإعدادات الحالية
```dart
final settings = await settingsManager.getSettings();
print('النظام مفعل: ${settings.globalEnabled}');
print('خصم الأشقاء مفعل: ${settings.siblingDiscountEnabled}');
```

### 3. تشغيل المعالج مع الإعدادات
```dart
final processor = AutoDiscountProcessor(isar);
final discounts = await processor.processAllAutoDiscounts(student, academicYear);
```

## الحماية المدمجة

1. **فحص النظام العام:** يتم فحص `globalEnabled` قبل أي معالجة
2. **فحص كل نوع خصم:** يتم فحص تفعيل كل نوع منفصل
3. **القيم الافتراضية:** إعدادات آمنة عند عدم وجود قيم محفوظة
4. **التحقق من الصحة:** فحص النسب والقيم المدخلة

## الإعدادات الافتراضية

- **النظام العام:** مفعل
- **خصم الأشقاء:** مفعل (10%, 15%, 20%)
- **خصم الدفع المبكر:** مفعل (5% لـ 30 يوم)
- **خصم الدفع الكامل:** مفعل (3%)

## ملاحظات مهمة

1. تم إضافة `shared_preferences` كمتطلب جديد
2. جميع الإعدادات تُحفظ محلياً على الجهاز
3. النظام متوافق مع الكود الموجود
4. لا يؤثر على الخصومات المطبقة مسبقاً

## استكمال التطوير

للاستفادة الكاملة من هذا النظام، يُنصح بإضافة:
1. واجهة مستخدم لإدارة الإعدادات
2. نظام نسخ احتياطي للإعدادات
3. سجل تغييرات الإعدادات
4. تصدير/استيراد الإعدادات

تم حل المشكلة الأساسية وإضافة نظام متقدم للتحكم في الخصومات التلقائية! 🎉
