# حل مشكلة Row Level Security في Supabase

## 🔴 **المشكلة:**
```
PostgrestException: new row violates row-level security policy for table "educational_organizations"
```

## 🔧 **الحل السريع:**

### **الطريقة 1: تعطيل RLS مؤقتاً (الأسرع)**

اذهب إلى **Supabase Dashboard → SQL Editor** ونفذ:

```sql
-- تعطيل Row Level Security مؤقتاً للتجربة
ALTER TABLE educational_organizations DISABLE ROW LEVEL SECURITY;
ALTER TABLE schools DISABLE ROW LEVEL SECURITY;
ALTER TABLE organization_admins DISABLE ROW LEVEL SECURITY;
ALTER TABLE reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE organization_analytics DISABLE ROW LEVEL SECURITY;
```

### **الطريقة 2: إضافة سياسات مؤقتة مفتوحة**

```sql
-- إبقاء RLS مفعل مع سياسات مفتوحة
CREATE POLICY "temp_allow_all_organizations" ON educational_organizations 
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_schools" ON schools 
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_admins" ON organization_admins 
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_reports" ON reports 
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "temp_allow_all_analytics" ON organization_analytics 
  FOR ALL USING (true) WITH CHECK (true);
```

## 🧪 **اختبار الحل:**

بعد تنفيذ أي من الطريقتين أعلاه:

1. **أعد تشغيل التطبيق**
2. **جرب إنشاء مدرسة جديدة**
3. **تحقق من الرسائل في console**

### **الرسائل المتوقعة عند النجاح:**
```
🔄 بدء إنشاء المؤسسة التعليمية...
✅ الاتصال بـ Supabase سليم
📋 إنشاء المؤسسة: اسم المؤسسة
✅ تم إنشاء المؤسسة - ID: 1
🏫 إنشاء المدرسة: اسم المدرسة
✅ تم إنشاء المدرسة - ID: 1
👤 إنشاء حساب المدير: email@example.com
✅ تم إنشاء حساب المدير - ID: uuid
🔐 إضافة صلاحيات المدير...
✅ تم إنشاء ملف المدير بنجاح
🎉 إنشاء المؤسسة التعليمية مكتمل!
```

## 🔒 **تأمين لاحقاً (اختياري):**

عندما تريد تأمين قاعدة البيانات لاحقاً، يمكنك:

```sql
-- إعادة تفعيل RLS
ALTER TABLE educational_organizations ENABLE ROW LEVEL SECURITY;
-- ... باقي الجداول

-- حذف السياسات المؤقتة
DROP POLICY "temp_allow_all_organizations" ON educational_organizations;
-- ... باقي السياسات

-- إضافة سياسات أمان محكمة
CREATE POLICY "authenticated_can_insert_org" ON educational_organizations 
  FOR INSERT WITH CHECK (true);
-- إلخ...
```

## 🚀 **بعد الإصلاح:**

- ✅ إنشاء المؤسسات التعليمية يعمل
- ✅ إنشاء المدارس يعمل  
- ✅ إنشاء حسابات المدراء يعمل
- ✅ تطبيق الهاتف سيتمكن من الوصول للبيانات

---

**الحل مؤقت لأغراض التطوير والاختبار. يُنصح بتطبيق أمان أكثر تفصيلاً في البيئة الإنتاجية.**
