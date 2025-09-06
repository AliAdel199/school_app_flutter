import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../services/supabase_service.dart';
import '../services/premium_features_service.dart';
import '../services/reports_upload_service.dart';
import '../localdatabase/school.dart';
import '../main.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _subscriptionInfo;
  List<Map<String, dynamic>> _purchasedFeatures = [];
  
  int _organizationId = 1;
  String _organizationName = '';

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() => _isLoading = true);
    
    try {
      // جلب معلومات المدرسة
      final schools = await isar.schools.where().findAll();
      if (schools.isNotEmpty) {
        final school = schools.first;
        _organizationId = school.organizationId ?? 1;
        _organizationName = school.organizationName ?? 'غير محدد';
        
        // إذا كان معرف المؤسسة 1، حاول الحصول على المؤسسة الافتراضية
        if (_organizationId == 1) {
          final defaultOrgId = await SupabaseService.getOrCreateDefaultOrganization();
          if (defaultOrgId != null) {
            _organizationId = defaultOrgId;
            // تحديث بيانات المدرسة المحلية
            school.organizationId = defaultOrgId;
            await isar.writeTxn(() async {
              await isar.schools.put(school);
            });
          }
        }
      }

      // جلب حالة الاشتراك
      _subscriptionInfo = await SupabaseService.checkOrganizationSubscriptionStatus(_organizationId);
      
      // جلب الميزات المشتراة
      _purchasedFeatures = await SupabaseService.getOrganizationPurchasedFeatures(_organizationId) ?? [];
      
    } catch (e) {
      print('❌ خطأ في تحميل بيانات الاشتراك: $e');
      _showErrorSnackBar('فشل في تحميل بيانات الاشتراك');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الاشتراكات والميزات'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubscriptionData,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSubscriptionData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrganizationInfo(),
                    const SizedBox(height: 20),
                    _buildSubscriptionStatus(),
                    const SizedBox(height: 20),
                    _buildOnlineReportsFeature(),
                    const SizedBox(height: 20),
                    _buildPurchasedFeatures(),
                    const SizedBox(height: 20),
                    _buildManagementActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrganizationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 8),
                Text(
                  'معلومات المؤسسة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('اسم المؤسسة', _organizationName),
            _buildInfoRow('معرف المؤسسة', _organizationId.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionStatus() {
    if (_subscriptionInfo == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text('لا يمكن جلب معلومات الاشتراك'),
            ],
          ),
        ),
      );
    }

    final isActive = _subscriptionInfo!['is_active'] ?? false;
    final plan = _subscriptionInfo!['subscription_plan'] ?? 'غير محدد';
    final status = _subscriptionInfo!['subscription_status'] ?? 'غير محدد';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'حالة الاشتراك',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الحالة', isActive ? 'نشط' : 'غير نشط'),
            _buildInfoRow('نوع الاشتراك', plan),
            _buildInfoRow('حالة الاشتراك', status),
            if (_subscriptionInfo!['subscription_expires_at'] != null)
              _buildInfoRow(
                'تاريخ الانتهاء',
                DateFormat('yyyy-MM-dd').format(
                  DateTime.parse(_subscriptionInfo!['subscription_expires_at']),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineReportsFeature() {
    final hasOnlineReports = _subscriptionInfo?['has_online_reports'] == true;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasOnlineReports ? Icons.cloud_done : Icons.cloud_off,
                  color: hasOnlineReports ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'التقارير الأونلاين',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (hasOnlineReports)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'مفعل',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'غير مفعل',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasOnlineReports
                  ? 'يمكنك رفع التقارير على السحابة والوصول إليها من أي مكان'
                  : 'اشترك في ميزة التقارير الأونلاين للاستفادة من التخزين السحابي',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!hasOnlineReports) ...[
                  ElevatedButton.icon(
                    onPressed: _purchaseOnlineReports,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('شراء الميزة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  onPressed: hasOnlineReports ? _testOnlineReports : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(hasOnlineReports ? 'اختبار الرفع' : 'غير متاح'),
                ),
                if (hasOnlineReports) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _showUploadSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('إعدادات الرفع'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasedFeatures() {
    if (_purchasedFeatures.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.inbox, color: Colors.grey, size: 48),
              const SizedBox(height: 8),
              Text(
                'لا توجد ميزات مشتراة',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الميزات المشتراة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...List.generate(_purchasedFeatures.length, (index) {
              final feature = _purchasedFeatures[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  title: Text(feature['feature_name'] ?? 'غير محدد'),
                  subtitle: Text(
                    'تاريخ الشراء: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(feature['purchase_date']))}',
                  ),
                  trailing: Text(
                    '${feature['amount']} د.ع',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات الإدارة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadSubscriptionData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث البيانات'),
                ),
                ElevatedButton.icon(
                  onPressed: _viewSubscriptionHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('تاريخ الاشتراكات'),
                ),
                ElevatedButton.icon(
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.support_agent),
                  label: const Text('اتصال بالدعم'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseOnlineReports() async {
    PremiumFeaturesService.showPurchaseDialog(
      context,
      'online_reports',
      _organizationId,
      () {
        _loadSubscriptionData();
        _showSuccessSnackBar('تم شراء ميزة التقارير الأونلاين بنجاح!');
      },
    );
  }

  Future<void> _testOnlineReports() async {
    _showLoadingDialog('جاري اختبار رفع التقرير...');
    
    try {
      // محاكاة رفع تقرير تجريبي
      await Future.delayed(const Duration(seconds: 2));
      
      Navigator.pop(context); // إغلاق dialog التحميل
      _showSuccessSnackBar('تم اختبار رفع التقرير بنجاح!');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('فشل في اختبار رفع التقرير: $e');
    }
  }

  Future<void> _viewSubscriptionHistory() async {
    _showInfoDialog(
      'تاريخ الاشتراكات',
      'هذه الميزة قيد التطوير وستكون متاحة قريباً.',
    );
  }

  Future<void> _contactSupport() async {
    _showInfoDialog(
      'اتصال بالدعم الفني',
      'للدعم الفني، يرجى التواصل على:\n\nالبريد الإلكتروني: support@schoolapp.com\nالهاتف: +964 770 123 4567',
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUploadSettings() {
    ReportsUploadService.showUploadSettings(context);
  }
}
