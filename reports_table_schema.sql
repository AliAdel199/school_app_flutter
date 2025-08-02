-- إنشاء جدول التقارير العامة في Supabase
-- يحتوي على تقارير المدارس لعرضها في تطبيق المدراء

CREATE TABLE IF NOT EXISTS school_reports (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES educational_organizations(id) ON DELETE CASCADE,
    school_id BIGINT REFERENCES schools(id) ON DELETE CASCADE,
    
    -- معلومات التقرير
    report_title VARCHAR(255) NOT NULL DEFAULT 'تقرير عام',
    report_type VARCHAR(100) NOT NULL DEFAULT 'general',
    academic_year VARCHAR(50), -- مثل "2024-2025"
    period_start DATE,
    period_end DATE,
    
    -- بيانات الطلاب
    total_students INTEGER DEFAULT 0,
    active_students INTEGER DEFAULT 0,
    inactive_students INTEGER DEFAULT 0,
    graduated_students INTEGER DEFAULT 0,
    withdrawn_students INTEGER DEFAULT 0,
    
    -- البيانات المالية
    total_annual_fees DECIMAL(15,2) DEFAULT 0,
    total_paid DECIMAL(15,2) DEFAULT 0,
    total_due DECIMAL(15,2) DEFAULT 0,
    total_incomes DECIMAL(15,2) DEFAULT 0,
    total_expenses DECIMAL(15,2) DEFAULT 0,
    net_balance DECIMAL(15,2) DEFAULT 0,
    
    -- بيانات إضافية (JSON للمرونة)
    additional_data JSONB,
    
    -- معلومات النظام
    report_generated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_school_reports_organization_id ON school_reports(organization_id);
CREATE INDEX IF NOT EXISTS idx_school_reports_school_id ON school_reports(school_id);
CREATE INDEX IF NOT EXISTS idx_school_reports_academic_year ON school_reports(academic_year);
CREATE INDEX IF NOT EXISTS idx_school_reports_generated_at ON school_reports(generated_at);

-- إنشاء تريجر لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_school_reports_updated_at 
    BEFORE UPDATE ON school_reports 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- إضافة تعليقات على الجدول والأعمدة
COMMENT ON TABLE school_reports IS 'جدول التقارير العامة للمدارس';
COMMENT ON COLUMN school_reports.report_type IS 'نوع التقرير: general, financial, academic';
COMMENT ON COLUMN school_reports.academic_year IS 'السنة الدراسية بصيغة YYYY-YYYY';
COMMENT ON COLUMN school_reports.additional_data IS 'بيانات إضافية بصيغة JSON للمرونة المستقبلية';
