-- إنشاء قاعدة بيانات Supabase كاملة بدون RLS
-- الجداول الأساسية للنظام التعليمي

-- إزالة أي قيود موجودة قد تسبب مشاكل
ALTER TABLE IF EXISTS schools DROP CONSTRAINT IF EXISTS schools_school_type_check;

-- 1. جدول المؤسسات التعليمية
CREATE TABLE IF NOT EXISTS educational_organizations (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    logo_url TEXT,
    subscription_plan VARCHAR(50) DEFAULT 'basic',
    subscription_status VARCHAR(50) DEFAULT 'trial',
    trial_expires_at TIMESTAMP WITH TIME ZONE,
    max_schools INTEGER DEFAULT 1,
    max_students INTEGER DEFAULT 100,
    device_fingerprint TEXT,
    device_info JSONB,
    last_activation_at TIMESTAMP WITH TIME ZONE,
    activation_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. جدول المدارس
CREATE TABLE IF NOT EXISTS schools (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    school_type VARCHAR(100) NOT NULL,
    -- grade_levels INTEGER[],
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    logo_url TEXT,
    current_students_count INTEGER DEFAULT 0,
    max_students_count INTEGER DEFAULT 100,
    established_year INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- إزالة أي قيود على school_type للسماح بأي قيمة نصية
    CONSTRAINT schools_max_students_check CHECK (max_students_count > 0)
);

-- 3. جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    school_id BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(100) NOT NULL,
    permissions JSONB,
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. جدول الطلاب
CREATE TABLE IF NOT EXISTS students (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    school_id BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    student_id VARCHAR(100) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    phone VARCHAR(50),
    email VARCHAR(255),
    parent_name VARCHAR(255),
    parent_phone VARCHAR(50),
    parent_email VARCHAR(255),
    address TEXT,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    grade_level INTEGER,
    section VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    notes TEXT,
    profile_photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(organization_id, school_id, student_id)
);

-- 5. جدول الصفوف
CREATE TABLE IF NOT EXISTS classes (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    school_id BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    class_name VARCHAR(255) NOT NULL,
    grade_level INTEGER NOT NULL,
    section VARCHAR(100),
    teacher_id UUID REFERENCES users(id) ON DELETE SET NULL,
    max_students INTEGER DEFAULT 30,
    current_students_count INTEGER DEFAULT 0,
    subject VARCHAR(255),
    room_number VARCHAR(100),
    schedule JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(organization_id, school_id, class_name, grade_level, section)
);

-- 6. جدول ربط الطلاب بالصفوف
CREATE TABLE IF NOT EXISTS student_classes (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    school_id BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
    class_id BIGINT REFERENCES classes(id) ON DELETE CASCADE,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(50) DEFAULT 'active',
    final_grade NUMERIC(5,2),
    attendance_percentage NUMERIC(5,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, class_id)
);

-- 7. جدول المدفوعات
CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    school_id BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
    amount NUMERIC(10,2) NOT NULL,
    payment_type VARCHAR(100) NOT NULL,
    payment_method VARCHAR(100),
    payment_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    status VARCHAR(50) DEFAULT 'pending',
    receipt_number VARCHAR(255),
    notes TEXT,
    academic_year VARCHAR(20),
    term VARCHAR(50),
    discount_amount NUMERIC(10,2) DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_schools_organization_id ON schools(organization_id);
CREATE INDEX IF NOT EXISTS idx_students_organization_school ON students(organization_id, school_id);
CREATE INDEX IF NOT EXISTS idx_students_status ON students(status);
CREATE INDEX IF NOT EXISTS idx_classes_organization_school ON classes(organization_id, school_id);
CREATE INDEX IF NOT EXISTS idx_student_classes_student_id ON student_classes(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_organization_school ON payments(organization_id, school_id);
CREATE INDEX IF NOT EXISTS idx_payments_student_status ON payments(student_id, status);
CREATE INDEX IF NOT EXISTS idx_users_organization_school ON users(organization_id, school_id);

-- إنشاء View لحالة التراخيص
CREATE OR REPLACE VIEW license_status_view AS
SELECT 
    eo.id as organization_id,
    eo.name as organization_name,
    eo.email,
    eo.subscription_plan,
    eo.subscription_status,
    eo.trial_expires_at,
    eo.max_schools,
    eo.max_students,
    eo.device_fingerprint,
    eo.device_info,
    eo.last_activation_at,
    eo.activation_count,
    COUNT(DISTINCT s.id) as current_schools_count,
    COUNT(DISTINCT st.id) as current_students_count,
    CASE 
        WHEN eo.subscription_status = 'trial' AND eo.trial_expires_at < NOW() THEN 'expired'
        WHEN eo.subscription_status = 'trial' AND eo.trial_expires_at >= NOW() THEN 'trial_active'
        WHEN eo.subscription_status = 'active' THEN 'active'
        ELSE 'inactive'
    END as license_status,
    CASE 
        WHEN COUNT(DISTINCT s.id) > eo.max_schools THEN false
        WHEN COUNT(DISTINCT st.id) > eo.max_students THEN false
        ELSE true
    END as within_limits,
    eo.created_at,
    eo.updated_at
FROM educational_organizations eo
LEFT JOIN schools s ON eo.id = s.organization_id AND s.is_active = true
LEFT JOIN students st ON eo.id = st.organization_id AND st.status = 'active'
GROUP BY eo.id;

-- إنشاء View للإحصائيات
CREATE OR REPLACE VIEW license_stats_view AS
SELECT 
    eo.id as organization_id,
    eo.name as organization_name,
    eo.subscription_plan,
    eo.subscription_status,
    COUNT(DISTINCT s.id) as total_schools,
    COUNT(DISTINCT st.id) as total_students,
    COUNT(DISTINCT u.id) as total_users,
    COUNT(DISTINCT c.id) as total_classes,
    COALESCE(SUM(p.amount), 0) as total_revenue,
    COUNT(DISTINCT CASE WHEN p.status = 'paid' THEN p.id END) as paid_payments,
    COUNT(DISTINCT CASE WHEN p.status = 'pending' THEN p.id END) as pending_payments,
    eo.created_at as organization_created_at,
    MAX(u.last_login_at) as last_user_activity
FROM educational_organizations eo
LEFT JOIN schools s ON eo.id = s.organization_id
LEFT JOIN students st ON eo.id = st.organization_id
LEFT JOIN users u ON eo.id = u.organization_id
LEFT JOIN classes c ON eo.id = c.organization_id
LEFT JOIN payments p ON eo.id = p.organization_id
GROUP BY eo.id;

-- دالة لتحديث عدد الطلاب في المدرسة
CREATE OR REPLACE FUNCTION update_school_student_count()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث عدد الطلاب في المدرسة
    UPDATE schools 
    SET current_students_count = (
        SELECT COUNT(*) 
        FROM students 
        WHERE school_id = COALESCE(NEW.school_id, OLD.school_id) 
        AND status = 'active'
    )
    WHERE id = COALESCE(NEW.school_id, OLD.school_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- دالة لتحديث عدد الطلاب في الصف
CREATE OR REPLACE FUNCTION update_class_student_count()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث عدد الطلاب في الصف
    UPDATE classes 
    SET current_students_count = (
        SELECT COUNT(*) 
        FROM student_classes 
        WHERE class_id = COALESCE(NEW.class_id, OLD.class_id) 
        AND status = 'active'
    )
    WHERE id = COALESCE(NEW.class_id, OLD.class_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- دالة لتحديث updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء الـ Triggers
-- تحديث عدد الطلاب عند إضافة/حذف/تعديل طلاب
DROP TRIGGER IF EXISTS trigger_update_school_student_count_insert ON students;
CREATE TRIGGER trigger_update_school_student_count_insert
    AFTER INSERT ON students
    FOR EACH ROW
    EXECUTE FUNCTION update_school_student_count();

DROP TRIGGER IF EXISTS trigger_update_school_student_count_update ON students;
CREATE TRIGGER trigger_update_school_student_count_update
    AFTER UPDATE ON students
    FOR EACH ROW
    EXECUTE FUNCTION update_school_student_count();

DROP TRIGGER IF EXISTS trigger_update_school_student_count_delete ON students;
CREATE TRIGGER trigger_update_school_student_count_delete
    AFTER DELETE ON students
    FOR EACH ROW
    EXECUTE FUNCTION update_school_student_count();

-- تحديث عدد الطلاب في الصف عند إضافة/حذف/تعديل student_classes
DROP TRIGGER IF EXISTS trigger_update_class_student_count_insert ON student_classes;
CREATE TRIGGER trigger_update_class_student_count_insert
    AFTER INSERT ON student_classes
    FOR EACH ROW
    EXECUTE FUNCTION update_class_student_count();

DROP TRIGGER IF EXISTS trigger_update_class_student_count_update ON student_classes;
CREATE TRIGGER trigger_update_class_student_count_update
    AFTER UPDATE ON student_classes
    FOR EACH ROW
    EXECUTE FUNCTION update_class_student_count();

DROP TRIGGER IF EXISTS trigger_update_class_student_count_delete ON student_classes;
CREATE TRIGGER trigger_update_class_student_count_delete
    AFTER DELETE ON student_classes
    FOR EACH ROW
    EXECUTE FUNCTION update_class_student_count();

-- تحديث updated_at للجداول
DROP TRIGGER IF EXISTS trigger_updated_at_educational_organizations ON educational_organizations;
CREATE TRIGGER trigger_updated_at_educational_organizations
    BEFORE UPDATE ON educational_organizations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_updated_at_schools ON schools;
CREATE TRIGGER trigger_updated_at_schools
    BEFORE UPDATE ON schools
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_updated_at_users ON users;
CREATE TRIGGER trigger_updated_at_users
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_updated_at_students ON students;
CREATE TRIGGER trigger_updated_at_students
    BEFORE UPDATE ON students
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_updated_at_classes ON classes;
CREATE TRIGGER trigger_updated_at_classes
    BEFORE UPDATE ON classes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_updated_at_student_classes ON student_classes;
CREATE TRIGGER trigger_updated_at_student_classes
    BEFORE UPDATE ON student_classes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_updated_at_payments ON payments;
CREATE TRIGGER trigger_updated_at_payments
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- إدراج بيانات تجريبية
INSERT INTO educational_organizations (name, email, phone, address, subscription_plan, subscription_status, trial_expires_at, max_schools, max_students, device_fingerprint) VALUES
('مؤسسة التعليم المتميز', 'admin@excellence-edu.com', '+1234567890', 'شارع الجامعة، المدينة التعليمية', 'premium', 'active', '2025-12-31 23:59:59', 5, 1000, 'device_123456'),
('مجموعة مدارس المستقبل', 'info@future-schools.com', '+1234567891', 'حي النهضة، طريق الملك فهد', 'basic', 'trial', '2024-12-31 23:59:59', 1, 100, 'device_789012')
ON CONFLICT (email) DO NOTHING;

INSERT INTO schools (organization_id, name, school_type, grade_levels, email, phone, address, max_students_count) VALUES
(1, 'مدرسة الإبداع الابتدائية', 'primary', '{1,2,3,4,5,6}', 'primary@excellence-edu.com', '+1234567892', 'فرع الابتدائي', 300),
(1, 'مدرسة التميز الثانوية', 'secondary', '{7,8,9,10,11,12}', 'secondary@excellence-edu.com', '+1234567893', 'فرع الثانوي', 400),
(2, 'مدرسة المستقبل الأهلية', 'mixed', '{1,2,3,4,5,6,7,8,9,10,11,12}', 'info@future-schools.com', '+1234567891', 'حي النهضة', 100)
ON CONFLICT (organization_id, name) DO NOTHING;

-- تأكيد إنشاء قاعدة البيانات
SELECT 'Database schema created successfully!' as status;
