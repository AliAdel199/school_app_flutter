# إعداد قاعدة البيانات Supabase

## المشكلة الحالية
```
PostgrestException(message: Could not find the 'device_info' column of 'educational_organizations' in the schema cache, code: PGRST204, details: Bad Request, hint: null)
```

**المشكلة**: قاعدة البيانات Supabase لا تحتوي على الجداول والأعمدة المطلوبة.

## الحل
تحتاج لتشغيل السكريبت `supabase_complete_schema.sql` في قاعدة بيانات Supabase الجديدة.         

## خطوات الحل:

### 1. الدخول إلى Supabase Dashboard
- اذهب إلى: https://app.supabase.com
- اختر المشروع: `hvqpucjmtwqtaqydpskv`

### 2. تشغيل SQL Schema
- اذهب إلى قسم "SQL Editor" 
- انسخ محتوى ملف `supabase_complete_schema.sql`
- الصق المحتوى في محرر SQL
- اضغط "Run" لتنفيذ السكريبت

### 3. التحقق من الجداول
بعد تشغيل السكريبت، تأكد من وجود هذه الجداول:
- ✅ `educational_organizations`
- ✅ `schools` 
- ✅ `users`
- ✅ `students`
- ✅ `classes`
- ✅ `student_classes`
- ✅ `payments`
- ✅ `license_status_view` (View)
- ✅ `license_stats_view` (View)

### 4. التحقق من الأعمدة
تأكد من وجود عمود `activation_count` في جدول `educational_organizations`:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'educational_organizations';
```

## الحالة الحالية
✅ تم إصلاح الكود ليعمل مع الحد الأدنى من الأعمدة المطلوبة
✅ تم تعطيل `device_info`، `device_fingerprint`، `activation_count` مؤقتاً
⚠️ يحتاج إعداد قاعدة البيانات الكاملة لاستعادة جميع الميزات

## الأعمدة المُعطلة مؤقتاً
- `activation_count` - عداد تفعيل الجهاز
- `device_info` - معلومات الجهاز
- `device_fingerprint` - بصمة الجهاز  
- `last_activation_at` - آخر تفعيل

## بعد إعداد قاعدة البيانات
يمكن إعادة تفعيل جميع الأعمدة والميزات المُعطلة:
- Device fingerprinting لمنع الاستخدام المتعدد
- تتبع عدد مرات التفعيل
- حفظ معلومات الجهاز للأمان

## للاختبار الآن
التطبيق جاهز للاختبار بالميزات الأساسية:
- إنشاء المؤسسات التعليمية ✅
- إنشاء المدارس ✅  
- إنشاء المستخدمين ✅
- النظام المحلي يعمل بالكامل ✅
