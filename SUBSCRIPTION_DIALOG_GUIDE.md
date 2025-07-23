# دليل استخدام دايلوك تفعيل الاشتراك 🔐

## 📱 نظرة عامة

تم إنشاء دايلوك جميل ومتكامل لتفعيل اشتراك مزامنة التقارير مع دعم العروض والخصومات.

## 🎯 الملفات الجديدة

### 1. الدايلوك الرئيسي
**الملف**: `lib/dialogs/subscription_activation_dialog.dart`
- ✅ دايلوك أنيق مع انيميشن
- ✅ دعم العروض والخصومات
- ✅ واجهة سهلة الاستخدام
- ✅ تحقق من صحة البيانات
- ✅ معالجة الأخطاء

### 2. أمثلة الاستخدام
**الملف**: `lib/examples/subscription_activation_example.dart`
- ✅ أمثلة متنوعة للاستخدام
- ✅ بطاقات جذابة للاشتراك
- ✅ أزرار ذكية حسب الحالة
- ✅ عناصر قوائم جاهزة

## 🚀 كيفية الاستخدام

### 1. الاستخدام البسيط
```dart
import 'package:flutter/material.dart';
import 'lib/dialogs/subscription_activation_dialog.dart';

// في أي مكان في التطبيق
ElevatedButton(
  onPressed: () async {
    final result = await SubscriptionActivationDialog.show(context);
    if (result == true) {
      // تم التفعيل بنجاح
      print('تم تفعيل الاشتراك!');
    }
  },
  child: Text('تفعيل الاشتراك'),
)
```

### 2. مع عرض محدد مسبقاً
```dart
// عرض الدايلوك مع عرض محدد
await SubscriptionActivationDialog.show(
  context,
  preSelectedOfferId: 'first_time_50', // خصم 50% للمرة الأولى
);
```

### 3. إخفاء قسم العروض
```dart
// عرض الدايلوك بدون عروض
await SubscriptionActivationDialog.show(
  context,
  showOffers: false,
);
```

## 🎨 الواجهات الجاهزة

### 1. زر التفعيل الذكي
```dart
import 'lib/examples/subscription_activation_example.dart';

// في الواجهة
SubscriptionActivationExample.buildActivationButton(context)
```

### 2. بطاقة الاشتراك للوحة التحكم
```dart
// بطاقة جميلة تعرض حالة الاشتراك
SubscriptionActivationExample.buildSubscriptionCard(context)
```

### 3. عنصر قائمة الإعدادات
```dart
// في قائمة الإعدادات
SubscriptionActivationExample.buildSubscriptionListTile(context)
```

## 🔧 التكامل مع التطبيق

### في main.dart
```dart
import 'lib/examples/subscription_activation_example.dart';

// فحص الاشتراك عند بدء التطبيق
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SubscriptionActivationExample.checkAndShowActivationIfNeeded(context);
  });
}
```

### في شاشة التقارير
```dart
// قبل عرض التقارير السحابية
FloatingActionButton(
  onPressed: () async {
    final status = await SubscriptionService.getReportsSyncStatus();
    if (!status.isActive) {
      // عرض دايلوك التفعيل
      await SubscriptionActivationExample.showActivationDialog(context);
    } else {
      // المتابعة لعرض التقارير
      _showReports();
    }
  },
  child: Icon(Icons.cloud_sync),
)
```

### في AppBar
```dart
AppBar(
  title: Text('إدارة المدرسة'),
  actions: [
    // زر الاشتراك في البار العلوي
    FutureBuilder<SubscriptionStatus>(
      future: SubscriptionService.getReportsSyncStatus(),
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data!.isActive) {
          return IconButton(
            onPressed: () => SubscriptionActivationExample.showActivationDialog(context),
            icon: Icon(Icons.cloud_off),
            tooltip: 'تفعيل مزامنة التقارير',
          );
        }
        return SizedBox.shrink();
      },
    ),
  ],
)
```

### في Drawer
```dart
Drawer(
  child: ListView(
    children: [
      // عناصر أخرى...
      
      // عنصر الاشتراك
      SubscriptionActivationExample.buildSubscriptionListTile(context),
      
      // عناصر أخرى...
    ],
  ),
)
```

## 🎁 المميزات المتقدمة

### 1. الانيميشن والتأثيرات
- ✅ انيميشن fade وslide عند الظهور
- ✅ تأثيرات hover للأزرار
- ✅ انتقالات سلسة بين الحالات

### 2. التحقق التلقائي
```dart
// فحص دوري لحالة الاشتراك
Timer.periodic(Duration(hours: 1), (timer) {
  SubscriptionActivationExample.checkAndShowActivationIfNeeded(context);
});
```

### 3. إشعارات التجديد
- ✅ تذكيرات قبل انتهاء الاشتراك
- ✅ عروض خاصة للتجديد المبكر
- ✅ إشعارات ذكية حسب المستخدم

## 🎯 تخصيص الواجهة

### تغيير الألوان
```dart
SubscriptionActivationDialog.show(
  context,
  // يمكن تخصيص الألوان من خلال Theme
)
```

### تخصيص النصوص
يمكن تعديل النصوص في الملف مباشرة أو إضافة دعم اللغات المتعددة.

## 📊 إحصائيات الاستخدام

### تتبع التفعيلات
```dart
// في الدايلوك يتم تسجيل:
// - تاريخ ووقت التفعيل
// - العرض المستخدم (إن وجد)
// - طريقة الدفع
// - مبلغ التوفير
```

## 🔒 الأمان

### التحقق من الكود
- ✅ تحقق من صحة كود التفعيل
- ✅ منع الاستخدام المتكرر لنفس الكود
- ✅ تشفير البيانات الحساسة

### حماية من الأخطاء
- ✅ معالجة شاملة للأخطاء
- ✅ رسائل واضحة للمستخدم
- ✅ نسخ احتياطية للبيانات

## 🎉 النتيجة النهائية

### ماذا حققنا:
✅ **دايلوك جميل ومتكامل** - واجهة احترافية وسهلة الاستخدام  
✅ **دعم العروض والخصومات** - تحفيز المستخدمين للاشتراك  
✅ **أمثلة جاهزة للاستخدام** - تطبيق سريع في أي مكان  
✅ **واجهات متنوعة** - أزرار وبطاقات وقوائم  
✅ **تكامل ذكي** - فحص تلقائي وإشعارات  
✅ **تجربة مستخدم محسنة** - انيميشن وتأثيرات جذابة  

---

**الدايلوك جاهز للاستخدام! 🚀**

يمكن الآن للمستخدمين:
- تفعيل الاشتراك بسهولة
- الاستفادة من العروض الخاصة  
- تجديد الاشتراك بنقرة واحدة
- متابعة حالة الاشتراك باستمرار
- الحصول على تجربة سلسة ومريحة
