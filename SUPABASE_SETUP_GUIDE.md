# دليل إعداد Supabase للتقارير الأونلاين

## الخطوات المطلوبة

### 1. إنشاء مشروع Supabase
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. أنشئ مشروع جديد
3. انسخ URL والـ Anon Key من إعدادات المشروع

### 2. إنشاء الجداول
قم بتنفيذ الكود SQL الموجود في ملف `supabase_tables.sql` في SQL Editor في Supabase:

```sql
-- يتم تنفيذ محتوى ملف supabase_tables.sql
```

### 3. إعداد المشروع
الكود موجود ومُحدَث بالفعل في:
- `lib/services/supabase_service.dart` - خدمة الاتصال بـ Supabase
- `lib/services/online_reports_service.dart` - خدمة التقارير الأونلاين
- `lib/schoolregstristion.dart` - تم تحديثه لإضافة المدرسة إلى Supabase
- `lib/localdatabase/school.dart` - تم إضافة حقول Supabase

### 4. الميزات المتاحة

#### للمدارس المسجلة في Supabase:
- ✅ مزامنة بيانات المدرسة مع السحابة
- ✅ رفع التقارير المالية أونلاين
- ✅ رفع تقارير الطلاب أونلاين
- ✅ رفع تقارير الموظفين أونلاين
- ✅ نسخ احتياطي سحابي للتقارير

#### للمدارس غير المتصلة:
- ⚠️ العمل محلياً فقط
- ⚠️ عدم إمكانية الوصول للتقارير من أجهزة أخرى
- ⚠️ عدم وجود نسخ احتياطي سحابي

### 5. كيفية الاستخدام

#### في كود التطبيق:
```dart
// للتحقق من توفر التقارير الأونلاين
bool isOnline = await OnlineReportsService.isOnlineReportsAvailable();

// لرفع تقرير مالي
await OnlineReportsService.uploadFinancialReport(
  reportData: financialData
);

// لرفع تقرير الطلاب
await OnlineReportsService.uploadStudentReport(
  reportData: studentsData
);
```

#### في واجهة المستخدم:
- عند التسجيل الأول، سيظهر للمستخدم إذا تم تفعيل الميزات الأونلاين
- في شاشات التقارير، يمكن إظهار خيارات إضافية للمدارس المتصلة

### 6. معلومات إضافية

#### الأمان:
- جميع البيانات محمية بسياسات RLS في Supabase
- كل مدرسة تستطيع الوصول لبياناتها فقط

#### الاشتراكات:
- الفترة التجريبية: 7 أيام
- بعد انتهاء الفترة التجريبية، يمكن ترقية الاشتراك

#### الدعم الفني:
- جميع العمليات تعمل في وضع الأخطاء المحلي إذا فشل الاتصال بـ Supabase
- يتم حفظ البيانات محلياً في جميع الحالات

### 7. ملاحظات مهمة
- تأكد من تشغيل `flutter pub get` بعد إضافة dependencies
- قم بإعادة build للمشروع بعد تحديث نموذج School
- اختبر الاتصال بـ Supabase قبل النشر النهائي
