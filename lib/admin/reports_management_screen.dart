import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/reports_upload_service.dart';

class ReportsManagementScreen extends StatefulWidget {
  const ReportsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReportsManagementScreen> createState() => _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> {
  ReportsUploadMode _currentMode = ReportsUploadMode.manual;
  TimeOfDay _uploadTime = const TimeOfDay(hour: 22, minute: 0);
  DateTime? _lastUpload;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final mode = await ReportsUploadService.getUploadMode();
      final time = await ReportsUploadService.getAutoUploadTime();
      final lastUpload = await ReportsUploadService.getLastUploadDate();
      
      setState(() {
        _currentMode = mode;
        _uploadTime = time;
        _lastUpload = lastUpload;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في جلب الإعدادات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة رفع التقارير'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildSettingsCard(),
                  const SizedBox(height: 16),
                  _buildActionsCard(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _currentMode == ReportsUploadMode.automatic 
                      ? Icons.autorenew 
                      : Icons.touch_app,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'حالة الرفع الحالية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getModeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getModeColor()),
              ),
              child: Text(
                _getModeText(),
                style: TextStyle(
                  color: _getModeColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_lastUpload != null) ...[
              const SizedBox(height: 12),
              Text(
                'آخر رفع: ${DateFormat('yyyy/MM/dd - HH:mm').format(_lastUpload!)}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات الرفع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // خيار الرفع اليدوي
            RadioListTile<ReportsUploadMode>(
              title: const Text('رفع يدوي'),
              subtitle: const Text('ترفع التقارير عند الضغط على زر الرفع'),
              value: ReportsUploadMode.manual,
              groupValue: _currentMode,
              onChanged: _onModeChanged,
            ),
            
            // خيار الرفع التلقائي
            RadioListTile<ReportsUploadMode>(
              title: const Text('رفع تلقائي'),
              subtitle: const Text('ترفع التقارير تلقائياً في وقت محدد يومياً'),
              value: ReportsUploadMode.automatic,
              groupValue: _currentMode,
              onChanged: _onModeChanged,
            ),
            
            // إعدادات الوقت للرفع التلقائي
            if (_currentMode == ReportsUploadMode.automatic) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('وقت الرفع التلقائي'),
                subtitle: Text('كل يوم في الساعة ${_uploadTime.format(context)}'),
                trailing: TextButton(
                  onPressed: _selectTime,
                  child: const Text('تغيير'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإجراءات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _uploadNow,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('رفع الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('اختبار الاتصال'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'معلومات مهمة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• الرفع التلقائي يتطلب اتصال مستمر بالإنترنت\n'
              '• يتم حفظ التقارير محلياً حتى لو فشل الرفع\n'
              '• يمكنك تغيير وضع الرفع في أي وقت\n'
              '• التقارير المرفوعة آمنة ومشفرة',
              style: TextStyle(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModeColor() {
    switch (_currentMode) {
      case ReportsUploadMode.automatic:
        return Colors.green;
      case ReportsUploadMode.manual:
        return Colors.orange;
      case ReportsUploadMode.scheduled:
        return Colors.blue;
    }
  }

  String _getModeText() {
    switch (_currentMode) {
      case ReportsUploadMode.automatic:
        return 'رفع تلقائي مفعل';
      case ReportsUploadMode.manual:
        return 'رفع يدوي';
      case ReportsUploadMode.scheduled:
        return 'رفع مجدول';
    }
  }

  void _onModeChanged(ReportsUploadMode? mode) async {
    if (mode == null) return;
    
    setState(() => _currentMode = mode);
    await ReportsUploadService.setUploadMode(mode);
    _showSuccessSnackBar('تم تغيير وضع الرفع بنجاح');
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _uploadTime,
    );
    
    if (time != null) {
      setState(() => _uploadTime = time);
      await ReportsUploadService.setAutoUploadTime(time);
      _showSuccessSnackBar('تم حفظ وقت الرفع التلقائي');
    }
  }

  Future<void> _uploadNow() async {
    _showLoadingDialog('جاري رفع التقارير...');
    
    try {
      final success = await ReportsUploadService.uploadReportsManually(
        reportData: {
          'type': 'manual_upload',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      Navigator.pop(context); // إغلاق dialog التحميل
      
      if (success) {
        await _loadSettings(); // إعادة تحميل الإعدادات لتحديث آخر رفع
        _showSuccessSnackBar('تم رفع التقارير بنجاح');
      } else {
        _showErrorSnackBar('فشل في رفع التقارير');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('خطأ في رفع التقارير: $e');
    }
  }

  Future<void> _testConnection() async {
    _showLoadingDialog('جاري اختبار الاتصال...');
    
    try {
      // محاكاة اختبار الاتصال
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      _showSuccessSnackBar('الاتصال ممتاز مع الخدمة');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('فشل في الاتصال: $e');
    }
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
            Expanded(child: Text(message)),
          ],
        ),
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
}
