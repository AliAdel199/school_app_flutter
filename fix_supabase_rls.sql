-- حل مشكلة Row Level Security في Supabase
-- نفذ هذا SQL في Supabase Dashboard → SQL Editor

-- إزالة السياسات الحالية
DROP POLICY IF EXISTS "Allow all operations on organizations" ON educational_organizations;
DROP POLICY IF EXISTS "Allow all operations on schools" ON schools;
DROP POLICY IF EXISTS "Allow all operations on admins" ON organization_admins;
DROP POLICY IF EXISTS "Allow all operations on reports" ON reports;
DROP POLICY IF EXISTS "Allow all operations on analytics" ON organization_analytics;

-- تعطيل RLS مؤقتاً للتجربة (يمكن إعادة تفعيله لاحقاً)
ALTER TABLE educational_organizations DISABLE ROW LEVEL SECURITY;
ALTER TABLE schools DISABLE ROW LEVEL SECURITY;
ALTER TABLE organization_admins DISABLE ROW LEVEL SECURITY;
ALTER TABLE reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE organization_analytics DISABLE ROW LEVEL SECURITY;

-- أو إبقاء RLS مفعل مع سياسات مؤقتة مفتوحة للتجربة
-- ALTER TABLE educational_organizations ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE organization_admins ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE organization_analytics ENABLE ROW LEVEL SECURITY;

-- -- سياسات مؤقتة مفتوحة (لأغراض التجربة فقط)
-- CREATE POLICY "temp_allow_all_organizations" ON educational_organizations FOR ALL USING (true) WITH CHECK (true);
-- CREATE POLICY "temp_allow_all_schools" ON schools FOR ALL USING (true) WITH CHECK (true);
-- CREATE POLICY "temp_allow_all_admins" ON organization_admins FOR ALL USING (true) WITH CHECK (true);
-- CREATE POLICY "temp_allow_all_reports" ON reports FOR ALL USING (true) WITH CHECK (true);
-- CREATE POLICY "temp_allow_all_analytics" ON organization_analytics FOR ALL USING (true) WITH CHECK (true);

-- التحقق من الجداول
SELECT 'educational_organizations' as table_name, COUNT(*) as row_count FROM educational_organizations
UNION ALL
SELECT 'schools' as table_name, COUNT(*) as row_count FROM schools
UNION ALL
SELECT 'organization_admins' as table_name, COUNT(*) as row_count FROM organization_admins;
