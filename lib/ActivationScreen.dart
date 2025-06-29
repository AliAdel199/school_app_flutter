import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'device_info_service.dart';
import 'license_manager.dart';
import 'schoolregstristion.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final codeController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> handleActivation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = await LicenseManager.activateWithCode(codeController.text.trim());

    if (success) {
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
    String fingerprint = '';

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
        appBar: AppBar(title: Row(
          children: [
            const Text('تفعيل النظام',style: TextStyle(color: Colors.red),),IconButton(onPressed: copyFingerprint, icon: Icon(Icons.copy))
          ],
        )),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'انتهت الفترة التجريبية. الرجاء إدخال رمز التفعيل لمتابعة استخدام النظام.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'رمز التفعيل',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.vpn_key),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (errorMessage != null)
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: handleActivation,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('تفعيل الآن'),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
