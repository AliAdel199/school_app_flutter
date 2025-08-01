# حل مشكلة الاتصال بـ Supabase

## 🔴 **المشكلة المكتشفة:**
```
ClientException with SocketException: Failed host lookup: 'lhzujcquhgxhsmmjwgdq.supabase.co'
```

## ✅ **التحديثات المطبقة:**

1. **تحديث `main.dart`:**
   - استخدام `SupabaseService.initialize()` بدلاً من التهيئة اليدوية
   - إزالة URLs القديمة المكررة

2. **إضافة دالة `initialize()` في `SupabaseService`:**
   - تهيئة موحدة لـ Supabase
   - معالجة أفضل للأخطاء

3. **إنشاء ملف اختبار `test_supabase_connection.dart`:**
   - لاختبار الاتصال بـ Supabase
   - تشخيص المشاكل المحتملة

## 🚀 **الحلول حسب سبب المشكلة:**

### **1. إذا كانت المشكلة في الاتصال بالإنترنت:**
- تأكد من الاتصال بالإنترنت
- جرب موقع آخر للتأكد

### **2. إذا كانت المشكلة في URL Supabase:**
- تأكد أن المشروع ما زال فعال في Supabase Dashboard
- إنشاء مشروع جديد إذا لزم الأمر

### **3. إذا كانت الجداول غير موجودة:**
نفذ هذا SQL في Supabase Dashboard:

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

-- جدول المدارس
CREATE TABLE schools (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES educational_organizations(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  school_type VARCHAR(100),
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

-- جدول التقارير
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

-- الفهارس
CREATE INDEX idx_schools_organization ON schools(organization_id);
CREATE INDEX idx_schools_type ON schools(organization_id, school_type);
CREATE INDEX idx_reports_organization ON reports(organization_id, created_at);
CREATE INDEX idx_reports_school ON reports(school_id, report_type);
CREATE INDEX idx_analytics_organization ON organization_analytics(organization_id, period_start);

-- Row Level Security
ALTER TABLE educational_organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_analytics ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان البسيطة (مؤقتاً للاختبار)
CREATE POLICY "Allow all operations on organizations" ON educational_organizations USING (true);
CREATE POLICY "Allow all operations on schools" ON schools USING (true);
CREATE POLICY "Allow all operations on admins" ON organization_admins USING (true);
CREATE POLICY "Allow all operations on reports" ON reports USING (true);
CREATE POLICY "Allow all operations on analytics" ON organization_analytics USING (true);
```

## 🧪 **لاختبار الاتصال:**

أضف هذا الكود في أي مكان مناسب:

```dart
import 'package:school_app_flutter/test_supabase_connection.dart';

// في أي دالة
await testSupabaseConnection();
```

## 📱 **بعد الإصلاح:**

عند نجاح الاتصال، ستظهر رسائل:
```
✅ Supabase initialized successfully
✅ تم الاتصال بـ Supabase بنجاح!
📊 جدول المؤسسات متوفر
🏫 جدول المدارس متوفر
🎉 جميع الجداول متوفرة ويمكن إنشاء المؤسسة!
```

## 🔄 **إعادة تشغيل التطبيق:**

بعد إنشاء الجداول، أعد تشغيل التطبيق وجرب إنشاء مدرسة جديدة.

---

التحديثات المطبقة تضمن استخدام معلومات Supabase الصحيحة من مكان واحد فقط! 🎯
