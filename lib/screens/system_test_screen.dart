import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../helpers/network_helper.dart';

class SystemTestScreen extends StatefulWidget {
  const SystemTestScreen({Key? key}) : super(key: key);

  @override
  State<SystemTestScreen> createState() => _SystemTestScreenState();
}

class _SystemTestScreenState extends State<SystemTestScreen> {
  final List<TestResult> _testResults = [];
  bool _isRunning = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 اختبار النظام الشامل'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // أزرار الاختبار
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runCompleteSystemTest,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('تشغيل اختبار شامل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _clearResults,
                    icon: const Icon(Icons.clear),
                    label: const Text('مسح النتائج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // قائمة الاختبارات المتاحة
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTestButton('🌐 اختبار الشبكة', _testNetwork),
                _buildTestButton('🔗 اختبار Supabase', _testSupabase),
                _buildTestButton('🏢 اختبار إنشاء مؤسسة', _testCreateOrganization),
                _buildTestButton('🏫 اختبار إنشاء مدرسة', _testCreateSchool),
                _buildTestButton('👤 اختبار إنشاء مستخدم', _testCreateUser),
                _buildTestButton('📊 اختبار الإحصائيات', _testStats),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // نتائج الاختبار
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.assignment),
                          const SizedBox(width: 8),
                          const Text('نتائج الاختبار', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          if (_isRunning) 
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _testResults.length,
                        itemBuilder: (context, index) {
                          final result = _testResults[index];
                          return _buildTestResultItem(result);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isRunning ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(title, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildTestResultItem(TestResult result) {
    Color statusColor;
    IconData statusIcon;
    
    switch (result.status) {
      case TestStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TestStatus.failure:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case TestStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case TestStatus.running:
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_empty;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.testName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                '${result.duration}ms',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (result.message.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              result.message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
          if (result.details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result.details,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // تشغيل اختبار شامل
  Future<void> _runCompleteSystemTest() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addTestResult('🚀 بدء الاختبار الشامل', 'بدء سلسلة الاختبارات...', TestStatus.running);

    // تشغيل جميع الاختبارات بالتسلسل
    await _testNetwork();
    await _testSupabase();
    await _testCreateOrganization();
    await _testCreateSchool();
    await _testCreateUser();
    await _testStats();

    // حساب الإحصائيات
    int successCount = _testResults.where((r) => r.status == TestStatus.success).length;
    int failureCount = _testResults.where((r) => r.status == TestStatus.failure).length;
    int warningCount = _testResults.where((r) => r.status == TestStatus.warning).length;
    
    _addTestResult(
      '🎉 انتهاء الاختبار الشامل', 
      'مكتمل: $successCount نجح، $failureCount فشل، $warningCount تحذير', 
      failureCount == 0 ? TestStatus.success : TestStatus.warning
    );

    setState(() {
      _isRunning = false;
    });

    // التمرير للنهاية
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // اختبار الشبكة
  Future<void> _testNetwork() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _addTestResult('🌐 اختبار الشبكة', 'فحص اتصال الإنترنت...', TestStatus.running);
      
      final networkStatus = await NetworkHelper.checkNetworkStatus();
      stopwatch.stop();
      
      if (networkStatus['is_connected'] == true) {
        _updateLastTestResult(
          'اختبار الشبكة',
          'الاتصال متاح ✅',
          TestStatus.success,
          stopwatch.elapsedMilliseconds,
          'تفاصيل: ${networkStatus['message']}\nيمكن الوصول لـ Supabase: ${networkStatus['can_reach_supabase']}',
        );
      } else {
        _updateLastTestResult(
          'اختبار الشبكة',
          'لا يوجد اتصال بالإنترنت ❌',
          TestStatus.failure,
          stopwatch.elapsedMilliseconds,
          'تفاصيل: ${networkStatus['message']}',
        );
      }
    } catch (e) {
      stopwatch.stop();
      _updateLastTestResult(
        'اختبار الشبكة',
        'خطأ في فحص الشبكة ❌',
        TestStatus.failure,
        stopwatch.elapsedMilliseconds,
        'خطأ: $e',
      );
    }
  }

  // اختبار Supabase
  Future<void> _testSupabase() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _addTestResult('🔗 اختبار Supabase', 'فحص الاتصال مع قاعدة البيانات...', TestStatus.running);
      
      // أولاً، التحقق من تفعيل الخدمة
      if (!SupabaseService.isEnabled) {
        _updateLastTestResult(
          'اختبار Supabase',
          'خدمة Supabase غير مفعلة ⚠️',
          TestStatus.warning,
          stopwatch.elapsedMilliseconds,
          'تحقق من إعدادات SupabaseService في الكود',
        );
        return;
      }
      
      // اختبار الاتصال البسيط
      final response = await SupabaseService.client
          .from('educational_organizations')
          .select('id, name')
          .limit(1);
      
      stopwatch.stop();
      
      _updateLastTestResult(
        'اختبار Supabase',
        'الاتصال مع قاعدة البيانات يعمل ✅',
        TestStatus.success,
        stopwatch.elapsedMilliseconds,
        'استجابة: تم جلب ${response.length} سجل\nURL: ${SupabaseService.supabaseUrl}',
      );
    } catch (e) {
      stopwatch.stop();
      _updateLastTestResult(
        'اختبار Supabase',
        'فشل الاتصال مع قاعدة البيانات ❌',
        TestStatus.failure,
        stopwatch.elapsedMilliseconds,
        'خطأ: $e\n\nتحقق من:\n- صحة URL و AnonKey\n- اتصال الإنترنت\n- إعدادات RLS في Supabase',
      );
    }
  }

  // اختبار إنشاء مؤسسة
  Future<void> _testCreateOrganization() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _addTestResult('🏢 اختبار إنشاء مؤسسة', 'إنشاء مؤسسة تجريبية...', TestStatus.running);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final result = await SupabaseService.createEducationalOrganization(
        name: 'مؤسسة تجريبية $timestamp',
        email: 'test$timestamp@gmail.com',
        phone: '07712345678',
        address: 'عنوان تجريبي',
        subscriptionPlan: 'basic',
        subscriptionStatus: 'trial',
        maxSchools: 1,
        maxStudents: 100,
      );
      
      stopwatch.stop();
      
      if (result != null && result.isNotEmpty) {
        _updateLastTestResult(
          'اختبار إنشاء مؤسسة',
          'تم إنشاء المؤسسة بنجاح ✅',
          TestStatus.success,
          stopwatch.elapsedMilliseconds,
          'ID: ${result['id']}\nاسم: ${result['name']}\nبريد: ${result['email']}\nحالة الاشتراك: ${result['subscription_status']}',
        );
      } else {
        _updateLastTestResult(
          'اختبار إنشاء مؤسسة',
          'فشل في إنشاء المؤسسة ❌',
          TestStatus.failure,
          stopwatch.elapsedMilliseconds,
          'لم يتم إرجاع نتيجة من الخادم - تحقق من:\n- اتصال الإنترنت\n- إعدادات Supabase\n- صحة البيانات المرسلة',
        );
      }
    } catch (e) {
      stopwatch.stop();
      _updateLastTestResult(
        'اختبار إنشاء مؤسسة',
        'خطأ في إنشاء المؤسسة ❌',
        TestStatus.failure,
        stopwatch.elapsedMilliseconds,
        'خطأ: $e\n\nاحتمالات الخطأ:\n- مشكلة في الشبكة\n- مشكلة في قاعدة البيانات\n- بيانات مكررة (البريد الإلكتروني)',
      );
    }
  }

  // اختبار إنشاء مدرسة
  Future<void> _testCreateSchool() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _addTestResult('🏫 اختبار إنشاء مدرسة', 'إنشاء مدرسة تجريبية...', TestStatus.running);
      
      // أولاً نحتاج لإنشاء مؤسسة
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final org = await SupabaseService.createEducationalOrganization(
        name: 'مؤسسة للمدرسة $timestamp',
        email: 'org$timestamp@example.com',
      );
      
      if (org == null) {
        throw Exception('فشل في إنشاء المؤسسة المطلوبة للمدرسة');
      }
      
      final result = await SupabaseService.createSchool(
        organizationId: org['id'],
        name: 'مدرسة تجريبية $timestamp',
        schoolType: 'مختلطة',
        gradeLevels: [1, 2, 3, 4, 5, 6],
        email: 'school$timestamp@example.com',
        phone: '07712345679',
        address: 'عنوان المدرسة التجريبية',
        maxStudentsCount: 100,
        establishedYear: 2025,
      );
      
      stopwatch.stop();
      
      if (result != null) {
        _updateLastTestResult(
          'اختبار إنشاء مدرسة',
          'تم إنشاء المدرسة بنجاح ✅',
          TestStatus.success,
          stopwatch.elapsedMilliseconds,
          'ID: ${result['id']}\nاسم: ${result['name']}\nنوع: ${result['school_type']}\nمؤسسة: ${org['id']}',
        );
      } else {
        _updateLastTestResult(
          'اختبار إنشاء مدرسة',
          'فشل في إنشاء المدرسة ❌',
          TestStatus.failure,
          stopwatch.elapsedMilliseconds,
          'لم يتم إرجاع نتيجة من الخادم',
        );
      }
    } catch (e) {
      stopwatch.stop();
      _updateLastTestResult(
        'اختبار إنشاء مدرسة',
        'خطأ في إنشاء المدرسة ❌',
        TestStatus.failure,
        stopwatch.elapsedMilliseconds,
        'خطأ: $e',
      );
    }
  }

