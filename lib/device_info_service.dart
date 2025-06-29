import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
static Future<String> getDeviceFingerprint() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isWindows) {
    final info = await deviceInfo.windowsInfo;
    return '${info.deviceId}-${info.buildNumber}-${info.computerName}';
  } else if (Platform.isLinux) {
    final info = await deviceInfo.linuxInfo;
    return '${info.machineId}-${info.prettyName}-${info.versionId}';
  } else if (Platform.isMacOS) {
    final info = await deviceInfo.macOsInfo;
    return '${info.systemGUID}-${info.computerName}-${info.arch}';
  } else {
    throw UnsupportedError('Unsupported platform');
  }
}

}
