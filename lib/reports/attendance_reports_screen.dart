import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../localdatabase/student.dart';
import '../localdatabase/attendance.dart';
import '../localdatabase/class.dart';
import '../localdatabase/subject.dart';
import '../main.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceReportsScreen> createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  List<Student> students = [];
  List<SchoolClass> classes = [];
  List<Subject> subjects = [];
  List<Attendance> attendanceRecords = [];
  
  SchoolClass? selectedClass;
  Subject? selectedSubject;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  AttendanceType? selectedAttendanceType;
  bool isLoading = true;
  
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd', 'ar');
  final DateFormat displayFormatter = DateFormat('dd/MM/yyyy', 'ar');
  final DateFormat exportDateFormatter = DateFormat('yyyy-MM-dd_HH-mm-ss');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      students = await isar.students.where().findAll();
      classes = await isar.schoolClass.where().findAll();
      subjects = await isar.subjects.where().findAll();
      
      // تحميل العلاقات
      for (var student in students) {
        await student.schoolclass.load();
      }
      
      for (var subject in subjects) {
        await subject.schoolClass.load();
      }
      
      for (var schoolClass in classes) {
        await schoolClass.subjects.load();
      }
      
      await _loadAttendanceRecords();
      
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    }
  }

  Future<void> _loadAttendanceRecords() async {
    try {
      var query = isar.attendances
          .where()
          .dateBetween(startDate, endDate.add(const Duration(days: 1)));
      
      attendanceRecords = await query.findAll();
      
      // فلترة حسب المعايير المحددة
      attendanceRecords = attendanceRecords.where((attendance) {
        bool classMatch = true;
        bool subjectMatch = true;
        bool typeMatch = true;
        
        // فلترة حسب الصف
        if (selectedClass != null) {
          classMatch = attendance.student.value?.schoolclass.value?.id == selectedClass!.id;
        }
        
        // فلترة حسب المادة
        if (selectedSubject != null) {
          subjectMatch = attendance.subject.value?.id == selectedSubject!.id;
        }
        
        // فلترة حسب نوع الحضور
        if (selectedAttendanceType != null) {
          typeMatch = attendance.type == selectedAttendanceType;
        }
        
        return classMatch && subjectMatch && typeMatch;
      }).toList();
      
      // تحميل العلاقات
      for (var attendance in attendanceRecords) {
        await attendance.student.load();
        await attendance.subject.load();
      }
      
      setState(() {});
    } catch (e) {
      print('خطأ في تحميل سجلات الحضور: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير الحضور'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _exportToCSV,
            icon: const Icon(Icons.download),
            tooltip: 'تصدير إلى CSV',
          ),
          IconButton(
            onPressed: _generateDetailedReport,
            icon: const Icon(Icons.article),
            tooltip: 'تقرير مفصل',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildFiltersCard(),
                  _buildStatisticsCard(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildReportsContent(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFiltersCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فلاتر التقرير',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // فترة التاريخ
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('من تاريخ', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectStartDate(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(displayFormatter.format(startDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى تاريخ', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectEndDate(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(displayFormatter.format(endDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // فلاتر إضافية
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<SchoolClass>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'الصف',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<SchoolClass>(
                        value: null,
                        child: Text('جميع الصفوف'),
                      ),
                      ...classes.map((schoolClass) {
                        return DropdownMenuItem(
                          value: schoolClass,
                          child: Text(schoolClass.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value;
                        selectedSubject = null;
                      });
                      _loadAttendanceRecords();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Subject>(
                    value: selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'المادة',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<Subject>(
                        value: null,
                        child: Text('جميع المواد'),
                      ),
                      ..._getAvailableSubjects().map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value;
                      });
                      _loadAttendanceRecords();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            DropdownButtonFormField<AttendanceType>(
              value: selectedAttendanceType,
              decoration: const InputDecoration(
                labelText: 'نوع الحضور',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem<AttendanceType>(
                  value: null,
                  child: Text('جميع الأنواع'),
                ),
                DropdownMenuItem(
                  value: AttendanceType.daily,
                  child: Text('حضور يومي'),
                ),
                DropdownMenuItem(
                  value: AttendanceType.subject,
                  child: Text('حضور المادة'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedAttendanceType = value;
                });
                _loadAttendanceRecords();
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: _loadAttendanceRecords,
                    icon: const Icon(Icons.search),
                    label: const Text('تطبيق الفلاتر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: OutlinedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('إعادة تعيين'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final totalRecords = attendanceRecords.length;
    final presentCount = attendanceRecords.where((a) => a.status == AttendanceStatus.present).length;
    final lateCount = attendanceRecords.where((a) => a.status == AttendanceStatus.late).length;
    final absentCount = attendanceRecords.where((a) => a.status == AttendanceStatus.absent).length;
    final excusedCount = attendanceRecords.where((a) => a.status == AttendanceStatus.excused).length;
    
    final attendanceRate = totalRecords > 0 ? ((presentCount + lateCount) / totalRecords * 100) : 0.0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'إحصائيات عامة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'من ${displayFormatter.format(startDate)} إلى ${displayFormatter.format(endDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('إجمالي السجلات', totalRecords.toString(), Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('نسبة الحضور', '${attendanceRate.toStringAsFixed(1)}%', Colors.green),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('حاضر', presentCount.toString(), Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('متأخر', lateCount.toString(), Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('غائب', absentCount.toString(), Colors.red),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('معذور', excusedCount.toString(), Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'تقرير تفصيلي', icon: Icon(Icons.list)),
              Tab(text: 'تقرير يومي', icon: Icon(Icons.calendar_today)),
              Tab(text: 'تقرير الطلاب', icon: Icon(Icons.person)),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDetailedReport(),
                _buildDailyReport(),
                _buildStudentReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedReport() {
    if (attendanceRecords.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد سجلات حضور للفترة المحددة',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendanceRecords.length,
      itemBuilder: (context, index) {
        final attendance = attendanceRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(attendance.status),
              child: Icon(
                _getStatusIcon(attendance.status),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(attendance.student.value?.fullName ?? 'غير محدد'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الصف: ${attendance.student.value?.schoolclass.value?.name ?? 'غير محدد'}'),
                if (attendance.subject.value != null)
                  Text('المادة: ${attendance.subject.value!.name}'),
                Text('التاريخ: ${displayFormatter.format(attendance.date)}'),
                Text('الوقت: ${DateFormat('HH:mm').format(attendance.checkInTime)}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(attendance.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(attendance.status),
                style: TextStyle(
                  color: _getStatusColor(attendance.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyReport() {
    // تجميع السجلات حسب التاريخ
    Map<String, List<Attendance>> dailyGroups = {};
    for (var attendance in attendanceRecords) {
      String dateKey = dateFormatter.format(attendance.date);
      dailyGroups[dateKey] ??= [];
      dailyGroups[dateKey]!.add(attendance);
    }

    if (dailyGroups.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد سجلات حضور للفترة المحددة',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    List<String> sortedDates = dailyGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String dateKey = sortedDates[index];
        List<Attendance> dayAttendances = dailyGroups[dateKey]!;
        DateTime date = DateTime.parse(dateKey);
        
        final presentCount = dayAttendances.where((a) => a.status == AttendanceStatus.present).length;
        final lateCount = dayAttendances.where((a) => a.status == AttendanceStatus.late).length;
        final absentCount = dayAttendances.where((a) => a.status == AttendanceStatus.absent).length;
        final excusedCount = dayAttendances.where((a) => a.status == AttendanceStatus.excused).length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              DateFormat('EEEE، dd MMMM yyyy', 'ar').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('إجمالي السجلات: ${dayAttendances.length}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('حاضر', presentCount.toString(), Colors.green)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('متأخر', lateCount.toString(), Colors.orange)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('غائب', absentCount.toString(), Colors.red)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('معذور', excusedCount.toString(), Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...dayAttendances.map((attendance) => ListTile(
                      leading: Icon(
                        _getStatusIcon(attendance.status),
                        color: _getStatusColor(attendance.status),
                      ),
                      title: Text(attendance.student.value?.fullName ?? 'غير محدد'),
                      subtitle: Text('${attendance.student.value?.schoolclass.value?.name ?? 'غير محدد'}${attendance.subject.value != null ? ' - ${attendance.subject.value!.name}' : ''}'),
                      trailing: Text(
                        _getStatusText(attendance.status),
                        style: TextStyle(
                          color: _getStatusColor(attendance.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentReport() {
    // تجميع السجلات حسب الطالب
    Map<int, List<Attendance>> studentGroups = {};
    for (var attendance in attendanceRecords) {
      int studentId = attendance.student.value?.id ?? 0;
      studentGroups[studentId] ??= [];
      studentGroups[studentId]!.add(attendance);
    }

    if (studentGroups.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد سجلات حضور للفترة المحددة',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: studentGroups.length,
      itemBuilder: (context, index) {
        int studentId = studentGroups.keys.elementAt(index);
        List<Attendance> studentAttendances = studentGroups[studentId]!;
        Student? student = studentAttendances.first.student.value;
        
        if (student == null) return const SizedBox.shrink();
        
        final presentCount = studentAttendances.where((a) => a.status == AttendanceStatus.present).length;
        final lateCount = studentAttendances.where((a) => a.status == AttendanceStatus.late).length;
        final absentCount = studentAttendances.where((a) => a.status == AttendanceStatus.absent).length;
        final excusedCount = studentAttendances.where((a) => a.status == AttendanceStatus.excused).length;
        final totalDays = studentAttendances.length;
        final attendanceRate = totalDays > 0 ? ((presentCount + lateCount) / totalDays * 100) : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الصف: ${student.schoolclass.value?.name ?? 'غير محدد'}'),
                Text('نسبة الحضور: ${attendanceRate.toStringAsFixed(1)}%'),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('حاضر', presentCount.toString(), Colors.green)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('متأخر', lateCount.toString(), Colors.orange)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('غائب', absentCount.toString(), Colors.red)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatCard('معذور', excusedCount.toString(), Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تفاصيل الحضور:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...studentAttendances.map((attendance) => ListTile(
                      leading: Icon(
                        _getStatusIcon(attendance.status),
                        color: _getStatusColor(attendance.status),
                      ),
                      title: Text(displayFormatter.format(attendance.date)),
                      subtitle: Text(attendance.subject.value?.name ?? 'حضور عام'),
                      trailing: Text(
                        _getStatusText(attendance.status),
                        style: TextStyle(
                          color: _getStatusColor(attendance.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Subject> _getAvailableSubjects() {
    if (selectedClass == null) {
      return subjects;
    }
    return subjects.where((subject) => subject.schoolClass.value?.id == selectedClass!.id).toList();
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.excused:
        return Colors.blue;
      case AttendanceStatus.leftEarly:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.excused:
        return Icons.assignment;
      case AttendanceStatus.leftEarly:
        return Icons.exit_to_app;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.late:
        return 'متأخر';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.excused:
        return 'معذور';
      case AttendanceStatus.leftEarly:
        return 'مغادرة مبكرة';
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      await _loadAttendanceRecords();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      await _loadAttendanceRecords();
    }
  }

  void _resetFilters() {
    setState(() {
      selectedClass = null;
      selectedSubject = null;
      selectedAttendanceType = null;
      startDate = DateTime.now().subtract(const Duration(days: 30));
      endDate = DateTime.now();
    });
    _loadAttendanceRecords();
  }

  Future<void> _exportToCSV() async {
    if (attendanceRecords.isEmpty) {
      _showErrorDialog('لا توجد بيانات للتصدير');
      return;
    }

    try {
      // إعداد محتوى CSV
      List<List<String>> csvData = [];
      
      // إضافة العناوين
      csvData.add([
        'اسم الطالب',
        'الصف',
        'المادة',
        'التاريخ',
        'نوع الحضور',
        'حالة الحضور',
        'وقت الوصول',
        'ملاحظات'
      ]);
      
      // إضافة البيانات
      for (var attendance in attendanceRecords) {
        csvData.add([
          attendance.student.value?.fullName ?? '',
          attendance.student.value?.schoolclass.value?.name ?? '',
          attendance.subject.value?.name ?? 'حضور عام',
          displayFormatter.format(attendance.date),
          attendance.type == AttendanceType.daily ? 'يومي' : 'مادة',
          _getStatusText(attendance.status),
          DateFormat('HH:mm').format(attendance.checkInTime),
          attendance.notes ?? ''
        ]);
      }
      
      // تحويل إلى CSV
      String csvContent = csvData.map((row) => 
        row.map((field) => '"${field.replaceAll('"', '""')}"').join(',')
      ).join('\n');
      
      // إضافة BOM للدعم العربي
      csvContent = '\uFEFF' + csvContent;
      
      // حفظ الملف
      String? result = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ تقرير الحضور',
        fileName: 'attendance_report_${exportDateFormatter.format(DateTime.now())}.csv',
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsString(csvContent, encoding: utf8);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير التقرير بنجاح إلى: $result'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في تصدير التقرير: $e');
    }
  }

  Future<void> _generateDetailedReport() async {
    if (attendanceRecords.isEmpty) {
      _showErrorDialog('لا توجد بيانات لإنشاء التقرير');
      return;
    }

    try {
      // إعداد التقرير المفصل
      StringBuffer report = StringBuffer();
      
      report.writeln('تقرير الحضور المفصل');
      report.writeln('=' * 50);
      report.writeln('الفترة: من ${displayFormatter.format(startDate)} إلى ${displayFormatter.format(endDate)}');
      
      if (selectedClass != null) {
        report.writeln('الصف: ${selectedClass!.name}');
      }
      
      if (selectedSubject != null) {
        report.writeln('المادة: ${selectedSubject!.name}');
      }
      
      if (selectedAttendanceType != null) {
        report.writeln('نوع الحضور: ${selectedAttendanceType == AttendanceType.daily ? 'يومي' : 'مادة'}');
      }
      
      report.writeln('تاريخ التقرير: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      report.writeln('=' * 50);
      report.writeln();
      
      // الإحصائيات العامة
      final totalRecords = attendanceRecords.length;
      final presentCount = attendanceRecords.where((a) => a.status == AttendanceStatus.present).length;
      final lateCount = attendanceRecords.where((a) => a.status == AttendanceStatus.late).length;
      final absentCount = attendanceRecords.where((a) => a.status == AttendanceStatus.absent).length;
      final excusedCount = attendanceRecords.where((a) => a.status == AttendanceStatus.excused).length;
      final attendanceRate = totalRecords > 0 ? ((presentCount + lateCount) / totalRecords * 100) : 0.0;
      
      report.writeln('الإحصائيات العامة:');
      report.writeln('-' * 20);
      report.writeln('إجمالي السجلات: $totalRecords');
      report.writeln('حاضر: $presentCount');
      report.writeln('متأخر: $lateCount');
      report.writeln('غائب: $absentCount');
      report.writeln('معذور: $excusedCount');
      report.writeln('نسبة الحضور: ${attendanceRate.toStringAsFixed(2)}%');
      report.writeln();
      
      // التفاصيل
      report.writeln('تفاصيل السجلات:');
      report.writeln('-' * 20);
      
      for (var attendance in attendanceRecords) {
        report.writeln('الطالب: ${attendance.student.value?.fullName ?? 'غير محدد'}');
        report.writeln('الصف: ${attendance.student.value?.schoolclass.value?.name ?? 'غير محدد'}');
        if (attendance.subject.value != null) {
          report.writeln('المادة: ${attendance.subject.value!.name}');
        }
        report.writeln('التاريخ: ${displayFormatter.format(attendance.date)}');
        report.writeln('الحالة: ${_getStatusText(attendance.status)}');
        report.writeln('الوقت: ${DateFormat('HH:mm').format(attendance.checkInTime)}');
        if (attendance.notes?.isNotEmpty == true) {
          report.writeln('ملاحظات: ${attendance.notes}');
        }
        report.writeln('-' * 30);
      }
      
      // حفظ التقرير
      String? result = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ التقرير المفصل',
        fileName: 'detailed_attendance_report_${exportDateFormatter.format(DateTime.now())}.txt',
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsString(report.toString(), encoding: utf8);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء التقرير المفصل بنجاح: $result'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في إنشاء التقرير: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
