import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../localdatabase/student.dart';
import '../localdatabase/attendance.dart';
import '../localdatabase/class.dart';
import '../localdatabase/subject.dart';
import '../reports/attendance_reports_screen.dart';
import '../main.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  List<Student> students = [];
  List<SchoolClass> classes = [];
  List<Subject> subjects = [];
  List<Attendance> todayAttendance = [];
  
  SchoolClass? selectedClass;
  Subject? selectedSubject;
  DateTime selectedDate = DateTime.now();
  AttendanceType attendanceType = AttendanceType.daily;
  bool isLoading = true;
  
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd', 'ar');
  final DateFormat timeFormatter = DateFormat('HH:mm', 'ar');
  final DateFormat displayFormatter = DateFormat('EEEE، dd MMMM yyyy', 'ar');

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
      
      // تحميل علاقات المواد
      for (var subject in subjects) {
        await subject.schoolClass.load();
      }
      
      // تحميل مواد كل صف
      for (var schoolClass in classes) {
        await schoolClass.subjects.load();
      }
      
      await _loadTodayAttendance();
      
      // تشخيص العلاقات
      print('=== تشخيص علاقة المواد والصفوف ===');
      print('إجمالي الصفوف: ${classes.length}');
      print('إجمالي المواد: ${subjects.length}');
      
      for (var schoolClass in classes) {
        print('\nالصف: ${schoolClass.name} (ID: ${schoolClass.id})');
        print('  - مواد مرتبطة بالعلاقة: ${schoolClass.subjects.length}');
        
        final directSubjects = subjects.where((subject) => 
          subject.schoolClass.value?.id == schoolClass.id).toList();
        print('  - مواد مرتبطة مباشرة: ${directSubjects.length}');
        
        if (directSubjects.isNotEmpty) {
          print('  - أسماء المواد: ${directSubjects.map((s) => s.name).join(', ')}');
        }
      }
      
      print('\n=== المواد وارتباطها بالصفوف ===');
      for (var subject in subjects) {
        final className = subject.schoolClass.value?.name ?? "غير مرتبط";
        print('المادة: ${subject.name} → الصف: $className');
      }
      
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      var query = isar.attendances
          .where()
          .dateBetween(startOfDay, endOfDay);
      
      // فلتر حسب نوع الحضور والمادة إذا لزم الأمر
      todayAttendance = await query.findAll();
      
      // فلترة إضافية في الكود للنوع والمادة
      todayAttendance = todayAttendance.where((attendance) {
        bool typeMatch = attendance.type == attendanceType;
        bool subjectMatch = true;
        
        if (attendanceType == AttendanceType.subject && selectedSubject != null) {
          subjectMatch = attendance.subject.value?.id == selectedSubject!.id;
        }
        
        return typeMatch && subjectMatch;
      }).toList();
      
      // تحميل العلاقات
      for (var attendance in todayAttendance) {
        await attendance.student.load();
        await attendance.subject.load();
      }
      
      setState(() {});
    } catch (e) {
      print('خطأ في تحميل حضور اليوم: $e');
    }
  }

  List<Student> get filteredStudents {
    if (selectedClass == null) return students;
    return students.where((student) => 
      student.schoolclass.value?.id == selectedClass!.id).toList();
  }

  Attendance? _getStudentAttendance(Student student) {
    try {
      return todayAttendance.firstWhere(
        (attendance) => attendance.student.value?.id == student.id &&
                       attendance.type == attendanceType &&
                       (attendanceType == AttendanceType.daily || 
                        attendance.subject.value?.id == selectedSubject?.id)
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحضور والانصراف'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAttendanceReports,
            icon: const Icon(Icons.analytics),
            tooltip: 'تقارير الحضور',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildAttendanceTypeSelector(),
                  _buildFilterCard(),
                  _buildDateSelector(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: _buildAttendanceList(),
                  ),
                ],
              ),
            ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildAttendanceTypeSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نوع الحضور',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<AttendanceType>(
                    title: const Text('حضور يومي عام'),
                    subtitle: const Text('حضور شامل للطالب'),
                    value: AttendanceType.daily,
                    groupValue: attendanceType,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          attendanceType = value;
                          selectedSubject = null;
                        });
                        _loadTodayAttendance();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<AttendanceType>(
                    title: const Text('حضور حسب المادة'),
                    subtitle: const Text('يتطلب اختيار الصف والمادة'),
                    value: AttendanceType.subject,
                    groupValue: attendanceType,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          attendanceType = value;
                          // إعادة تعيين المادة عند تغيير النوع
                          selectedSubject = null;
                        });
                        _loadTodayAttendance();
                      }
                    },
                  ),
                ),
              ],
            ),
            if (attendanceType == AttendanceType.subject) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<Subject>(
                value: selectedSubject,
                decoration: InputDecoration(
                  labelText: 'المادة',
                  border: const OutlineInputBorder(),
                  hintText: selectedClass == null ? 'اختر الصف أولاً' : 'اختر المادة',
                  helperText: selectedClass != null 
                    ? 'المواد المتاحة للصف: ${selectedClass!.name} (${_getAvailableSubjects().length} مادة)'
                    : null,
                ),
                items: _getAvailableSubjects().map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject.name),
                  );
                }).toList(),
                onChanged: selectedClass == null ? null : (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                  _loadTodayAttendance();
                },
              ),
              if (selectedClass == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '📚 يجب اختيار الصف أولاً لإظهار مواد هذا الصف فقط',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (selectedClass != null && _getAvailableSubjects().isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '⚠️ لا توجد مواد مرتبطة بهذا الصف - يرجى إضافة مواد للصف أولاً',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (selectedClass != null && _getAvailableSubjects().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '✅ يتم عرض ${_getAvailableSubjects().length} مادة خاصة بالصف ${selectedClass!.name}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (selectedClass != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '🔍 تشخيص: إجمالي المواد في النظام: ${subjects.length}، مواد الصف: ${_getAvailableSubjects().length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Subject> _getAvailableSubjects() {
    if (selectedClass == null) {
      return []; // لا تُظهر أي مواد إذا لم يتم اختيار صف
    }
    
    // البحث عن المواد المرتبطة بالصف بطريقة مباشرة
    final directSubjects = subjects.where((subject) {
      // تحقق من أن المادة مُحملة وترتبط بالصف المحدد
      return subject.schoolClass.value?.id == selectedClass!.id;
    }).toList();
    
    print('🔍 البحث عن مواد الصف ${selectedClass!.name}:');
    print('  - مواد مرتبطة مباشرة: ${directSubjects.length}');
    
    if (directSubjects.isNotEmpty) {
      print('  - أسماء المواد: ${directSubjects.map((s) => s.name).join(', ')}');
      return directSubjects;
    }
    
    // البحث في علاقة الصف كحل بديل
    final linkedSubjects = selectedClass!.subjects.toList();
    print('  - مواد من علاقة الصف: ${linkedSubjects.length}');
    
    if (linkedSubjects.isNotEmpty) {
      print('  - أسماء المواد المرتبطة: ${linkedSubjects.map((s) => s.name).join(', ')}');
      return linkedSubjects;
    }
    
    // إذا لم توجد أي مواد مرتبطة
    print('  - ⚠️ لم توجد مواد مرتبطة بالصف');
    return [];
  }

  Widget _buildFilterCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فلترة حسب الصف',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SchoolClass>(
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
                  selectedSubject = null; // إعادة تعيين المادة عند تغيير الصف
                });
                _loadTodayAttendance();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التاريخ المحدد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    displayFormatter.format(selectedDate),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
       SizedBox(width:200,child:      ElevatedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.edit_calendar),
              label: const Text('تغيير'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (filteredStudents.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد طلاب في الصف المحدد',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final attendance = _getStudentAttendance(student);
        return _buildStudentAttendanceCard(student, attendance);
      },
    );
  }

  Widget _buildStudentAttendanceCard(Student student, Attendance? attendance) {
    final isPresent = attendance?.status == AttendanceStatus.present;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isPresent ? 3 : 1,
      color: _getCardColor(attendance?.status),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(attendance?.status),
                  child: Icon(
                    _getStatusIcon(attendance?.status),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'الصف: ${student.schoolclass.value?.name ?? 'غير محدد'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (attendanceType == AttendanceType.subject && selectedSubject != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'المادة: ${selectedSubject!.name}',
                              style: TextStyle(color: Colors.blue[600], fontSize: 12),
                            ),
                          ],
                          if (attendance != null) ...[
                            const SizedBox(width: 16),
                            Text(
                              _getStatusText(attendance.status),
                              style: TextStyle(
                                color: _getStatusColor(attendance.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (attendance?.checkInTime != null)
                        Text(
                          'وقت الوصول: ${timeFormatter.format(attendance!.checkInTime)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<AttendanceStatus>(
                  onSelected: (status) => _markAttendance(student, status),
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: AttendanceStatus.present,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('حاضر'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: AttendanceStatus.late,
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('متأخر'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: AttendanceStatus.absent,
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('غائب'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: AttendanceStatus.excused,
                      child: Row(
                        children: [
                          Icon(Icons.assignment, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('غياب معذور'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (attendance?.notes?.isNotEmpty == true)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                child: Text(
                  'ملاحظات: ${attendance!.notes}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'mark_all_present',
          onPressed: _markAllPresent,
          backgroundColor: Colors.green,
          child: const Icon(Icons.group, color: Colors.white),
          tooltip: 'تسجيل حضور جميع الطلاب',
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'attendance_stats',
          onPressed: _showQuickStats,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.analytics, color: Colors.white),
          tooltip: 'إحصائيات سريعة',
        ),
      ],
    );
  }

  Color _getCardColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green[50]!;
      case AttendanceStatus.late:
        return Colors.orange[50]!;
      case AttendanceStatus.absent:
        return Colors.red[50]!;
      case AttendanceStatus.excused:
        return Colors.blue[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getStatusColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.excused:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.excused:
        return Icons.assignment;
      default:
        return Icons.person;
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _loadTodayAttendance();
    }
  }

  Future<void> _markAttendance(Student student, AttendanceStatus status) async {
    try {
      // التحقق من المتطلبات
      if (attendanceType == AttendanceType.subject) {
        if (selectedClass == null) {
          _showErrorDialog('يجب اختيار الصف أولاً');
          return;
        }
        if (selectedSubject == null) {
          _showErrorDialog('يجب اختيار المادة أولاً');
          return;
        }
      }

      await isar.writeTxn(() async {
        // البحث عن سجل حضور موجود لهذا الطالب في هذا اليوم
        final existingAttendance = _getStudentAttendance(student);
        
        if (existingAttendance != null) {
          // تحديث الحضور الموجود
          existingAttendance.status = status;
          existingAttendance.checkInTime = DateTime.now();
          await isar.attendances.put(existingAttendance);
        } else {
          // إنشاء سجل حضور جديد
          final attendance = Attendance()
            ..date = selectedDate
            ..status = status
            ..type = attendanceType
            ..checkInTime = DateTime.now();
          
          await isar.attendances.put(attendance);
          
          // ربط الطالب
          attendance.student.value = student;
          await attendance.student.save();
          
          // ربط المادة إذا كان الحضور حسب المادة
          if (attendanceType == AttendanceType.subject && selectedSubject != null) {
            attendance.subject.value = selectedSubject;
            await attendance.subject.save();
          }
        }
      });

      await _loadTodayAttendance();
      
      String message = 'تم تسجيل ${_getStatusText(status)} للطالب ${student.fullName}';
      if (attendanceType == AttendanceType.subject && selectedSubject != null) {
        message += ' في مادة ${selectedSubject!.name}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _getStatusColor(status),
        ),
      );
    } catch (e) {
      _showErrorDialog('خطأ في تسجيل الحضور: $e');
    }
  }

  Future<void> _markAllPresent() async {
    if (filteredStudents.isEmpty) return;
    
    // التحقق من المتطلبات
    if (attendanceType == AttendanceType.subject) {
      if (selectedClass == null) {
        _showErrorDialog('يجب اختيار الصف أولاً');
        return;
      }
      if (selectedSubject == null) {
        _showErrorDialog('يجب اختيار المادة أولاً');
        return;
      }
    }
    
    String message = 'هل تريد تسجيل حضور جميع الطلاب (${filteredStudents.length} طالب)؟';
    if (attendanceType == AttendanceType.subject && selectedSubject != null) {
      message += '\nفي مادة ${selectedSubject!.name}';
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await isar.writeTxn(() async {
        for (final student in filteredStudents) {
          final existingAttendance = _getStudentAttendance(student);
          
          if (existingAttendance != null) {
            existingAttendance.status = AttendanceStatus.present;
            existingAttendance.checkInTime = DateTime.now();
            await isar.attendances.put(existingAttendance);
          } else {
            final attendance = Attendance()
              ..date = selectedDate
              ..status = AttendanceStatus.present
              ..type = attendanceType
              ..checkInTime = DateTime.now();
            
            await isar.attendances.put(attendance);
            
            attendance.student.value = student;
            await attendance.student.save();
            
            // ربط المادة إذا كان الحضور حسب المادة
            if (attendanceType == AttendanceType.subject && selectedSubject != null) {
              attendance.subject.value = selectedSubject;
              await attendance.subject.save();
            }
          }
        }
      });

      await _loadTodayAttendance();
      
      String successMessage = 'تم تسجيل حضور ${filteredStudents.length} طالب';
      if (attendanceType == AttendanceType.subject && selectedSubject != null) {
        successMessage += ' في مادة ${selectedSubject!.name}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('خطأ في تسجيل الحضور الجماعي: $e');
    }
  }

  void _showQuickStats() {
    final presentCount = todayAttendance.where((a) => a.status == AttendanceStatus.present).length;
    final lateCount = todayAttendance.where((a) => a.status == AttendanceStatus.late).length;
    final absentCount = todayAttendance.where((a) => a.status == AttendanceStatus.absent).length;
    final excusedCount = todayAttendance.where((a) => a.status == AttendanceStatus.excused).length;
    final totalStudents = filteredStudents.length;
    final notMarkedCount = totalStudents - todayAttendance.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إحصائيات ${displayFormatter.format(selectedDate)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('حاضر', presentCount, Colors.green),
            _buildStatRow('متأخر', lateCount, Colors.orange),
            _buildStatRow('غائب', absentCount, Colors.red),
            _buildStatRow('معذور', excusedCount, Colors.blue),
            _buildStatRow('غير مسجل', notMarkedCount, Colors.grey),
            const Divider(),
            _buildStatRow('إجمالي الطلاب', totalStudents, Colors.black),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceReportsScreen(),
      ),
    );
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
