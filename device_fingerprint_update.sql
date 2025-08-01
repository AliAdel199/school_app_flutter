-- تحديث جداول Supabase لإضافة device_fingerprint

-- إضافة حقل device_fingerprint إلى جدول educational_organizations إذا لم يكن موجوداً
ALTER TABLE educational_organizations 
ADD COLUMN IF NOT EXISTS device_fingerprint VARCHAR(255);

-- إضافة حقل activation_code إذا لم يكن موجوداً
ALTER TABLE educational_organizations 
ADD COLUMN IF NOT EXISTS activation_code VARCHAR(255);

-- إضافة حقل last_device_sync إذا لم يكن موجوداً
ALTER TABLE educational_organizations 
ADD COLUMN IF NOT EXISTS last_device_sync TIMESTAMPTZ;

-- إضافة فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_educational_organizations_device_fingerprint 
ON educational_organizations(device_fingerprint);

CREATE INDEX IF NOT EXISTS idx_educational_organizations_activation_code 
ON educational_organizations(activation_code);

CREATE INDEX IF NOT EXISTS idx_educational_organizations_last_device_sync 
ON educational_organizations(last_device_sync);

-- تحديث Views ليعمل مع الحقول الجديدة
DROP VIEW IF EXISTS public.license_status_view;
DROP VIEW IF EXISTS public.license_stats_view;

-- إعادة إنشاء view لحالة الترخيص مع device_fingerprint
CREATE VIEW public.license_status_view AS
SELECT
  id,
  name AS organization_name,
  email,
  subscription_status,
  subscription_plan,
  trial_expires_at,
  device_fingerprint,
  activation_code,
  CASE
    WHEN device_fingerprint IS NOT NULL THEN 'مُعرَّف'::text
    ELSE 'غير مُعرَّف'::text
  END AS device_status,
  CASE
    WHEN activation_code IS NOT NULL THEN 'موجود'::text
    ELSE 'غير موجود'::text
  END AS activation_code_status,
  last_device_sync,
  CASE
    WHEN last_device_sync IS NULL THEN 'لم يتم المزامنة'::text
    WHEN last_device_sync < (NOW() - '7 days'::interval) THEN 'قديم'::text
    WHEN last_device_sync < (NOW() - '1 day'::interval) THEN 'متوسط'::text
    ELSE 'حديث'::text
  END AS sync_freshness,
  created_at,
  updated_at
FROM
  educational_organizations
ORDER BY
  last_device_sync DESC NULLS LAST,
  created_at DESC;

-- إعادة إنشاء view للإحصائيات
CREATE VIEW public.license_stats_view AS
SELECT
  COUNT(*) AS total_organizations,
  COUNT(
    CASE
      WHEN subscription_status::text = 'active'::text THEN 1
      ELSE NULL::integer
    END
  ) AS active_count,
  COUNT(
    CASE
      WHEN subscription_status::text = 'trial'::text THEN 1
      ELSE NULL::integer
    END
  ) AS trial_count,
  COUNT(
    CASE
      WHEN subscription_status::text = 'expired'::text THEN 1
      ELSE NULL::integer
    END
  ) AS expired_count,
  COUNT(
    CASE
      WHEN device_fingerprint IS NOT NULL THEN 1
      ELSE NULL::integer
    END
  ) AS devices_registered,
  COUNT(
    CASE
      WHEN last_device_sync > (NOW() - '1 day'::interval) THEN 1
      ELSE NULL::integer
    END
  ) AS recently_synced,
  AVG(
    CASE
      WHEN last_device_sync IS NOT NULL THEN EXTRACT(
        epoch
        FROM
          NOW() - last_device_sync
      ) / 86400::numeric
      ELSE NULL::numeric
    END
  ) AS avg_days_since_sync
FROM
  educational_organizations;

-- منح الصلاحيات للـ views
GRANT SELECT ON public.license_status_view TO authenticated;
GRANT SELECT ON public.license_stats_view TO authenticated;
GRANT SELECT ON public.license_status_view TO anon;
GRANT SELECT ON public.license_stats_view TO anon;

-- تعليق توضيحي
COMMENT ON VIEW public.license_status_view IS 'عرض حالة الترخيص للمؤسسات التعليمية مع معلومات الجهاز والمزامنة المحدث';
COMMENT ON VIEW public.license_stats_view IS 'إحصائيات شاملة لجميع التراخيص والمؤسسات المحدث';

-- دالة لتحديث device_fingerprint
CREATE OR REPLACE FUNCTION update_device_fingerprint(
  org_id UUID,
  fingerprint VARCHAR(255)
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE educational_organizations 
  SET 
    device_fingerprint = fingerprint,
    last_device_sync = NOW(),
    updated_at = NOW()
  WHERE id = org_id;
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لتحديث activation_code
CREATE OR REPLACE FUNCTION update_activation_code(
  org_id UUID,
  code VARCHAR(255)
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE educational_organizations 
  SET 
    activation_code = code,
    updated_at = NOW()
  WHERE id = org_id;
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لمزامنة بيانات الجهاز
CREATE OR REPLACE FUNCTION sync_device_data(
  org_id UUID,
  fingerprint VARCHAR(255) DEFAULT NULL,
  code VARCHAR(255) DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  UPDATE educational_organizations 
  SET 
    device_fingerprint = COALESCE(fingerprint, device_fingerprint),
    activation_code = COALESCE(code, activation_code),
    last_device_sync = NOW(),
    updated_at = NOW()
  WHERE id = org_id;
  
  IF FOUND THEN
    SELECT row_to_json(t) INTO result
    FROM (
      SELECT 
        'success' as status,
        'تم تحديث بيانات الجهاز بنجاح' as message,
        NOW() as synced_at
    ) t;
  ELSE
    SELECT row_to_json(t) INTO result
    FROM (
      SELECT 
        'error' as status,
        'لم يتم العثور على المؤسسة' as message
    ) t;
  END IF;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
