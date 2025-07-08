import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'license_manager.dart';
import 'device_info_service.dart';
import 'reports/login_screen.dart';
import 'schoolregstristion.dart';

class LicenseCheckScreen extends StatefulWidget {
  const LicenseCheckScreen({super.key});

  @override
  State<LicenseCheckScreen> createState() => _LicenseCheckScreenState();
}

class _LicenseCheckScreenState extends State<LicenseCheckScreen> {
  final codeController = TextEditingController();
  String message = '';
  String fingerprint = '';
  bool isLoading = false;
  int remainingDays = 0;
  bool isTrialActive = false;

  @override
  void initState() {
    super.initState();
    _checkTrialStatus();
  }

  Future<void> _checkTrialStatus() async {
    final trialValid = await LicenseManager.isTrialValid();
    final days = await LicenseManager.getRemainingTrialDays();
    setState(() {
      isTrialActive = trialValid;
      remainingDays = days;
    });
  }

  Future<void> _activate() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    final success = await LicenseManager.activateWithCode(codeController.text.trim());

    setState(() {
      isLoading = false;
      message = success ? '✅ تم التفعيل بنجاح' : '❌ رمز التفعيل غير صحيح';
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _copyFingerprint() async {
    final fp = await DeviceInfoService.getDeviceFingerprint();
    await Clipboard.setData(ClipboardData(text: fp));
    setState(() => fingerprint = fp);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 تم نسخ بصمة الجهاز')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفعيل النسخة')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // معلومات الفترة التجريبية
                if (isTrialActive)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: remainingDays > 3 ? Colors.green.shade50 : Colors.orange.shade50,
                      border: Border.all(
                        color: remainingDays > 3 ? Colors.green : Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: remainingDays > 3 ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الفترة التجريبية: باقي $remainingDays يوم',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: remainingDays > 3 ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isTrialActive)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'انتهت الفترة التجريبية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                GestureDetector(
                  onLongPress: _copyFingerprint,
                  child: const Text(
                    'أدخل رمز التفعيل المزوّد لتفعيل النسخة:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(obscureText: true,
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'رمز التفعيل',
                    border: OutlineInputBorder(),
                  ),
                
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _activate,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('تفعيل'),
                      ),
                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: message.contains('✅') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (fingerprint.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        const Text(
                          'بصمة الجهاز:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(fingerprint),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                if (isTrialActive)
                  Text(
                    'الفترة التجريبية: ${remainingDays} يوم${remainingDays > 1 ? 'ا' : ''} متبقية',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
