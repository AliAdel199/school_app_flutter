-- إضافة جداول نظام الترخيص الجديد
-- جدول حالة الترخيص
CREATE TABLE IF NOT EXISTS license_status_view (
  id SERIAL PRIMARY KEY,
  school_id INTEGER REFERENCES schools(id),
  status VARCHAR NOT NULL DEFAULT 'trial', -- 'activated', 'trial', 'expired'
  is_activated BOOLEAN DEFAULT FALSE,
  is_trial_active BOOLEAN DEFAULT FALSE,
  remaining_days INTEGER DEFAULT 0,
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  license_key VARCHAR,
  activation_date TIMESTAMPTZ,
  expiry_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول إحصائيات الترخيص
CREATE TABLE IF NOT EXISTS license_stats_view (
  id SERIAL PRIMARY KEY,
  school_id INTEGER REFERENCES schools(id),
  total_students INTEGER DEFAULT 0,
  total_classes INTEGER DEFAULT 0,
  total_users INTEGER DEFAULT 0,
  total_payments INTEGER DEFAULT 0,
  last_calculated TIMESTAMPTZ DEFAULT NOW(),
  license_type VARCHAR DEFAULT 'trial', -- 'trial', 'premium', 'standard'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_license_status_school_id ON license_status_view(school_id);
CREATE INDEX IF NOT EXISTS idx_license_status_status ON license_status_view(status);
CREATE INDEX IF NOT EXISTS idx_license_status_last_updated ON license_status_view(last_updated);

CREATE INDEX IF NOT EXISTS idx_license_stats_school_id ON license_stats_view(school_id);
CREATE INDEX IF NOT EXISTS idx_license_stats_license_type ON license_stats_view(license_type);
CREATE INDEX IF NOT EXISTS idx_license_stats_last_calculated ON license_stats_view(last_calculated);

-- تفعيل RLS للجداول الجديدة
ALTER TABLE license_status_view ENABLE ROW LEVEL SECURITY;
ALTER TABLE license_stats_view ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان لجدول license_status_view
CREATE POLICY "Enable insert for license_status_view" ON license_status_view FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable read access for license_status_view" ON license_status_view FOR SELECT USING (true);
CREATE POLICY "Enable update for license_status_view" ON license_status_view FOR UPDATE USING (true);
CREATE POLICY "Enable delete for license_status_view" ON license_status_view FOR DELETE USING (true);

-- سياسات الأمان لجدول license_stats_view
CREATE POLICY "Enable insert for license_stats_view" ON license_stats_view FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable read access for license_stats_view" ON license_stats_view FOR SELECT USING (true);
CREATE POLICY "Enable update for license_stats_view" ON license_stats_view FOR UPDATE USING (true);
CREATE POLICY "Enable delete for license_stats_view" ON license_stats_view FOR DELETE USING (true);

-- إضافة triggers لتحديث last_updated و last_calculated تلقائياً
CREATE TRIGGER update_license_status_last_updated 
    BEFORE UPDATE ON license_status_view 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- دالة لتحديث last_calculated
CREATE OR REPLACE FUNCTION update_last_calculated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_calculated = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_license_stats_last_calculated 
    BEFORE UPDATE ON license_stats_view 
    FOR EACH ROW 
    EXECUTE FUNCTION update_last_calculated_column();

-- دالة لتحديث إحصائيات الترخيص
CREATE OR REPLACE FUNCTION update_license_stats(school_id_param INTEGER)
RETURNS VOID AS $$
DECLARE
    student_count INTEGER;
    class_count INTEGER;
    user_count INTEGER;
    payment_count INTEGER;
    license_type_val VARCHAR;
BEGIN
    -- حساب عدد الطلاب (يجب تعديل اسم الجدول حسب نظامك)
    SELECT COUNT(*) INTO student_count FROM students WHERE school_id = school_id_param;
    
    -- حساب عدد الصفوف (يجب تعديل اسم الجدول حسب نظامك)
    SELECT COUNT(*) INTO class_count FROM classes WHERE school_id = school_id_param;
    
    -- حساب عدد المستخدمين (يجب تعديل اسم الجدول حسب نظامك)
    SELECT COUNT(*) INTO user_count FROM users WHERE school_id = school_id_param;
    
    -- حساب عدد المدفوعات (يجب تعديل اسم الجدول حسب نظامك)
    SELECT COUNT(*) INTO payment_count FROM student_payments WHERE school_id = school_id_param;
    
    -- تحديد نوع الترخيص
    SELECT 
        CASE 
            WHEN is_activated = true THEN 'premium'
            WHEN is_trial_active = true THEN 'trial'
            ELSE 'expired'
        END 
    INTO license_type_val
    FROM license_status_view 
    WHERE school_id = school_id_param 
    ORDER BY last_updated DESC 
    LIMIT 1;
    
    -- إدراج أو تحديث الإحصائيات
    INSERT INTO license_stats_view (
        school_id, 
        total_students, 
        total_classes, 
        total_users, 
        total_payments, 
        license_type,
        last_calculated
    ) VALUES (
        school_id_param, 
        student_count, 
        class_count, 
        user_count, 
        payment_count, 
        COALESCE(license_type_val, 'trial'),
        NOW()
    )
    ON CONFLICT (school_id) 
    DO UPDATE SET 
        total_students = EXCLUDED.total_students,
        total_classes = EXCLUDED.total_classes,
        total_users = EXCLUDED.total_users,
        total_payments = EXCLUDED.total_payments,
        license_type = EXCLUDED.license_type,
        last_calculated = NOW();
END;
$$ language 'plpgsql';

-- إضافة unique constraint لمنع تكرار البيانات لنفس المدرسة
ALTER TABLE license_status_view ADD CONSTRAINT unique_school_license_status UNIQUE (school_id);
ALTER TABLE license_stats_view ADD CONSTRAINT unique_school_license_stats UNIQUE (school_id);
