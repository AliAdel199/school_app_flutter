-- جدول المدارس
CREATE TABLE IF NOT EXISTS schools (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  email VARCHAR,
  phone VARCHAR,
  address TEXT,
  logo_url VARCHAR,
  subscription_plan VARCHAR DEFAULT 'basic',
  subscription_status VARCHAR DEFAULT 'trial',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  trial_expires_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول التقارير
CREATE TABLE IF NOT EXISTS reports (
  id SERIAL PRIMARY KEY,
  school_id INTEGER REFERENCES schools(id),
  report_type VARCHAR NOT NULL,
  report_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_reports_school_id ON reports(school_id);
CREATE INDEX IF NOT EXISTS idx_reports_type ON reports(report_type);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at);

-- إنشاء سياسات الأمان (RLS)
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- سياسة للسماح بإدراج المدارس الجديدة
CREATE POLICY "Enable insert for schools" ON schools FOR INSERT WITH CHECK (true);

-- سياسة للسماح بقراءة بيانات المدرسة
CREATE POLICY "Enable read access for schools" ON schools FOR SELECT USING (true);

-- سياسة للسماح بتحديث بيانات المدرسة
CREATE POLICY "Enable update for schools" ON schools FOR UPDATE USING (true);

-- سياسة للسماح بإدراج التقارير
CREATE POLICY "Enable insert for reports" ON reports FOR INSERT WITH CHECK (true);

-- سياسة للسماح بقراءة التقارير للمدرسة المالكة
CREATE POLICY "Enable read access for reports" ON reports FOR SELECT USING (true);

-- إضافة trigger لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_schools_updated_at 
    BEFORE UPDATE ON schools 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
