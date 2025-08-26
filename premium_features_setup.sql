-- إضافة نظام الميزات المدفوعة للتقارير الأونلاين
-- تشغيل هذا في Supabase SQL Editor

-- 1. إضافة عمود features لجدول educational_organizations
ALTER TABLE educational_organizations 
ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '{}';

-- 2. إنشاء جدول مشتريات الميزات
CREATE TABLE IF NOT EXISTS feature_purchases (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    feature_name TEXT NOT NULL,
    payment_method TEXT,
    amount DECIMAL(10,2),
    currency TEXT DEFAULT 'IQD',
    purchase_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. إنشاء جدول التقارير إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS reports (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    school_id BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    report_type TEXT NOT NULL,
    report_title TEXT NOT NULL,
    report_data JSONB NOT NULL,
    period TEXT,
    generated_by TEXT,
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'uploaded' CHECK (status IN ('uploaded', 'processing', 'completed', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. إضافة فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_feature_purchases_org_feature 
ON feature_purchases(organization_id, feature_name);

CREATE INDEX IF NOT EXISTS idx_feature_purchases_status_expires 
ON feature_purchases(status, expires_at);

CREATE INDEX IF NOT EXISTS idx_reports_organization 
ON reports(organization_id);

CREATE INDEX IF NOT EXISTS idx_reports_school 
ON reports(school_id);

CREATE INDEX IF NOT EXISTS idx_reports_type_period 
ON reports(report_type, period);

-- 5. إضافة RLS (Row Level Security)
ALTER TABLE feature_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- 6. سياسات RLS للمديرين
-- سياسة للقراءة من feature_purchases
CREATE POLICY IF NOT EXISTS "Admins can view organization features" 
ON feature_purchases FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.organization_id = feature_purchases.organization_id
        AND users.role IN ('admin', 'super_admin')
    )
);

-- سياسة للإدراج في feature_purchases
CREATE POLICY IF NOT EXISTS "Admins can purchase features" 
ON feature_purchases FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.organization_id = feature_purchases.organization_id
        AND users.role IN ('admin', 'super_admin')
    )
);

-- سياسة للقراءة من reports
CREATE POLICY IF NOT EXISTS "Admins can view organization reports" 
ON reports FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.organization_id = reports.organization_id
        AND users.role IN ('admin', 'super_admin', 'teacher')
    )
);

-- سياسة للإدراج في reports
CREATE POLICY IF NOT EXISTS "Admins can upload reports" 
ON reports FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.organization_id = reports.organization_id
        AND users.role IN ('admin', 'super_admin')
    )
);

-- 7. دالة للتحقق من صلاحية الميزة
CREATE OR REPLACE FUNCTION check_feature_access(
    org_id BIGINT,
    feature_name TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    org_plan TEXT;
    feature_active BOOLEAN := FALSE;
    purchase_record RECORD;
BEGIN
    -- التحقق من خطة المؤسسة
    SELECT subscription_plan INTO org_plan
    FROM educational_organizations
    WHERE id = org_id;
    
    -- الباقات المدفوعة تحصل على جميع الميزات
    IF org_plan IN ('premium', 'enterprise') THEN
        RETURN TRUE;
    END IF;
    
    -- التحقق من المشتريات المنفصلة
    SELECT * INTO purchase_record
    FROM feature_purchases
    WHERE organization_id = org_id
      AND feature_name = check_feature_access.feature_name
      AND status = 'active'
      AND (expires_at IS NULL OR expires_at > NOW())
    ORDER BY created_at DESC
    LIMIT 1;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. دالة مساعدة لتحديث تواريخ انتهاء الميزات المنتهية
CREATE OR REPLACE FUNCTION update_expired_features()
RETURNS VOID AS $$
BEGIN
    UPDATE feature_purchases
    SET status = 'expired'
    WHERE status = 'active'
      AND expires_at IS NOT NULL
      AND expires_at <= NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. إضافة trigger لتحديث updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إضافة triggers
CREATE TRIGGER IF NOT EXISTS update_feature_purchases_updated_at
    BEFORE UPDATE ON feature_purchases
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER IF NOT EXISTS update_reports_updated_at
    BEFORE UPDATE ON reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 10. تحديث المؤسسات الموجودة لتشمل الميزات الافتراضية
UPDATE educational_organizations
SET features = CASE 
    WHEN subscription_plan IN ('premium', 'enterprise') THEN '{"online_reports": true}'::jsonb
    ELSE '{}'::jsonb
END
WHERE features IS NULL;

-- رسالة النجاح
SELECT 'تم تثبيت نظام الميزات المدفوعة بنجاح!' as message;
