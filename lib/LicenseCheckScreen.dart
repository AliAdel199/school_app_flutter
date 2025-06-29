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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
