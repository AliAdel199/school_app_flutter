import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReportsUploadMode {
  automatic,  // رفع تلقائي
  manual,     // رفع يدوي
  scheduled   // رفع مجدول
}

class ReportsUploadService {
  static const String _uploadModeKey = 'reports_upload_mode';
  static const String _autoUploadTimeKey = 'auto_upload_time';
  static const String _lastUploadKey = 'last_upload_date';

  // الحصول على وضع الرفع المحفوظ
  static Future<ReportsUploadMode> getUploadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_uploadModeKey) ?? 0;
    return ReportsUploadMode.values[modeIndex];
  }

  // حفظ وضع الرفع
  static Future<void> setUploadMode(ReportsUploadMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_uploadModeKey, mode.index);
  }

  // حفظ وقت الرفع التلقائي
  static Future<void> setAutoUploadTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_autoUploadTimeKey, '${time.hour}:${time.minute}');
  }

  // الحصول على وقت الرفع التلقائي
  static Future<TimeOfDay> getAutoUploadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_autoUploadTimeKey) ?? '22:00';
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // رفع التقارير يدوياً
  static Future<bool> uploadReportsManually({
    required Map<String, dynamic> reportData,
    String? reportType,
  }) async {
    try {
      // محاكاة رفع ناجح للآن (يمكن إضافة التكامل مع Supabase لاحقاً)
      await Future.delayed(const Duration(seconds: 2));
      
      // تسجيل تاريخ آخر رفع
      await _saveLastUploadDate();
      
      return true;
    } catch (e) {
      print('خطأ في رفع التقرير: $e');
      return false;
    }
  }

  // رفع التقارير تلقائياً
  static Future<void> uploadReportsAutomatically() async {
    try {
      // جلب التقارير المحلية غير المرفوعة
      final pendingReports = await _getPendingReports();
      
      for (final report in pendingReports) {
        // محاكاة رفع التقرير
        await Future.delayed(const Duration(milliseconds: 500));
        print('تم رفع تقرير: ${report['type']}');
      }

      await _saveLastUploadDate();
    } catch (e) {
      print('خطأ في الرفع التلقائي: $e');
    }
  }

  // التحقق إذا كان الوقت مناسب للرفع التلقائي
  static Future<bool> isTimeForAutoUpload() async {
    final mode = await getUploadMode();
    if (mode != ReportsUploadMode.automatic) return false;

    final autoTime = await getAutoUploadTime();
    final now = TimeOfDay.now();
    
    // التحقق إذا كان الوقت الحالي مطابق لوقت الرفع (±5 دقائق)
    final nowMinutes = now.hour * 60 + now.minute;
    final autoMinutes = autoTime.hour * 60 + autoTime.minute;
    
    return (nowMinutes - autoMinutes).abs() <= 5;
  }

  // حفظ تاريخ آخر رفع
  static Future<void> _saveLastUploadDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUploadKey, DateTime.now().toIso8601String());
  }

  // الحصول على تاريخ آخر رفع
  static Future<DateTime?> getLastUploadDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastUploadKey);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // جلب التقارير المحلية غير المرفوعة
  static Future<List<Map<String, dynamic>>> _getPendingReports() async {
    // هنا يتم جلب التقارير من قاعدة البيانات المحلية (Isar)
    // التي لم يتم رفعها بعد
    return [
      {'type': 'grades', 'size': 1024, 'date': DateTime.now()},
      {'type': 'attendance', 'size': 512, 'date': DateTime.now()},
    ];
  }

  // عرض إعدادات رفع التقارير
  static void showUploadSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportsUploadSettingsDialog(),
    );
  }
}

class ReportsUploadSettingsDialog extends StatefulWidget {
  const ReportsUploadSettingsDialog({Key? key}) : super(key: key);

  @override
  State<ReportsUploadSettingsDialog> createState() => _ReportsUploadSettingsDialogState();
}

class _ReportsUploadSettingsDialogState extends State<ReportsUploadSettingsDialog> {
  ReportsUploadMode _selectedMode = ReportsUploadMode.manual;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mode = await ReportsUploadService.getUploadMode();
    final time = await ReportsUploadService.getAutoUploadTime();
    setState(() {
      _selectedMode = mode;
      _selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إعدادات رفع التقارير'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // وضع الرفع
            const Text(
              'اختر طريقة رفع التقارير:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // خيار الرفع اليدوي
            RadioListTile<ReportsUploadMode>(
              title: const Text('رفع يدوي'),
              subtitle: const Text('ترفع التقارير عند الضغط على زر الرفع'),
              value: ReportsUploadMode.manual,
              groupValue: _selectedMode,
              onChanged: (value) {
                setState(() {
                  _selectedMode = value!;
                });
              },
            ),
            
            // خيار الرفع التلقائي
            RadioListTile<ReportsUploadMode>(
              title: const Text('رفع تلقائي'),
              subtitle: const Text('ترفع التقارير تلقائياً في وقت محدد يومياً'),
              value: ReportsUploadMode.automatic,
              groupValue: _selectedMode,
              onChanged: (value) {
                setState(() {
                  _selectedMode = value!;
                });
              },
            ),
            
            // إعدادات الوقت للرفع التلقائي
            if (_selectedMode == ReportsUploadMode.automatic) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('وقت الرفع التلقائي:'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                    child: Text(_selectedTime.format(context)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم رفع التقارير تلقائياً كل يوم في الساعة ${_selectedTime.format(context)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            await ReportsUploadService.setUploadMode(_selectedMode);
            if (_selectedMode == ReportsUploadMode.automatic) {
              await ReportsUploadService.setAutoUploadTime(_selectedTime);
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ الإعدادات بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
