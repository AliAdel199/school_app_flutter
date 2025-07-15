import 'package:isar/isar.dart';
import 'student.dart';
import 'subject.dart';

part 'attendance.g.dart';

@Collection()
class Attendance {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime date;
  
  @Enumerated(EnumType.name)
  late AttendanceStatus status;
  
  @Enumerated(EnumType.name)
  late AttendanceType type; // نوع الحضور: يومي أم حسب المادة
  
  String? notes; // ملاحظات إضافية
  
  @Index()
  late DateTime checkInTime; // وقت الوصول
  
  DateTime? checkOutTime; // وقت المغادرة (اختياري)
  
  String? excuseReason; // سبب الغياب إذا كان معذور
  
  // علاقة مع الطالب
  final student = IsarLink<Student>();
  
  // علاقة مع المادة (للحضور حسب المادة فقط)
  final subject = IsarLink<Subject>();
  
  // للحصول على تاريخ بدون وقت للفهرسة
  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

enum AttendanceStatus {
  present,     // حاضر
  absent,      // غائب
  late,        // متأخر
  excused,     // غياب معذور
  leftEarly    // مغادرة مبكرة
}

enum AttendanceType {
  daily,       // حضور يومي عام
  subject      // حضور حسب المادة
}

// فئة للحصول على إحصائيات الحضور
class AttendanceStats {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int excusedDays;
  final int leftEarlyDays;
  
  AttendanceStats({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.excusedDays,
    required this.leftEarlyDays,
  });
  
  double get attendancePercentage {
    if (totalDays == 0) return 0.0;
    return (presentDays + lateDays + leftEarlyDays) / totalDays * 100;
  }
  
  double get punctualityPercentage {
    if (totalDays == 0) return 0.0;
    return presentDays / totalDays * 100;
  }
}
