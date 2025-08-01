import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class DatabaseTestScreen extends StatefulWidget {
  @override
  _DatabaseTestScreenState createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  String _output = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار قاعدة البيانات الجديدة'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختبار الاتصال والوظائف الجديدة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testConnection,
                          child: Text('اختبار الاتصال'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testDeviceInfo,
                          child: Text('معلومات الجهاز'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testCreateOrganization,
                          child: Text('إنشاء مؤسسة'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testLicenseStatus,
                          child: Text('حالة الترخيص'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testCreateSchool,
                          child: Text('إنشاء مدرسة'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testCreateStudent,
                          child: Text('إنشاء طالب'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testGetStats,
                          child: Text('الإحصائيات'),
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => _output = ''),
                          child: Text('مسح'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نتائج الاختبار',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          _output.isEmpty ? 'لا توجد نتائج بعد...' : _output,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addToOutput(String message) {
    setState(() {
      _output += '$message\n';
    });
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    _addToOutput('📡 اختبار الاتصال مع Supabase...');
    
    try {
      await SupabaseService.initialize();
      if (SupabaseService.isEnabled) {
        _addToOutput('✅ الاتصال ناجح!');
      } else {
        _addToOutput('❌ الاتصال فاشل - Supabase غير مفعل');
      }
    } catch (e) {
      _addToOutput('❌ خطأ في الاتصال: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testDeviceInfo() async {
    setState(() => _isLoading = true);
    _addToOutput('📱 جلب معلومات الجهاز...');
    
    try {
      final deviceInfo = await SupabaseService.getDeviceInfo();
      final fingerprint = await SupabaseService.generateDeviceFingerprint();
      
      _addToOutput('📱 معلومات الجهاز:');
      deviceInfo.forEach((key, value) {
        _addToOutput('  $key: $value');
      });
      _addToOutput('🔑 Device Fingerprint: $fingerprint');
    } catch (e) {
      _addToOutput('❌ خطأ في جلب معلومات الجهاز: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testCreateOrganization() async {
    setState(() => _isLoading = true);
    _addToOutput('🏢 إنشاء مؤسسة تعليمية جديدة...');
    
    try {
      final result = await SupabaseService.createEducationalOrganization(
        name: 'مؤسسة الاختبار التعليمية',
        email: 'test-${DateTime.now().millisecondsSinceEpoch}@test.com',
        phone: '+966501234567',
        address: 'الرياض، المملكة العربية السعودية',
        subscriptionPlan: 'basic',
        maxSchools: 2,
        maxStudents: 200,
      );
      
      if (result != null) {
        _addToOutput('✅ تم إنشاء المؤسسة بنجاح!');
        _addToOutput('📋 معرف المؤسسة: ${result['id']}');
        _addToOutput('📧 البريد الإلكتروني: ${result['email']}');
        _addToOutput('🏢 اسم المؤسسة: ${result['name']}');
      } else {
        _addToOutput('❌ فشل في إنشاء المؤسسة');
      }
    } catch (e) {
      _addToOutput('❌ خطأ في إنشاء المؤسسة: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testLicenseStatus() async {
    setState(() => _isLoading = true);
    _addToOutput('🔍 فحص حالة الترخيص...');
    
    try {
      final result = await SupabaseService.checkLicenseStatus('admin@excellence-edu.com');
      
      if (result != null) {
        _addToOutput('✅ تم العثور على ترخيص!');
        _addToOutput('🏢 اسم المؤسسة: ${result['organization_name']}');
        _addToOutput('📊 حالة الاشتراك: ${result['subscription_status']}');
        _addToOutput('📈 خطة الاشتراك: ${result['subscription_plan']}');
        _addToOutput('🏫 عدد المدارس: ${result['current_schools_count']}/${result['max_schools']}');
        _addToOutput('👥 عدد الطلاب: ${result['current_students_count']}/${result['max_students']}');
        _addToOutput('📱 Device Fingerprint: ${result['device_fingerprint']}');
        _addToOutput('✅ حالة الترخيص: ${result['license_status']}');
      } else {
        _addToOutput('❌ لم يتم العثور على ترخيص لهذا البريد الإلكتروني');
      }
    } catch (e) {
      _addToOutput('❌ خطأ في فحص حالة الترخيص: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testCreateSchool() async {
    setState(() => _isLoading = true);
    _addToOutput('🏫 إنشاء مدرسة جديدة...');
    
    try {
      // نفترض أن المؤسسة رقم 1 موجودة
      final result = await SupabaseService.createSchool(
        organizationId: 1,
        name: 'مدرسة الاختبار الابتدائية',
        schoolType: 'primary',
        gradeLevels: [1, 2, 3, 4, 5, 6],
        email: 'test-school@test.com',
        phone: '+966501234568',
        address: 'الرياض',
        maxStudentsCount: 150,
      );
      
      if (result != null) {
        _addToOutput('✅ تم إنشاء المدرسة بنجاح!');
        _addToOutput('📋 معرف المدرسة: ${result['id']}');
        _addToOutput('🏫 اسم المدرسة: ${result['name']}');
        _addToOutput('📚 نوع المدرسة: ${result['school_type']}');
      } else {
        _addToOutput('❌ فشل في إنشاء المدرسة');
      }
    } catch (e) {
      _addToOutput('❌ خطأ في إنشاء المدرسة: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testCreateStudent() async {
    setState(() => _isLoading = true);
    _addToOutput('👨‍🎓 إنشاء طالب جديد...');
    
    try {
      final result = await SupabaseService.createStudent(
        organizationId: 1,
        schoolId: 1,
        studentId: 'ST-${DateTime.now().millisecondsSinceEpoch}',
        fullName: 'أحمد محمد علي',
        dateOfBirth: DateTime(2010, 5, 15),
        gender: 'ذكر',
        parentName: 'محمد علي',
        parentPhone: '+966501234569',
        parentEmail: 'parent@test.com',
        gradeLevel: 3,
        section: 'أ',
      );
      
      if (result != null) {
        _addToOutput('✅ تم إنشاء الطالب بنجاح!');
        _addToOutput('📋 معرف الطالب: ${result['id']}');
        _addToOutput('👨‍🎓 اسم الطالب: ${result['full_name']}');
        _addToOutput('🎓 الصف: ${result['grade_level']}');
        _addToOutput('📚 الشعبة: ${result['section']}');
      } else {
        _addToOutput('❌ فشل في إنشاء الطالب');
      }
    } catch (e) {
      _addToOutput('❌ خطأ في إنشاء الطالب: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testGetStats() async {
    setState(() => _isLoading = true);
    _addToOutput('📊 جلب إحصائيات المؤسسة...');
    
    try {
      final result = await SupabaseService.getOrganizationStats(1);
      
      if (result != null) {
        _addToOutput('✅ تم جلب الإحصائيات بنجاح!');
        _addToOutput('🏢 اسم المؤسسة: ${result['organization_name']}');
        _addToOutput('🏫 عدد المدارس: ${result['total_schools']}');
        _addToOutput('👥 عدد الطلاب: ${result['total_students']}');
        _addToOutput('👨‍🏫 عدد المستخدمين: ${result['total_users']}');
        _addToOutput('📚 عدد الصفوف: ${result['total_classes']}');
        _addToOutput('💰 إجمالي الإيرادات: ${result['total_revenue']}');
        _addToOutput('✅ المدفوعات المسددة: ${result['paid_payments']}');
        _addToOutput('⏳ المدفوعات المعلقة: ${result['pending_payments']}');
      } else {
        _addToOutput('❌ لم يتم العثور على إحصائيات للمؤسسة');
      }
    } catch (e) {
      _addToOutput('❌ خطأ في جلب الإحصائيات: $e');
    }
    
    setState(() => _isLoading = false);
  }
}
