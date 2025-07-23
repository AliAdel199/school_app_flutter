import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'device_info_service.dart';
import 'license_manager.dart';
import 'schoolregstristion.dart';
import 'services/subscription_service.dart';
import 'services/subscription_notifications_service.dart';
import 'dialogs/subscription_activation_dialog.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final codeController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  String fingerprint = '';
  bool showSubscriptionOptions = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceFingerprint();
    _checkSubscriptionFeatures();
  }

  Future<void> _loadDeviceFingerprint() async {
    final fp = await DeviceInfoService.getDeviceFingerprint();
    setState(() => fingerprint = fp);
  }

  Future<void> _checkSubscriptionFeatures() async {
    // فحص إذا كان النظام يدعم ميزات الاشتراك
    await SubscriptionService.getReportsSyncStatus();
    setState(() {
      showSubscriptionOptions = true;
    });
  }

  Future<void> handleActivation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = await LicenseManager.activateWithCode(codeController.text.trim());

    if (success) {
      // إرسال إشعار نجاح التفعيل
      await SubscriptionNotificationsService.sendActivationSuccessNotification();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InitialSetupScreen()),
        );
      }
    } else {
      setState(() {
        errorMessage = 'رمز التفعيل غير صالح أو لا يطابق هذا الجهاز';
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> _showSubscriptionDialog() async {
    final result = await SubscriptionActivationDialog.show(context);
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('تم تفعيل اشتراك مزامنة التقارير بنجاح!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> copyFingerprint() async {
    final fp = await DeviceInfoService.getDeviceFingerprint();
    setState(() => fingerprint = fp);
    await Clipboard.setData(ClipboardData(text: fp));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 تم نسخ البصمة بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text(
                'تفعيل النظام',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                onPressed: copyFingerprint,
                icon: const Icon(Icons.copy),
                tooltip: 'نسخ بصمة الجهاز',
              ),
            ],
          ),
          backgroundColor: Colors.grey[50],
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.warning_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'انتهت الفترة التجريبية',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'الرجاء إدخال رمز التفعيل لمتابعة استخدام النظام والاستفادة من جميع المميزات.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: codeController,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            labelText: 'رمز التفعيل',
                            hintText: 'أدخل رمز التفعيل هنا',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            prefixIcon: Icon(Icons.vpn_key, color: Colors.blue),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(color: Colors.red[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        isLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: handleActivation,
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text('تفعيل النظام الأساسي'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  if (showSubscriptionOptions) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'ميزات إضافية اختيارية',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.green.shade50, Colors.green.shade100],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.cloud_sync, color: Colors.white, size: 20),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'مزامنة التقارير السحابية',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green[800],
                                                      ),
                                                    ),
                                                    Text(
                                                      'نسخ احتياطي آمن للتقارير في السحابة',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: _showSubscriptionDialog,
                                            icon: const Icon(Icons.add_shopping_cart),
                                            label: const Text('اشتراك اختياري - 15,000 د.ع شهرياً'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              minimumSize: Size(double.infinity, 45),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.local_offer, color: Colors.orange, size: 16),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'عروض وخصومات متاحة! خصم يصل إلى 50%',
                                                    style: TextStyle(
                                                      color: Colors.orange[800],
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                        const SizedBox(height: 20),
                        if (fingerprint.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.fingerprint, color: Colors.grey[600]),
                                    SizedBox(width: 8),
                                    Text(
                                      'بصمة الجهاز:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Spacer(),
                                    TextButton.icon(
                                      onPressed: copyFingerprint,
                                      icon: Icon(Icons.copy, size: 16),
                                      label: Text('نسخ'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                        minimumSize: Size(0, 30),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                SelectableText(
                                  fingerprint,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
