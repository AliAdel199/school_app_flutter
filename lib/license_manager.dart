import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'device_info_service.dart';
import 'dart:convert';

class LicenseManager {
  static const _fileName = 'license.key';
  static const _encryptionKey = 'my32lengthsupersecretnooneknows1'; // 32 chars

  static Future<String> _getFilePath() async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/$_fileName';
  }

  static String _encrypt(String text) {
    final key = Key.fromUtf8(_encryptionKey);
    final iv = IV.fromSecureRandom(16); // ✅ IV عشوائي

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);

    // نخزن IV مع النص المشفر بصيغة JSON
    final result = jsonEncode({
      'iv': iv.base64,
      'data': encrypted.base64,
    });

    return result;
  }

  static String _decrypt(String jsonString) {
    final key = Key.fromUtf8(_encryptionKey);
    final parsed = jsonDecode(jsonString);

    final iv = IV.fromBase64(parsed['iv']);
    final encrypted = parsed['data'];

    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt64(encrypted, iv: iv);
  }

  static Future<void> createLicenseFile() async {
    final fingerprint = await DeviceInfoService.getDeviceFingerprint();
    final encrypted = _encrypt(fingerprint);
    final filePath = await _getFilePath();
    await File(filePath).writeAsString(encrypted);
    print(filePath);
  }

  static Future<bool> verifyLicense() async {
    final filePath = await _getFilePath();
    final exists = await File(filePath).exists();
    print(filePath);
    if (!exists) return false;

    try {
      final encrypted = await File(filePath).readAsString();
      final storedFingerprint = _decrypt(encrypted);
      final currentFingerprint = await DeviceInfoService.getDeviceFingerprint();
      return storedFingerprint == currentFingerprint;
    } catch (e) {
      print('🔒 خطأ في فك التشفير: $e');
      return false;
    }
  }
}
