-- إنشاء Views للترخيص في Supabase
-- يجب تشغيل هذا الملف في Supabase SQL Editor

-- حذف الـ views إذا كانت موجودة
DROP VIEW IF EXISTS public.license_status_view;
DROP VIEW IF EXISTS public.license_stats_view;

-- إنشاء view لحالة الترخيص
CREATE VIEW public.license_status_view AS
SELECT
  id,
  name AS organization_name,
  email,
  subscription_status,
  subscription_plan,
  trial_expires_at,
  device_fingerprint,
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

-- إنشاء view للإحصائيات
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

-- إنشاء Row Level Security للـ views
ALTER VIEW public.license_status_view SET (security_invoker = on);
ALTER VIEW public.license_stats_view SET (security_invoker = on);

-- تعليق توضيحي
COMMENT ON VIEW public.license_status_view IS 'عرض حالة الترخيص للمؤسسات التعليمية مع معلومات الجهاز والمزامنة';
COMMENT ON VIEW public.license_stats_view IS 'إحصائيات شاملة لجميع التراخيص والمؤسسات';
