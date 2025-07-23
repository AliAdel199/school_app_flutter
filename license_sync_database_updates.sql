-- إضافة أعمدة معلومات الترخيص إلى جدول educational_organizations
-- تشغيل هذا الكود في محرر SQL في Supabase

-- إضافة الأعمدة الجديدة
ALTER TABLE educational_organizations 
ADD COLUMN IF NOT EXISTS device_fingerprint TEXT,
ADD COLUMN IF NOT EXISTS activation_code TEXT,
ADD COLUMN IF NOT EXISTS last_device_sync TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- إضافة تعليق على الأعمدة للتوضيح
COMMENT ON COLUMN educational_organizations.device_fingerprint IS 'بصمة الجهاز المشفرة - معرف فريد للجهاز المثبت عليه التطبيق';
COMMENT ON COLUMN educational_organizations.activation_code IS 'كود التفعيل المشفر للمؤسسة';
COMMENT ON COLUMN educational_organizations.last_device_sync IS 'آخر وقت مزامنة لبيانات الجهاز مع السحابة';

-- إنشاء فهارس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_educational_organizations_device_fingerprint 
ON educational_organizations(device_fingerprint);

CREATE INDEX IF NOT EXISTS idx_educational_organizations_subscription_status 
ON educational_organizations(subscription_status);

CREATE INDEX IF NOT EXISTS idx_educational_organizations_activation_code 
ON educational_organizations(activation_code);

-- إضافة قيود للتحقق من صحة البيانات
ALTER TABLE educational_organizations 
ADD CONSTRAINT chk_subscription_status 
CHECK (subscription_status IN ('trial', 'active', 'expired', 'suspended', 'cancelled'));

-- إنشاء دالة لتحديث last_device_sync تلقائياً
CREATE OR REPLACE FUNCTION update_last_device_sync()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث last_device_sync عند تغيير device_fingerprint أو activation_code
    IF OLD.device_fingerprint IS DISTINCT FROM NEW.device_fingerprint 
       OR OLD.activation_code IS DISTINCT FROM NEW.activation_code THEN
        NEW.last_device_sync = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ربط الدالة بجدول educational_organizations
DROP TRIGGER IF EXISTS tr_update_last_device_sync ON educational_organizations;
CREATE TRIGGER tr_update_last_device_sync
    BEFORE UPDATE ON educational_organizations
    FOR EACH ROW
    EXECUTE FUNCTION update_last_device_sync();

-- إنشاء view لعرض معلومات الترخيص بشكل مرتب
CREATE OR REPLACE VIEW license_status_view AS
SELECT 
    id,
    name as organization_name,
    email,
    subscription_status,
    subscription_plan,
    trial_expires_at,
    device_fingerprint,
    CASE 
        WHEN device_fingerprint IS NOT NULL THEN 'مُعرَّف'
        ELSE 'غير مُعرَّف'
    END as device_status,
    CASE 
        WHEN activation_code IS NOT NULL THEN 'موجود'
        ELSE 'غير موجود'
    END as activation_code_status,
    last_device_sync,
    CASE 
        WHEN last_device_sync IS NULL THEN 'لم يتم المزامنة'
        WHEN last_device_sync < NOW() - INTERVAL '7 days' THEN 'قديم'
        WHEN last_device_sync < NOW() - INTERVAL '1 day' THEN 'متوسط'
        ELSE 'حديث'
    END as sync_freshness,
    created_at,
    updated_at
FROM educational_organizations
ORDER BY last_device_sync DESC NULLS LAST, created_at DESC;

-- إضافة بيانات إحصائية
CREATE OR REPLACE VIEW license_stats_view AS
SELECT 
    COUNT(*) as total_organizations,
    COUNT(CASE WHEN subscription_status = 'active' THEN 1 END) as active_count,
    COUNT(CASE WHEN subscription_status = 'trial' THEN 1 END) as trial_count,
    COUNT(CASE WHEN subscription_status = 'expired' THEN 1 END) as expired_count,
    COUNT(CASE WHEN device_fingerprint IS NOT NULL THEN 1 END) as devices_registered,
    COUNT(CASE WHEN last_device_sync > NOW() - INTERVAL '1 day' THEN 1 END) as recently_synced,
    AVG(CASE WHEN last_device_sync IS NOT NULL THEN EXTRACT(EPOCH FROM (NOW() - last_device_sync))/86400 END) as avg_days_since_sync
FROM educational_organizations;

-- دالة للبحث عن مؤسسة بواسطة بصمة الجهاز
CREATE OR REPLACE FUNCTION find_organization_by_device(fingerprint_input TEXT)
RETURNS TABLE(
    org_id INT,
    org_name TEXT,
    org_email TEXT,
    subscription_status TEXT,
    last_sync TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id,
        name,
        email,
        educational_organizations.subscription_status,
        last_device_sync
    FROM educational_organizations
    WHERE device_fingerprint = fingerprint_input;
END;
$$ LANGUAGE plpgsql;

-- دالة لتحديث حالة الاشتراك بناءً على انتهاء الفترة التجريبية
CREATE OR REPLACE FUNCTION update_expired_trials()
RETURNS INT AS $$
DECLARE
    updated_count INT;
BEGIN
    UPDATE educational_organizations 
    SET subscription_status = 'expired'
    WHERE subscription_status = 'trial' 
      AND trial_expires_at < NOW();
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- جدولة دورية لتحديث الحالات المنتهية (يحتاج pg_cron extension)
-- SELECT cron.schedule('update-expired-trials', '0 1 * * *', 'SELECT update_expired_trials();');

-- إضافة تنبيهات أمنية
CREATE OR REPLACE FUNCTION detect_duplicate_devices()
RETURNS TABLE(
    device_fingerprint TEXT,
    organization_count BIGINT,
    organization_names TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        eo.device_fingerprint,
        COUNT(*) as organization_count,
        ARRAY_AGG(eo.name) as organization_names
    FROM educational_organizations eo
    WHERE eo.device_fingerprint IS NOT NULL
    GROUP BY eo.device_fingerprint
    HAVING COUNT(*) > 1;
END;
$$ LANGUAGE plpgsql;

-- سياسات الأمان (RLS) للترخيص
-- تأكد من أن المؤسسة يمكنها رؤية بياناتها فقط
CREATE POLICY "Organizations can view their own license data" ON educational_organizations
    FOR SELECT USING (
        auth.uid()::text IN (
            SELECT user_id::text FROM organization_admins 
            WHERE organization_id = educational_organizations.id 
            AND is_active = true
        )
    );

CREATE POLICY "Organizations can update their own license data" ON educational_organizations
    FOR UPDATE USING (
        auth.uid()::text IN (
            SELECT user_id::text FROM organization_admins 
            WHERE organization_id = educational_organizations.id 
            AND is_active = true
        )
    );

-- منح الصلاحيات للخدمة
GRANT SELECT, INSERT, UPDATE ON educational_organizations TO authenticated;
GRANT SELECT ON license_status_view TO authenticated;
GRANT SELECT ON license_stats_view TO authenticated;
GRANT EXECUTE ON FUNCTION find_organization_by_device(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION detect_duplicate_devices() TO authenticated;

-- تنبيهات للمطورين
SELECT 'تم تطبيق تحديثات الترخيص بنجاح!' as status;
SELECT 'يمكنك الآن استخدام خدمة مزامنة الترخيص في التطبيق' as message;
