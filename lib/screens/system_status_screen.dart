import 'package:flutter/material.dart';
import '../services/unified_service.dart';

/// شاشة عرض حالة النظام
class SystemStatusScreen extends StatefulWidget {
  @override
  _SystemStatusScreenState createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends State<SystemStatusScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _systemStatus;
  Map<String, dynamic>? _diagnosticResults;

  @override
  void initState() {
    super.initState();
    _loadSystemStatus();
  }

  Future<void> _loadSystemStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await UnifiedService.getServicesStatus();
      final summary = await UnifiedService.getSystemSummary();
      
      setState(() {
        _systemStatus = {
          'services': status,
          'summary': summary,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _systemStatus = {
          'error': 'فشل في تحميل حالة النظام: $e',
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await UnifiedService.performSystemDiagnostic();
      setState(() {
        _diagnosticResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _diagnosticResults = {
          'error': 'فشل في تشخيص النظام: $e',
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة النظام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSystemStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStatusContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _runDiagnostic,
        child: const Icon(Icons.medical_services),
        tooltip: 'تشخيص شامل للنظام',
      ),
    );
  }

  Widget _buildStatusContent() {
    if (_systemStatus == null) {
      return const Center(
        child: Text('لا توجد بيانات متاحة'),
      );
    }

    if (_systemStatus!.containsKey('error')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _systemStatus!['error'],
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSystemStatus,
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
          _buildSystemSummaryCard(),
          const SizedBox(height: 16),
          _buildServicesStatusCard(),
          const SizedBox(height: 16),
          if (_diagnosticResults != null) _buildDiagnosticResultsCard(),
        ],
      ),
    );
  }

  Widget _buildSystemSummaryCard() {
    final summary = _systemStatus!['summary'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'ملخص النظام',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('الحالة العامة', summary['system_health'] ?? 'غير معروف'),
            _buildInfoRow('حالة قاعدة البيانات', summary['database_status'] ?? 'غير معروف'),
            _buildInfoRow('حالة الشبكة', summary['network_status'] ?? 'غير معروف'),
            _buildInfoRow('نوع الجهاز', summary['device_type'] ?? 'غير معروف'),
            _buildInfoRow('وضع العمل', summary['working_mode'] ?? 'غير معروف'),
            _buildInfoRow('نوع الاشتراك', summary['subscription_plan'] ?? 'غير معروف'),
            if (summary['days_remaining'] != null && summary['days_remaining'] > 0)
              _buildInfoRow('الأيام المتبقية', '${summary['days_remaining']} يوم'),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesStatusCard() {
    final services = _systemStatus!['services']['services'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'حالة الخدمات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            ...services.entries.map((entry) => _buildServiceStatusRow(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusRow(String serviceName, dynamic serviceData) {
    String displayName = '';
    bool isAvailable = false;
    String status = 'غير معروف';
    Color statusColor = Colors.grey;

    switch (serviceName) {
      case 'database':
        displayName = 'قاعدة البيانات';
        isAvailable = serviceData['is_enabled'] ?? false;
        status = isAvailable ? 'متصل' : 'غير متصل';
        statusColor = isAvailable ? Colors.green : Colors.red;
        break;
      case 'network':
        displayName = 'الشبكة';
        isAvailable = serviceData['is_connected'] ?? false;
        status = isAvailable ? 'متصل' : 'غير متصل';
        statusColor = isAvailable ? Colors.green : Colors.orange;
        break;
      case 'device':
        displayName = 'الجهاز';
        isAvailable = serviceData['available'] ?? false;
        status = isAvailable ? 'متاح' : 'غير متاح';
        statusColor = isAvailable ? Colors.green : Colors.red;
        break;
      case 'organization':
        displayName = 'المؤسسة';
        isAvailable = serviceData['available'] ?? false;
        status = isAvailable ? 'مسجلة' : 'غير مسجلة';
        statusColor = isAvailable ? Colors.green : Colors.orange;
        break;
      case 'subscription':
        displayName = 'الاشتراك';
        isAvailable = serviceData['available'] ?? false;
        status = isAvailable ? 'نشط' : 'غير نشط';
        statusColor = isAvailable ? Colors.green : Colors.orange;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(displayName, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'نتائج التشخيص',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            
            if (_diagnosticResults!.containsKey('error')) ...[
              Text(
                'خطأ في التشخيص: ${_diagnosticResults!['error']}',
                style: const TextStyle(color: Colors.red),
              ),
            ] else ...[
              _buildInfoRow('مستوى الصحة', _diagnosticResults!['health_level'] ?? 'غير معروف'),
              _buildInfoRow('وقت التشخيص', _formatTimestamp(_diagnosticResults!['timestamp'])),
              
              if (_diagnosticResults!['critical_issues']?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                const Text(
                  'مشاكل حرجة:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                ...(_diagnosticResults!['critical_issues'] as List).map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $issue', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ],
              
              if (_diagnosticResults!['warnings']?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                const Text(
                  'تحذيرات:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                ...(_diagnosticResults!['warnings'] as List).map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $warning', style: const TextStyle(color: Colors.orange)),
                  ),
                ),
              ],
              
              if (_diagnosticResults!['recommendations']?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                const Text(
                  'التوصيات:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                ...(_diagnosticResults!['recommendations'] as List).map(
                  (recommendation) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $recommendation', style: const TextStyle(color: Colors.blue)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'غير معروف';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'غير صحيح';
    }
  }
}
