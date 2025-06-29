// license_manager.dart
import 'dart:io';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'device_info_service.dart';

class LicenseManager {
  static const _fileName = 'license.key';
  static const _trialFileName = 'trial.key';
  static const _encryptionKey = 'my32lengthsupersecretnooneknows1'; // 32 chars

static Future<DateTime?> getEndDate() async {
  final path = await _getFilePath(_trialFileName);
  final file = File(path);
  if (!await file.exists()) return null;

  try {
    final content = await file.readAsString();
    final decrypted = _decrypt(content);
    return DateTime.tryParse(decrypted);
  } catch (e) {
    print('🔒 خطأ في قراءة تاريخ الانتهاء: $e');
    return null;
  }
}

static Future<bool> isTrialLicense() async {
  final path = await _getFilePath(_trialFileName);
  final exists = await File(path).exists();
  if (!exists) return false;

  try {
    final content = await File(path).readAsString();
    final decrypted = _decrypt(content);
    // إن كان النص بعد فك التشفير يحتوي على تاريخ (كما في التشفير الحالي)
    DateTime.parse(decrypted); // إذا لم يكن نصًا على هيئة تاريخ سترمي خطأ
    return true;
  } catch (e) {
    return false;
  }
}


  static Future<String> _getFilePath([String? file]) async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/${file ?? _fileName}';
  }

  static String _encrypt(String text) {
    final key = Key.fromUtf8(_encryptionKey);
    final iv = IV.fromSecureRandom(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);

    return jsonEncode({
      'iv': iv.base64,
      'data': encrypted.base64,
    });
  }

  static String _decrypt(String jsonString) {
    final key = Key.fromUtf8(_encryptionKey);
    final parsed = jsonDecode(jsonString);

    final iv = IV.fromBase64(parsed['iv']);
    final encrypted = parsed['data'];

    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt64(encrypted, iv: iv);
  }

  // ----------------------------- التفعيل الكامل -----------------------------

  static Future<void> createLicenseFile() async {
    final fingerprint = await DeviceInfoService.getDeviceFingerprint();
    final encrypted = _encrypt(fingerprint);
    final path = await _getFilePath();
    await File(path).writeAsString(encrypted);
  }

 static Future<bool> verifyLicense() async {
  try {
    final path = await _getFilePath();
    final exists = await File(path).exists();
    if (!exists) return false;

    final content = await File(path).readAsString();
    final stored = _decrypt(content); // ✅ التصحيح هنا
    final current = await DeviceInfoService.getDeviceFingerprint();
    return stored == current;
  } catch (e) {
    print('🔒 خطأ في التحقق من التفعيل: $e');
    return false;
  }
}
static Future<bool> trialFileExists() async {
  final path = await _getFilePath(_trialFileName);
  return File(path).exists();
}

  static Future<bool> activateWithCode(String code) async {
    final current = await DeviceInfoService.getDeviceFingerprint();
    final expected = _encrypt(current);

    // فك التشفير والتحقق من الكود
    try {
      final decoded = _decrypt(code);
      if (decoded == current) {
        await createLicenseFile();
        return true;
      }
    } catch (_) {}

    return false;
  }

  static String generateActivationCodeForDevice(String fingerprint) {
    return _encrypt(fingerprint);
  }

  // ----------------------------- الفترة التجريبية -----------------------------

  static Future<void> createTrialLicenseFile() async {
    final now = DateTime.now();
    final trialExpiry = now.add(const Duration(days: 14));
    final encrypted = _encrypt(trialExpiry.toIso8601String());
    final path = await _getFilePath(_trialFileName);
    await File(path).writeAsString(encrypted);
    print(path);
  }

  static Future<bool> isTrialValid() async {
    final path = await _getFilePath(_trialFileName);
    final exists = await File(path).exists();
    if (!exists) return false;

    try {
      final content = await File(path).readAsString();
      final expiryStr = _decrypt(content);
      final expiryDate = DateTime.parse(expiryStr);
      print('🔒 تاريخ انتهاء الفترة التجريبية: $expiryDate');
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      print('🔒 خطأ في التحقق من الفترة التجريبية: $e');
      return false;
    }
  }
}
