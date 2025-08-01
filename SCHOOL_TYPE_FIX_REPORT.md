# حل مشكلة قيد التحقق school_type

## المشكلة
```
PostgrestException: new row for relation "schools" violates check constraint "schools_school_type_check"
```

## الحل المطبق

### ✅ 1. تعديل الكود (تم)
- إضافة دالة `_normalizeSchoolType()` في `SupabaseService`
- تحويل جميع قيم `school_type` للقيم المسموحة
- دعم اللغة العربية والإنجليزية

### ✅ 2. القيم المدعومة الآن
- `مختلطة` → `mixed`
- `ابتدائية` → `primary` 
- `ثانوية` → `secondary`
- `متوسطة` → `middle`
- `بنين` → `boys`
- `بنات` → `girls`
- أي قيمة غير معروفة → `mixed`

### 🔧 3. حل قاعدة البيانات (اختياري)
إذا كنت تريد إزالة القيد تماماً، شغل هذا في Supabase SQL Editor:

```sql
-- في ملف fix_school_constraint.sql
ALTER TABLE schools DROP CONSTRAINT IF EXISTS schools_school_type_check;
```

## النتيجة
✅ التطبيق جاهز للاختبار الآن
✅ يقبل أي نوع مدرسة ويحوله للقيم المسموحة
✅ لا حاجة لتعديل قاعدة البيانات

## اختبر الآن
جرب إنشاء مدرسة جديدة - يجب أن يعمل بدون أخطاء!
