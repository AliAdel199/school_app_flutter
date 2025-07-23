import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/reports_sync_service.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  bool isLoading = true;
  Map<String, dynamic>? subscriptionsInfo;
  SubscriptionStatus? reportsStatus;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionInfo();
  }

  Future<void> _loadSubscriptionInfo() async {
    setState(() => isLoading = true);
    
    try {
      final info = await SubscriptionService.getSubscriptionsInfo();
      final status = await SubscriptionService.getReportsSyncStatus();
      
      setState(() {
        subscriptionsInfo = info;
        reportsStatus = status;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('خطأ في تحميل معلومات الاشتراك: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الاشتراكات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildSubscriptionContent(),
    );
  }

  Widget _buildSubscriptionContent() {
    if (subscriptionsInfo?['error'] != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              subscriptionsInfo!['error'],
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubscriptionInfo,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSchoolInfo(),
          const SizedBox(height: 24),
          _buildBasicFeaturesCard(),
          const SizedBox(height: 16),
          _buildReportsSyncCard(),
          const SizedBox(height: 16),
          _buildSyncStatusCard(),
        ],
      ),
    );
  }

  Widget _buildSchoolInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات المدرسة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('اسم المدرسة: ${subscriptionsInfo?['school_name'] ?? 'غير محدد'}'),
            Text('معرف المؤسسة: ${subscriptionsInfo?['organization_id'] ?? 'غير مرتبط'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicFeaturesCard() {
    final basicFeatures = subscriptionsInfo?['basic_features'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'الميزات الأساسية (مجانية)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (basicFeatures?['included'] != null)
              ...List<String>.from(basicFeatures['included']).map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsSyncCard() {
    final reportsSync = subscriptionsInfo?['reports_sync'];
    final isActive = reportsStatus?.isActive ?? false;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.cloud_sync : Icons.cloud_off,
                  color: isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'مزامنة التقارير السحابية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (isActive) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text('الاشتراك نشط', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (reportsStatus?.expiryDate != null)
                      Text('تاريخ الانتهاء: ${_formatDate(reportsStatus!.expiryDate!)}'),
                    if (reportsStatus?.daysRemaining != null)
                      Text('الأيام المتبقية: ${reportsStatus!.daysRemaining} يوم'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _syncReports,
                      icon: Icon(Icons.sync),
                      label: const Text('مزامنة الآن'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _renewSubscription,
                      child: const Text('تجديد'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _cancelSubscription,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('إلغاء الاشتراك'),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        const Text('اشتراك غير نشط', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(reportsStatus?.message ?? 'مزامنة التقارير غير مفعلة'),
                    const SizedBox(height: 8),
                    Text('السعر: ${reportsSync?['price_per_month'] ?? 50} ريال شهرياً'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _activateReportsSync,
                  icon: Icon(Icons.cloud_upload),
                  label: const Text('تفعيل مزامنة التقارير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'ميزات مزامنة التقارير:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...[
              'نسخ احتياطي سحابي للتقارير',
              'الوصول للتقارير من أي جهاز',
              'تقارير مقارنة بين الفروع',
              'تحليلات متقدمة ورسوم بيانية',
              'تصدير التقارير بصيغ متعددة',
            ].map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة المزامنة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: ReportsSyncService.getSyncStatusReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final status = snapshot.data ?? {};
                final canSync = status['can_sync'] ?? false;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow('اشتراك مزامنة التقارير', 
                        status['subscription_active'] ?? false),
                    _buildStatusRow('الاتصال بالسحابة', 
                        status['cloud_connected'] ?? false),
                    _buildStatusRow('إمكانية المزامنة', canSync),
                    
                    if (status['last_sync'] != null) ...[
                      const SizedBox(height: 8),
                      Text('آخر مزامنة: ${_formatDateTime(DateTime.parse(status['last_sync']))}',
                           style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                    
                    if (status['error'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(status['error'], 
                                   style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _activateReportsSync() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفعيل مزامنة التقارير'),
        content: const Text(
          'سيتم تفعيل اشتراك مزامنة التقارير لمدة شهر بمبلغ 50 ريال.\n\n'
          'هل تريد المتابعة؟'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => isLoading = true);
      
      try {
        final activationResult = await SubscriptionService.activateReportsSync(
          paymentMethod: 'manual', // يمكن تطوير نظام دفع متكامل لاحقاً
          transactionId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
          paymentDetails: {'method': 'manual_activation'},
        );

        if (activationResult.success) {
          _showSnackBar(activationResult.message, Colors.green);
          await _loadSubscriptionInfo();
        } else {
          _showSnackBar(activationResult.message, Colors.red);
        }
      } catch (e) {
        _showSnackBar('خطأ في تفعيل الاشتراك: $e', Colors.red);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _syncReports() async {
    setState(() => isLoading = true);
    
    try {
      final result = await ReportsSyncService.syncReportsWithSupabase();
      
      if (result.success) {
        _showSnackBar('تم مزامنة التقارير بنجاح', Colors.green);
      } else {
        _showSnackBar(result.message, 
            result.requiresSubscription ? Colors.orange : Colors.red);
      }
      
      await _loadSubscriptionInfo();
    } catch (e) {
      _showSnackBar('خطأ في مزامنة التقارير: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _renewSubscription() async {
    await _activateReportsSync(); // نفس عملية التفعيل
  }

  Future<void> _cancelSubscription() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الاشتراك'),
        content: const Text(
          'هل أنت متأكد من إلغاء اشتراك مزامنة التقارير؟\n\n'
          'ستفقد إمكانية الوصول للميزات السحابية.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إلغاء الاشتراك'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => isLoading = true);
      
      try {
        final success = await SubscriptionService.cancelReportsSync();
        
        if (success) {
          _showSnackBar('تم إلغاء الاشتراك بنجاح', Colors.green);
          await _loadSubscriptionInfo();
        } else {
          _showSnackBar('فشل في إلغاء الاشتراك', Colors.red);
        }
      } catch (e) {
        _showSnackBar('خطأ في إلغاء الاشتراك: $e', Colors.red);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