  // اختبار إنشاء مستخدم
  Future<void> _testCreateUser() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _addTestResult('👤 اختبار إنشاء مستخدم', 'إنشاء مستخدم تجريبي...', TestStatus.running);
      
      // إنشاء مؤسسة ومدرسة مطلوبة
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final org = await SupabaseService.createEducationalOrganization(
        name: 'مؤسسة للمستخدم $timestamp',
        email: 'orguser$timestamp@example.com',
      );
      
      if (org == null) {
        throw Exception('فشل في إنشاء المؤسسة المطلوبة');
      }
      
      final school = await SupabaseService.createSchool(
        organizationId: org['id'],
        name: 'مدرسة للمستخدم $timestamp',
        schoolType: 'مختلطة',
      );
      
      if (school == null) {
        throw Exception('فشل في إنشاء المدرسة المطلوبة');
      }
      
      final result = await SupabaseService.createUser(
        organizationId: org['id'],
        schoolId: school['id'],
        fullName: 'مستخدم تجريبي $timestamp',
        email: 'user$timestamp@example.com',
        password: 'test123456',
        phone: '01234567892',
        role: 'teacher',
        permissions: {
          'can_view_students': true,
          'can_edit_grades': true,
        },
      );
      
      stopwatch.stop();
      
      if (result != null) {
        _updateLastTestResult(
          'اختبار إنشاء مستخدم',
          'تم إنشاء المستخدم بنجاح ✅',
          TestStatus.success,
          stopwatch.elapsedMilliseconds,
          'ID: ${result['id']}\nاسم: ${result['full_name']}\nبريد: ${result['email']}\nدور: ${result['role']}',
        );
      } else {
        _updateLastTestResult(
          'اختبار إنشاء مستخدم',
          'فشل في إنشاء المستخدم ❌',
          TestStatus.failure,
          stopwatch.elapsedMilliseconds,
          'لم يتم إرجاع نتيجة من الخادم',
        );
      }
    } catch (e) {
      stopwatch.stop();
      _updateLastTestResult(
        'اختبار إنشاء مستخدم',
        'خطأ في إنشاء المستخدم ❌',
        TestStatus.failure,
        stopwatch.elapsedMilliseconds,
        'خطأ: $e',
      );
    }
  }

  // اختبار الإحصائيات
  Future<void> _testStats() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _addTestResult('📊 اختبار الإحصائيات', 'جلب الإحصائيات...', TestStatus.running);
      
      // اختبار التحقق من حالة الاشتراك (يحتاج organization_id)
      final orgs = await SupabaseService.client
          .from('educational_organizations')
          .select('id')
          .limit(1);
      
      if (orgs.isEmpty) {
        throw Exception('لا توجد مؤسسات في قاعدة البيانات للاختبار');
      }
      
      final orgId = orgs.first['id'];
      final subscriptionStatus = await SupabaseService.checkOrganizationSubscriptionStatus(orgId);
      
      stopwatch.stop();
      
      _updateLastTestResult(
        'اختبار الإحصائيات',
        'تم جلب الإحصائيات بنجاح ✅',
        TestStatus.success,
        stopwatch.elapsedMilliseconds,
        'حالة الاشتراك للمؤسسة $orgId: ${subscriptionStatus != null ? "نشط" : "غير نشط"}',
      );
    } catch (e) {
      stopwatch.stop();
      _updateLastTestResult(
        'اختبار الإحصائيات',
        'خطأ في جلب الإحصائيات ❌',
        TestStatus.failure,
        stopwatch.elapsedMilliseconds,
        'خطأ: $e',
      );
    }
  }

  void _addTestResult(String testName, String message, TestStatus status) {
    setState(() {
      _testResults.add(TestResult(
        testName: testName,
        message: message,
        status: status,
        duration: 0,
        details: '',
      ));
    });
    
    // التمرير للنهاية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateLastTestResult(String testName, String message, TestStatus status, int duration, String details) {
    setState(() {
      if (_testResults.isNotEmpty) {
        final lastIndex = _testResults.length - 1;
        _testResults[lastIndex] = TestResult(
          testName: testName,
          message: message,
          status: status,
          duration: duration,
          details: details,
        );
      }
    });
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }
}

class TestResult {
  final String testName;
  final String message;
  final TestStatus status;
  final int duration;
  final String details;

  TestResult({
    required this.testName,
    required this.message,
    required this.status,
    required this.duration,
    required this.details,
  });
}

enum TestStatus {
  success,
  failure,
  warning,
  running,
}
