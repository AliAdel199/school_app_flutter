-- إزالة قيد التحقق من school_type للسماح بأي قيمة
ALTER TABLE schools DROP CONSTRAINT IF EXISTS schools_school_type_check;

-- التحقق من إزالة القيد
SELECT conname, contype, pg_get_constraintdef(c.oid) 
FROM pg_constraint c 
JOIN pg_class t ON c.conrelid = t.oid 
WHERE t.relname = 'schools' AND contype = 'c';

-- إضافة قيد جديد أكثر مرونة (اختياري)
-- ALTER TABLE schools ADD CONSTRAINT schools_school_type_not_empty CHECK (LENGTH(school_type) > 0);

SELECT 'School type constraint removed successfully!' as status;
