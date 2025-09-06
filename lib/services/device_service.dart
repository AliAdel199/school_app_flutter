import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// خدمة إدارة معلومات الأجهزة
/// تجمع معلومات الجهاز وتنشئ بصمة فريدة له
class DeviceService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// جمع معلومات الجهاز حسب المنصة
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    Map<String, dynamic> deviceData = {};
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceData = {
          'platform': 'android',
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'product': androidInfo.product,
          'id': androidInfo.id,
          'fingerprint': androidInfo.fingerprint,
          'hardware': androidInfo.hardware,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'serialNumber': androidInfo.serialNumber,
          'supported32BitAbis': androidInfo.supported32BitAbis,
          'supported64BitAbis': androidInfo.supported64BitAbis,
          'supportedAbis': androidInfo.supportedAbis,
          'systemFeatures': androidInfo.systemFeatures,
          'version': {
            'baseOS': androidInfo.version.baseOS,
            'codename': androidInfo.version.codename,
            'incremental': androidInfo.version.incremental,
            'previewSdkInt': androidInfo.version.previewSdkInt,
            'release': androidInfo.version.release,
            'sdkInt': androidInfo.version.sdkInt,
            'securityPatch': androidInfo.version.securityPatch,
          },
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceData = {
          'platform': 'ios',
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'model': iosInfo.model,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'utsname': {
            'sysname': iosInfo.utsname.sysname,
            'nodename': iosInfo.utsname.nodename,
            'release': iosInfo.utsname.release,
            'version': iosInfo.utsname.version,
            'machine': iosInfo.utsname.machine,
          },
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        deviceData = {
          'platform': 'windows',
          'computerName': windowsInfo.computerName,
          'numberOfCores': windowsInfo.numberOfCores,
          'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
          'userName': windowsInfo.userName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
          'buildNumber': windowsInfo.buildNumber,
          'platformId': windowsInfo.platformId,
          'csdVersion': windowsInfo.csdVersion,
          'servicePackMajor': windowsInfo.servicePackMajor,
          'servicePackMinor': windowsInfo.servicePackMinor,
          'suitMask': windowsInfo.suitMask,
          'productType': windowsInfo.productType,
          'reserved': windowsInfo.reserved,
          'buildLab': windowsInfo.buildLab,
          'buildLabEx': windowsInfo.buildLabEx,
          'digitalProductId': windowsInfo.digitalProductId,
          'displayVersion': windowsInfo.displayVersion,
          'editionId': windowsInfo.editionId,
          'installDate': windowsInfo.installDate.toIso8601String(),
          'productId': windowsInfo.productId,
          'productName': windowsInfo.productName,
          'registeredOwner': windowsInfo.registeredOwner,
          'releaseId': windowsInfo.releaseId,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        deviceData = {
          'platform': 'linux',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
          'idLike': linuxInfo.idLike,
          'versionCodename': linuxInfo.versionCodename,
          'versionId': linuxInfo.versionId,
          'prettyName': linuxInfo.prettyName,
          'buildId': linuxInfo.buildId,
          'variant': linuxInfo.variant,
          'variantId': linuxInfo.variantId,
          'machineId': linuxInfo.machineId,
        };
      } else if (Platform.isMacOS) {
        final macOSInfo = await _deviceInfoPlugin.macOsInfo;
        deviceData = {
          'platform': 'macos',
          'computerName': macOSInfo.computerName,
          'hostName': macOSInfo.hostName,
          'arch': macOSInfo.arch,
          'model': macOSInfo.model,
          'kernelVersion': macOSInfo.kernelVersion,
          'majorVersion': macOSInfo.majorVersion,
          'minorVersion': macOSInfo.minorVersion,
          'patchVersion': macOSInfo.patchVersion,
          'osRelease': macOSInfo.osRelease,
          'activeCPUs': macOSInfo.activeCPUs,
          'memorySize': macOSInfo.memorySize,
          'cpuFrequency': macOSInfo.cpuFrequency,
          'systemGUID': macOSInfo.systemGUID,
        };
      } else {
        deviceData = {
          'platform': 'unknown',
          'error': 'منصة غير مدعومة',
        };
      }
    } catch (e) {
      print('❌ خطأ في جمع معلومات الجهاز: $e');
      deviceData = {
        'platform': 'unknown',
        'error': 'فشل في جمع المعلومات: $e',
      };
    }
    
    return deviceData;
  }

  /// إنشاء بصمة فريدة للجهاز
  static Future<String> generateDeviceFingerprint() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final platform = deviceInfo['platform'] ?? 'unknown';
      
      String fingerprintData = '';
      
      switch (platform) {
        case 'android':
          fingerprintData = [
            deviceInfo['manufacturer'] ?? 'unknown',
            deviceInfo['model'] ?? 'unknown',
            deviceInfo['id'] ?? 'unknown',
            deviceInfo['fingerprint'] ?? 'unknown',
            deviceInfo['brand'] ?? 'unknown',
          ].join('_');
          break;
          
        case 'ios':
          fingerprintData = [
            deviceInfo['model'] ?? 'unknown',
            deviceInfo['identifierForVendor'] ?? 'unknown',
            deviceInfo['systemVersion'] ?? 'unknown',
            deviceInfo['name'] ?? 'unknown',
          ].join('_');
          break;
          
        case 'windows':
          fingerprintData = [
            deviceInfo['computerName'] ?? 'unknown',
            deviceInfo['userName'] ?? 'unknown',
            deviceInfo['majorVersion']?.toString() ?? 'unknown',
            deviceInfo['buildNumber']?.toString() ?? 'unknown',
          ].join('_');
          break;
          
        case 'linux':
          fingerprintData = [
            deviceInfo['machineId'] ?? 'unknown',
            deviceInfo['name'] ?? 'unknown',
            deviceInfo['version'] ?? 'unknown',
          ].join('_');
          break;
          
        case 'macos':
          fingerprintData = [
            deviceInfo['computerName'] ?? 'unknown',
            deviceInfo['hostName'] ?? 'unknown',
            deviceInfo['model'] ?? 'unknown',
            deviceInfo['systemGUID'] ?? 'unknown',
          ].join('_');
          break;
          
        default:
          fingerprintData = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // تنظيف البيانات وإنشاء hash
      final cleanedData = fingerprintData
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^\w_-]'), '')
          .toLowerCase();
      
      // إنشاء SHA-256 hash للبصمة
      final bytes = utf8.encode(cleanedData);
      final digest = sha256.convert(bytes);
      
      return '${platform}_${digest.toString().substring(0, 16)}';
      
    } catch (e) {
      print('❌ خطأ في إنشاء بصمة الجهاز: $e');
      return 'error_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// الحصول على معلومات مختصرة للجهاز للعرض
  static Future<Map<String, String>> getDisplayInfo() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final platform = deviceInfo['platform'] ?? 'unknown';
      
      switch (platform) {
        case 'android':
          return {
            'النوع': 'أندرويد',
            'الشركة المصنعة': deviceInfo['manufacturer'] ?? 'غير معروف',
            'الموديل': deviceInfo['model'] ?? 'غير معروف',
            'إصدار النظام': deviceInfo['version']?['release'] ?? 'غير معروف',
          };
          
        case 'ios':
          return {
            'النوع': 'آيفون/آيباد',
            'الاسم': deviceInfo['name'] ?? 'غير معروف',
            'الموديل': deviceInfo['model'] ?? 'غير معروف',
            'إصدار النظام': deviceInfo['systemVersion'] ?? 'غير معروف',
          };
          
        case 'windows':
          return {
            'النوع': 'ويندوز',
            'اسم الجهاز': deviceInfo['computerName'] ?? 'غير معروف',
            'إصدار النظام': '${deviceInfo['majorVersion']}.${deviceInfo['minorVersion']}',
            'رقم البناء': deviceInfo['buildNumber']?.toString() ?? 'غير معروف',
          };
          
        case 'linux':
          return {
            'النوع': 'لينكس',
            'التوزيعة': deviceInfo['prettyName'] ?? 'غير معروف',
            'الإصدار': deviceInfo['version'] ?? 'غير معروف',
            'المعرف': deviceInfo['id'] ?? 'غير معروف',
          };
          
        case 'macos':
          return {
            'النوع': 'ماك',
            'اسم الجهاز': deviceInfo['computerName'] ?? 'غير معروف',
            'الموديل': deviceInfo['model'] ?? 'غير معروف',
            'إصدار النظام': '${deviceInfo['majorVersion']}.${deviceInfo['minorVersion']}.${deviceInfo['patchVersion']}',
          };
          
        default:
          return {
            'النوع': 'غير معروف',
            'الخطأ': deviceInfo['error']?.toString() ?? 'منصة غير مدعومة',
          };
      }
    } catch (e) {
      return {
        'خطأ': 'فشل في جمع معلومات الجهاز: $e',
      };
    }
  }

  /// التحقق من أن الجهاز حقيقي وليس محاكي
  static Future<bool> isPhysicalDevice() async {
    try {
      final deviceInfo = await getDeviceInfo();
      return deviceInfo['isPhysicalDevice'] == true;
    } catch (e) {
      print('❌ خطأ في التحقق من نوع الجهاز: $e');
      return true; // افتراض أنه جهاز حقيقي في حالة الخطأ
    }
  }
}
