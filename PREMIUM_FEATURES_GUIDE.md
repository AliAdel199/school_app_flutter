# دليل تنفيذ نظام الميزات المدفوعة للتقارير الأونلاين

## الخطوات المطلوبة

### 1. تحديث قاعدة البيانات
```sql
-- في Supabase SQL Editor، قم بتشغيل الملف:
-- premium_features_setup.sql
```

### 2. إعادة تشغيل التطبيق
بعد تشغيل الـ SQL script، قم بإعادة تشغيل التطبيق لتحميل التحديثات الجديدة.

### 3. اختبار النظام

#### أ. للمؤسسات ذات الباقة الأساسية (Basic/Trial):
1. اذهب إلى شاشة التقارير
2. اضغط على زر رفع التقرير (سيظهر أيقونة القفل 🔒)
3. ستظهر شاشة شراء الميزة مع:
   - خيار شهري: 25,000 د.ع
   - خيار سنوي: 250,000 د.ع
   - قائمة بالمميزات

#### ب. للمؤسسات ذات الباقة المدفوعة (Premium/Enterprise):
1. زر رفع التقرير سيعمل مباشرة
2. أيقونة رفع السحابة ☁️ ستظهر بدلاً من القفل

### 4. كيفية عمل النظام

#### التحقق من الصلاحيات:
```dart
// عند الضغط على زر رفع التقرير
1. يتم فحص نوع الباقة في جدول educational_organizations
2. إذا كانت premium/enterprise → السماح بالرفع
3. إذا كانت basic/trial → فحص جدول feature_purchases
4. إذا لم توجد ميزة مشتراة → عرض شاشة الشراء
```

#### عملية الشراء:
```dart
1. اختيار الخطة (شهرية/سنوية)
2. تسجيل المشتراة في جدول feature_purchases
3. تفعيل الميزة فوراً
4. إظهار رسالة نجاح
```

### 5. الأسعار الحالية
- **شهرياً**: 25,000 دينار عراقي
- **سنوياً**: 250,000 دينار عراقي (توفير 50,000 د.ع)

### 6. الميزات المتضمنة
- ✅ رفع التقارير على السحابة
- ✅ الوصول للتقارير من أي جهاز
- ✅ نسخ احتياطي آمن
- ✅ مشاركة التقارير
- ✅ تخزين غير محدود

### 7. كيفية إضافة ميزات جديدة

#### أ. في الكود:
```dart
// في PremiumFeaturesService
static const Map<String, Map<String, dynamic>> FEATURE_PRICES = {
  'new_feature': {
    'name_ar': 'اسم الميزة',
    'price_monthly': 30000,
    'price_yearly': 300000,
    // ... باقي الإعدادات
  },
};
```

#### ب. في قاعدة البيانات:
```sql
-- إدراج ميزة جديدة
INSERT INTO feature_purchases (organization_id, feature_name, ...)
VALUES (1, 'new_feature', ...);
```

### 8. مراقبة النظام

#### فحص المشتريات:
```sql
SELECT 
    eo.name as organization_name,
    fp.feature_name,
    fp.amount,
    fp.purchase_date,
    fp.expires_at,
    fp.status
FROM feature_purchases fp
JOIN educational_organizations eo ON fp.organization_id = eo.id
ORDER BY fp.created_at DESC;
```

#### فحص التقارير المرفوعة:
```sql
SELECT 
    eo.name as organization_name,
    r.report_title,
    r.report_type,
    r.generated_at,
    r.status
FROM reports r
JOIN educational_organizations eo ON r.organization_id = eo.id
ORDER BY r.created_at DESC;
```

### 9. استكشاف الأخطاء

#### إذا لم تعمل الميزة بعد الشراء:
1. تحقق من جدول `feature_purchases`
2. تأكد من أن `status` = 'active'
3. تأكد من أن `expires_at` في المستقبل
4. أعد تشغيل التطبيق

#### إذا ظهرت رسائل خطأ:
1. تحقق من الاتصال بالإنترنت
2. تحقق من RLS policies في Supabase
3. تحقق من logs في Supabase Dashboard

### 10. الحماية والأمان
- ✅ Row Level Security مفعل
- ✅ المديرين فقط يمكنهم الشراء
- ✅ كل مؤسسة تصل لميزاتها فقط
- ✅ التحقق من صلاحية الميزة عند كل استخدام

## ملاحظات مهمة
- النظام يدعم الدفع اليدوي حالياً
- يمكن إضافة بوابات دفع إلكترونية لاحقاً
- الأسعار قابلة للتعديل من الكود
- النظام قابل للتوسع لإضافة ميزات جديدة

## الدعم
للدعم التقني أو الاستفسارات، يرجى مراجعة ملفات المشروع أو التواصل مع فريق التطوير.
