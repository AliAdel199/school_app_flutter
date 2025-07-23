-- إنشاء جدول اشتراكات المؤسسات
CREATE TABLE IF NOT EXISTS organization_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id INT NOT NULL REFERENCES educational_organizations(id) ON DELETE CASCADE,
    feature VARCHAR(50) NOT NULL, -- مثل 'reports_sync'
    activation_date TIMESTAMP WITH TIME ZONE NOT NULL,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- 'manual', 'credit_card', 'bank_transfer', etc.
    transaction_id VARCHAR(100),
    amount_paid DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- 'active', 'cancelled', 'expired'
    payment_details JSONB,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إضافة فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_org_subscriptions_org_id ON organization_subscriptions(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_subscriptions_feature ON organization_subscriptions(feature);
CREATE INDEX IF NOT EXISTS idx_org_subscriptions_status ON organization_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_org_subscriptions_expiry ON organization_subscriptions(expiry_date);

-- إضافة قيود التحقق
ALTER TABLE organization_subscriptions 
ADD CONSTRAINT chk_subscription_status 
CHECK (status IN ('active', 'cancelled', 'expired'));

ALTER TABLE organization_subscriptions 
ADD CONSTRAINT chk_positive_amount 
CHECK (amount_paid > 0);

-- دالة لتحديث حالة الاشتراكات المنتهية تلقائياً
CREATE OR REPLACE FUNCTION update_expired_subscriptions()
RETURNS void AS $$
BEGIN
    UPDATE organization_subscriptions 
    SET status = 'expired', updated_at = NOW()
    WHERE status = 'active' 
    AND expiry_date < NOW();
END;
$$ LANGUAGE plpgsql;

-- جدولة تشغيل الدالة يومياً (يتطلب تمكين pg_cron)
-- SELECT cron.schedule('update-expired-subscriptions', '0 2 * * *', 'SELECT update_expired_subscriptions();');

-- دالة للحصول على حالة اشتراك محدد
CREATE OR REPLACE FUNCTION get_subscription_status(
    org_id INT,
    feature_name VARCHAR(50)
)
RETURNS TABLE(
    is_active BOOLEAN,
    expiry_date TIMESTAMP WITH TIME ZONE,
    days_remaining INTEGER,
    subscription_data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (s.status = 'active' AND s.expiry_date > NOW()) as is_active,
        s.expiry_date,
        CASE 
            WHEN s.expiry_date > NOW() THEN EXTRACT(DAY FROM s.expiry_date - NOW())::INTEGER
            ELSE 0
        END as days_remaining,
        row_to_json(s)::JSONB as subscription_data
    FROM organization_subscriptions s
    WHERE s.organization_id = org_id 
    AND s.feature = feature_name
    AND s.status = 'active'
    ORDER BY s.created_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- دالة لإحصائيات الاشتراكات
CREATE OR REPLACE FUNCTION get_subscription_stats()
RETURNS TABLE(
    feature VARCHAR(50),
    active_count BIGINT,
    expired_count BIGINT,
    cancelled_count BIGINT,
    total_revenue DECIMAL(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.feature,
        COUNT(*) FILTER (WHERE s.status = 'active' AND s.expiry_date > NOW()) as active_count,
        COUNT(*) FILTER (WHERE s.status = 'expired' OR (s.status = 'active' AND s.expiry_date <= NOW())) as expired_count,
        COUNT(*) FILTER (WHERE s.status = 'cancelled') as cancelled_count,
        COALESCE(SUM(s.amount_paid) FILTER (WHERE s.status IN ('active', 'expired')), 0) as total_revenue
    FROM organization_subscriptions s
    GROUP BY s.feature;
END;
$$ LANGUAGE plpgsql;

-- إضافة أعمدة الاشتراك إلى جدول المؤسسات (إذا لم تكن موجودة)
ALTER TABLE educational_organizations 
ADD COLUMN IF NOT EXISTS reports_sync_active BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS reports_sync_expiry TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS last_subscription_check TIMESTAMP WITH TIME ZONE;

-- دالة لمزامنة حالة الاشتراك في جدول المؤسسات
CREATE OR REPLACE FUNCTION sync_organization_subscription_status()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث حالة الاشتراك في جدول المؤسسات عند تغيير الاشتراك
    IF NEW.feature = 'reports_sync' THEN
        UPDATE educational_organizations
        SET 
            reports_sync_active = (NEW.status = 'active' AND NEW.expiry_date > NOW()),
            reports_sync_expiry = NEW.expiry_date,
            last_subscription_check = NOW()
        WHERE id = NEW.organization_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء Trigger لمزامنة حالة الاشتراك
DROP TRIGGER IF EXISTS sync_subscription_status ON organization_subscriptions;
CREATE TRIGGER sync_subscription_status
    AFTER INSERT OR UPDATE ON organization_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION sync_organization_subscription_status();

-- إنشاء view لعرض معلومات الاشتراكات بشكل مرتب
CREATE OR REPLACE VIEW subscription_status_view AS
SELECT 
    eo.id as organization_id,
    eo.name as organization_name,
    eo.email,
    os.feature,
    os.status,
    os.activation_date,
    os.expiry_date,
    CASE 
        WHEN os.status = 'active' AND os.expiry_date > NOW() THEN 'نشط'
        WHEN os.status = 'active' AND os.expiry_date <= NOW() THEN 'منتهي'
        WHEN os.status = 'cancelled' THEN 'ملغي'
        WHEN os.status = 'expired' THEN 'منتهي'
        ELSE 'غير محدد'
    END as status_ar,
    CASE 
        WHEN os.expiry_date > NOW() THEN EXTRACT(DAY FROM os.expiry_date - NOW())::INTEGER
        ELSE 0
    END as days_remaining,
    os.amount_paid,
    os.payment_method,
    os.created_at,
    os.updated_at
FROM educational_organizations eo
LEFT JOIN organization_subscriptions os ON eo.id = os.organization_id
ORDER BY os.created_at DESC NULLS LAST;

-- إضافة بيانات إحصائية
CREATE OR REPLACE VIEW subscription_stats_view AS
SELECT 
    COUNT(DISTINCT eo.id) as total_organizations,
    COUNT(CASE WHEN os.feature = 'reports_sync' AND os.status = 'active' AND os.expiry_date > NOW() THEN 1 END) as active_reports_sync,
    COUNT(CASE WHEN os.feature = 'reports_sync' AND (os.status = 'expired' OR (os.status = 'active' AND os.expiry_date <= NOW())) THEN 1 END) as expired_reports_sync,
    COUNT(CASE WHEN os.feature = 'reports_sync' AND os.status = 'cancelled' THEN 1 END) as cancelled_reports_sync,
    COALESCE(SUM(CASE WHEN os.feature = 'reports_sync' AND os.status IN ('active', 'expired') THEN os.amount_paid ELSE 0 END), 0) as total_revenue_reports_sync,
    AVG(CASE WHEN os.feature = 'reports_sync' AND os.status = 'active' AND os.expiry_date > NOW() THEN EXTRACT(DAY FROM os.expiry_date - NOW()) END) as avg_days_remaining
FROM educational_organizations eo
LEFT JOIN organization_subscriptions os ON eo.id = os.organization_id;

-- دالة للبحث عن اشتراكات تنتهي قريباً
CREATE OR REPLACE FUNCTION get_expiring_subscriptions(days_ahead INTEGER DEFAULT 7)
RETURNS TABLE(
    organization_id INT,
    organization_name TEXT,
    organization_email TEXT,
    feature VARCHAR(50),
    expiry_date TIMESTAMP WITH TIME ZONE,
    days_remaining INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        eo.id,
        eo.name,
        eo.email,
        os.feature,
        os.expiry_date,
        EXTRACT(DAY FROM os.expiry_date - NOW())::INTEGER as days_remaining
    FROM educational_organizations eo
    JOIN organization_subscriptions os ON eo.id = os.organization_id
    WHERE os.status = 'active'
    AND os.expiry_date > NOW()
    AND os.expiry_date <= NOW() + INTERVAL '1 day' * days_ahead
    ORDER BY os.expiry_date ASC;
END;
$$ LANGUAGE plpgsql;

-- دالة لتجديد الاشتراك
CREATE OR REPLACE FUNCTION renew_subscription(
    org_id INT,
    feature_name VARCHAR(50),
    new_payment_method VARCHAR(50),
    new_transaction_id VARCHAR(100),
    new_amount DECIMAL(10,2),
    extension_days INTEGER DEFAULT 30
)
RETURNS UUID AS $$
DECLARE
    current_expiry TIMESTAMP WITH TIME ZONE;
    new_expiry TIMESTAMP WITH TIME ZONE;
    new_subscription_id UUID;
BEGIN
    -- الحصول على تاريخ انتهاء الاشتراك الحالي
    SELECT expiry_date INTO current_expiry
    FROM organization_subscriptions
    WHERE organization_id = org_id 
    AND feature = feature_name
    AND status = 'active'
    ORDER BY created_at DESC
    LIMIT 1;
    
    -- تحديد تاريخ الانتهاء الجديد
    IF current_expiry IS NULL OR current_expiry <= NOW() THEN
        new_expiry := NOW() + INTERVAL '1 day' * extension_days;
    ELSE
        new_expiry := current_expiry + INTERVAL '1 day' * extension_days;
    END IF;
    
    -- إنشاء اشتراك جديد
    INSERT INTO organization_subscriptions (
        organization_id,
        feature,
        activation_date,
        expiry_date,
        payment_method,
        transaction_id,
        amount_paid,
        status
    ) VALUES (
        org_id,
        feature_name,
        NOW(),
        new_expiry,
        new_payment_method,
        new_transaction_id,
        new_amount,
        'active'
    ) RETURNING id INTO new_subscription_id;
    
    -- إلغاء الاشتراكات القديمة
    UPDATE organization_subscriptions
    SET status = 'cancelled', cancelled_at = NOW(), updated_at = NOW()
    WHERE organization_id = org_id 
    AND feature = feature_name
    AND id != new_subscription_id
    AND status = 'active';
    
    RETURN new_subscription_id;
END;
$$ LANGUAGE plpgsql;

-- سياسات الأمان (RLS) للاشتراكات
-- تأكد من أن المؤسسة يمكنها رؤية اشتراكاتها فقط
CREATE POLICY "Organizations can view their own subscriptions" ON organization_subscriptions
    FOR SELECT USING (
        auth.uid()::text IN (
            SELECT user_id::text FROM organization_admins 
            WHERE organization_id = organization_subscriptions.organization_id 
            AND is_active = true
        )
    );

CREATE POLICY "Organizations can manage their own subscriptions" ON organization_subscriptions
    FOR ALL USING (
        auth.uid()::text IN (
            SELECT user_id::text FROM organization_admins 
            WHERE organization_id = organization_subscriptions.organization_id 
            AND is_active = true
        )
    );

-- منح الصلاحيات للخدمة
GRANT SELECT, INSERT, UPDATE ON organization_subscriptions TO authenticated;
GRANT SELECT ON subscription_status_view TO authenticated;
GRANT SELECT ON subscription_stats_view TO authenticated;
GRANT EXECUTE ON FUNCTION get_subscription_status(INT, VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION get_subscription_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION get_expiring_subscriptions(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION renew_subscription(INT, VARCHAR, VARCHAR, VARCHAR, DECIMAL, INTEGER) TO authenticated;

-- إدراج بيانات تجريبية (اختياري - للاختبار فقط)
-- INSERT INTO organization_subscriptions (
--     organization_id,
--     feature,
--     activation_date,
--     expiry_date,
--     payment_method,
--     transaction_id,
--     amount_paid,
--     status,
--     payment_details
-- ) VALUES 
-- (1, 'reports_sync', NOW(), NOW() + INTERVAL '30 days', 'manual', 'TEST001', 50.00, 'active', '{"test": true}')
-- ON CONFLICT DO NOTHING;

-- رسائل التأكيد
DO $$
BEGIN
    RAISE NOTICE 'تم إنشاء جداول ودوال الاشتراكات بنجاح';
    RAISE NOTICE 'الميزات المتاحة:';
    RAISE NOTICE '- reports_sync: مزامنة التقارير السحابية (50 ريال شهرياً)';
    RAISE NOTICE '';
    RAISE NOTICE 'الدوال المتاحة:';
    RAISE NOTICE '- get_subscription_status(org_id, feature_name)';
    RAISE NOTICE '- get_subscription_stats()';
    RAISE NOTICE '- get_expiring_subscriptions(days_ahead)';
    RAISE NOTICE '- renew_subscription(org_id, feature, payment_method, transaction_id, amount, days)';
    RAISE NOTICE '- update_expired_subscriptions()';
    RAISE NOTICE '';
    RAISE NOTICE 'Views المتاحة:';
    RAISE NOTICE '- subscription_status_view';
    RAISE NOTICE '- subscription_stats_view';
END $$;
