# دليل رفع التقارير إلى Supabase

## الملفات المُنشأة:

### 1. `reports_table_schema.sql`
- **الغرض**: إنشاء جدول التقارير في قاعدة بيانات Supabase
- **المحتوى**: 
  - جدول `school_reports` لحفظ التقارير العامة
  - فهارس لتحسين الأداء
  - تريجر لتحديث `updated_at` تلقائياً

### 2. `lib/services/reports_supabase_service.dart`
- **الغرض**: خدمة إدارة التقارير في Supabase
- **الوظائف**:
  - `uploadGeneralReport()`: رفع تقرير عام جديد
  - `getSchoolReports()`: جلب تقارير مدرسة معينة
  - `getOrganizationReports()`: جلب تقارير مؤسسة كاملة
  - `deleteReport()`: حذف تقرير
  - `updateReport()`: تحديث تقرير
  - `getOrganizationStats()`: إحصائيات المؤسسة
  - `getAvailableAcademicYears()`: السنوات الدراسية المتوفرة

### 3. `lib/reports/uploaded_reports_screen.dart`
- **الغرض**: شاشة عرض وإدارة التقارير المرفوعة
- **المميزات**:
  - عرض قائمة التقارير المرفوعة
  - فلترة بالسنة الدراسية
  - عرض تفاصيل كل تقرير
  - حذف التقارير

### 4. تحديثات على `lib/reports/reportsscreen.dart`
- **الإضافات**:
  - دالة `uploadReportToSupabase()`: رفع التقرير الحالي
  - زر رفع التقارير في AppBar
  - زر عرض التقارير المرفوعة

## خطوات التنفيذ:

### 1. إنشاء الجدول في Supabase:
```sql
-- نفّذ محتوى ملف reports_table_schema.sql في Supabase Dashboard
```

### 2. تحديث معرفات المؤسسة والمدرسة:
في الملفات التالية، استبدل القيم الثابتة بالمعرفات الحقيقية:

**في `reportsscreen.dart`:**
```dart
// السطر 162 و 163
const int organizationId = 1; // استبدل بالمعرف الحقيقي
const int schoolId = 1; // استبدل بالمعرف الحقيقي
```

**في `reportsscreen.dart`:**
```dart
// السطر 490-492
organizationId: 1, // استبدل بالمعرف الحقيقي  
schoolId: 1, // استبدل بالمعرف الحقيقي أو اتركه null لجميع المدارس
```

### 3. إضافة متغيرات عامة (اختياري):
يمكنك إضافة متغيرات عامة في `main.dart`:
```dart
// إضافة هذه المتغيرات في main.dart
int? currentOrganizationId;
int? currentSchoolId;
String? currentUserId;

// دالة لتعيين القيم عند تسجيل الدخول
void setCurrentUserContext(int orgId, int schoolId, String userId) {
  currentOrganizationId = orgId;
  currentSchoolId = schoolId;
  currentUserId = userId;
}
```

### 4. اختبار الوظائف:

#### اختبار رفع التقرير:
1. افتح شاشة التقارير العامة
2. اختر سنة دراسية أو فترة زمنية
3. اضغط على زر "رفع التقرير إلى السحابة" (☁️⬆️)
4. تأكد من ظهور رسالة النجاح

#### اختبار عرض التقارير المرفوعة:
1. اضغط على زر "عرض التقارير المرفوعة" (☁️⬇️)
2. تأكد من ظهور التقارير المرفوعة
3. جرّب فلترة السنوات الدراسية
4. جرّب حذف تقرير

### 5. ميزات إضافية يمكن تطويرها:

#### إشعارات تلقائية:
- رفع تقرير يومي/أسبوعي/شهري تلقائياً
- إرسال إشعار للمدراء عند رفع تقرير جديد

#### تحليلات متقدمة:
- مقارنة التقارير بين فترات مختلفة
- رسوم بيانية للاتجاهات
- تصدير التقارير بصيغ مختلفة

#### صلاحيات متقدمة:
- تحديد من يمكنه رفع التقارير
- تحديد من يمكنه حذف التقارير
- تسجيل تاريخ جميع العمليات

## استخدام في تطبيق المدراء:

يمكن لتطبيق المدراء الآن:

1. **جلب التقارير**: استخدام `ReportsSupabaseService.getOrganizationReports()`
2. **عرض الإحصائيات**: استخدام `ReportsSupabaseService.getOrganizationStats()`
3. **فلترة البيانات**: حسب السنة الدراسية أو التاريخ
4. **مراقبة الأداء**: متابعة الاتجاهات والتغييرات

## الأمان والصلاحيات:

⚠️ **مهم**: تأكد من إعداد Row Level Security (RLS) في Supabase:

```sql
-- تفعيل RLS على جدول التقارير
ALTER TABLE school_reports ENABLE ROW LEVEL SECURITY;

-- سياسة للسماح بالقراءة للمؤسسة نفسها فقط
CREATE POLICY "Users can view their organization reports" ON school_reports
    FOR SELECT USING (organization_id = auth.jwt() ->> 'organization_id');

-- سياسة للسماح بالإدراج للمؤسسة نفسها فقط  
CREATE POLICY "Users can insert their organization reports" ON school_reports
    FOR INSERT WITH CHECK (organization_id = auth.jwt() ->> 'organization_id');
```

## التحقق من نجاح التنفيذ:

✅ إنشاء جدول `school_reports` في Supabase  
✅ إضافة خدمة `ReportsSupabaseService`  
✅ إضافة شاشة `UploadedReportsScreen`  
✅ تحديث `ReportsScreen` مع أزرار الرفع والعرض  
✅ استبدال المعرفات الثابتة بالقيم الحقيقية  
✅ اختبار رفع وعرض التقارير  
✅ إعداد الصلاحيات في Supabase  

---

🎉 **تم! النظام جاهز لرفع واستخدام التقارير في تطبيق المدراء**
