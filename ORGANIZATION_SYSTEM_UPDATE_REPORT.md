# تقرير تحديث النظام للمؤسسات التعليمية

## ✅ **تم تحديث الكود بنجاح!**

### 🏗️ **التحديثات المنجزة:**

#### 1. **نموذج قاعدة البيانات المحلية:**
- ✅ تحديث `School` model لإضافة:
  - `organizationId` - معرف المؤسسة في Supabase
  - `organizationType` - نوع المدرسة (ابتدائية، متوسطة، ثانوية)
  - `organizationName` - اسم المؤسسة التابعة لها

#### 2. **خدمة Supabase المحسنة:**
- ✅ `createOrganizationWithSchool()` - إنشاء مؤسسة مع المدرسة الأولى
- ✅ `addSchoolToOrganization()` - إضافة مدرسة جديدة للمؤسسة
- ✅ `uploadOrganizationReport()` - رفع التقارير مع ربطها بالمؤسسة
- ✅ `getOrganizationSchools()` - جلب جميع مدارس المؤسسة
- ✅ `getOrganizationAnalytics()` - إحصائيات مجمعة للمؤسسة
- ✅ `checkOrganizationSubscriptionStatus()` - التحقق من اشتراك المؤسسة

#### 3. **خدمة التقارير الأونلاين المطورة:**
- ✅ تحديث جميع دوال الرفع لتعمل مع المؤسسات
- ✅ إضافة معاملات جديدة: `reportTitle`, `period`
- ✅ دوال جديدة للعمل مع المؤسسات:
  - `getOrganizationSchools()` 
  - `getOrganizationAnalytics()`
  - `addNewSchoolToOrganization()`

#### 4. **تحديث شاشة التسجيل:**
- ✅ استخدام `createOrganizationWithSchool()` بدلاً من الطريقة القديمة
- ✅ حفظ معلومات المؤسسة في قاعدة البيانات المحلية
- ✅ رسائل نجاح محسنة تشمل معلومات المؤسسة
- ✅ دعم إنشاء حساب مدير للوصول من التطبيق

---

### 🗃️ **جداول Supabase المطلوبة:**

```sql
-- جدول المؤسسات التعليمية
CREATE TABLE educational_organizations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  logo_url TEXT,
  email VARCHAR(255),
  phone VARCHAR(50),
  address TEXT,
  website VARCHAR(255),
  license_number VARCHAR(100),
  subscription_plan VARCHAR(50) DEFAULT 'basic',
  subscription_status VARCHAR(50) DEFAULT 'trial',
  trial_expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول المدارس (محدث)
CREATE TABLE schools (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES educational_organizations(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  school_type VARCHAR(100),
  grade_levels JSONB,
  email VARCHAR(255),
  phone VARCHAR(50),
  address TEXT,
  logo_url TEXT,
  capacity INTEGER DEFAULT 0,
  current_students_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول مدراء المؤسسة
CREATE TABLE organization_admins (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES educational_organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(50),
  role VARCHAR(50) DEFAULT 'admin',
  permissions JSONB DEFAULT '{"all_schools": true, "reports": true, "analytics": true}',
  school_access JSONB,
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول التقارير (محدث)
CREATE TABLE reports (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES educational_organizations(id) ON DELETE CASCADE,
  school_id INTEGER REFERENCES schools(id) ON DELETE CASCADE,
  report_type VARCHAR(100) NOT NULL,
  report_title VARCHAR(255) NOT NULL,
  report_data JSONB NOT NULL,
  report_summary JSONB,
  period_start DATE,
  period_end DATE,
  generated_by VARCHAR(255),
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول الإحصائيات المجمعة
CREATE TABLE organization_analytics (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES educational_organizations(id) ON DELETE CASCADE,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  analytics_data JSONB NOT NULL,
  total_students INTEGER DEFAULT 0,
  total_income DECIMAL(15,2) DEFAULT 0,
  total_expenses DECIMAL(15,2) DEFAULT 0,
  schools_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### 📱 **ما سيظهر في تطبيق المدير:**

#### 🏠 **الشاشة الرئيسية:**
- 📊 إحصائيات مجمعة من جميع المدارس
- 🏫 قائمة بالمدارس التابعة للمؤسسة
- 📈 رسوم بيانية للمقارنة بين المدارس

#### 📋 **شاشة التقارير:**
- 📊 تقارير مجمعة للمؤسسة كاملة
- 🏫 تقارير مفصلة لكل مدرسة على حدة
- 📈 مقارنات الأداء بين المدارس
- 📅 تقارير شهرية/سنوية

#### ⚙️ **شاشة الإدارة:**
- ➕ إضافة مدرسة جديدة للمؤسسة
- 👥 إدارة الصلاحيات للمدراء
- 🔔 الإشعارات والتنبيهات

---

### 🚀 **الخطوات التالية:**

1. **إنشاء مشروع Supabase جديد**
2. **تنفيذ SQL أعلاه في Supabase**
3. **تحديث المفاتيح في SupabaseService**
4. **اختبار التسجيل وإنشاء المؤسسة**
5. **بدء تطوير تطبيق المدير للهاتف**

---

### ✨ **المميزات الجديدة:**

- 🏢 **نظام هرمي**: مؤسسة → مدارس → تقارير
- 📊 **إحصائيات مجمعة** من جميع المدارس
- 🔄 **مزامنة ذكية** مع السحابة
- 📱 **دعم التطبيق المحمول** للمدراء
- 🔒 **نظام صلاحيات** متقدم
- 📈 **تحليلات متطورة** ومقارنات

النظام الآن جاهز للعمل كمؤسسة تعليمية شاملة! 🎯
