import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../localdatabase/student.dart';
import '../localdatabase/subject.dart';
import '../localdatabase/subject_mark.dart';
import '../localdatabase/class.dart';
import '../main.dart';

class StudentGradesReportScreen extends StatefulWidget {
  const StudentGradesReportScreen({Key? key}) : super(key: key);

  @override
  State<StudentGradesReportScreen> createState() => _StudentGradesReportScreenState();
}

class _StudentGradesReportScreenState extends State<StudentGradesReportScreen> {
  List<Student> students = [];
  List<Subject> subjects = [];
  List<SubjectMark> marks = [];
  List<SchoolClass> classes = [];
  
  Student? selectedStudent;
  String selectedEvaluationType = 'نهائي';
  String selectedAcademicYear = academicYear;
  String searchQuery = '';
  
  final List<String> evaluationTypes = ['نصف سنة', 'نهائي', 'شفوي', 'عملي', 'مشاركة'];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final loadedStudents = await isar.students.where().findAll();
      final loadedSubjects = await isar.subjects.where().findAll();
      final loadedMarks = await isar.subjectMarks.where().findAll();
      final loadedClasses = await isar.schoolClass.where().findAll();

      // تحميل العلاقات
      for (var student in loadedStudents) {
        await student.schoolclass.load();
      }
      
      for (var subject in loadedSubjects) {
        await subject.schoolClass.load();
      }
      
      for (var mark in loadedMarks) {
        await mark.student.load();
        await mark.subject.load();
      }

      setState(() {
        students = loadedStudents;
        subjects = loadedSubjects;
        marks = loadedMarks;
        classes = loadedClasses;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorMessage('خطأ في تحميل البيانات: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<SubjectMark> _getStudentMarks() {
    if (selectedStudent == null) return [];
    
    return marks.where((mark) =>
      mark.student.value?.id == selectedStudent!.id &&
      mark.evaluationType == selectedEvaluationType &&
      mark.academicYear == selectedAcademicYear
    ).toList();
  }

  double _calculateAverage() {
    final studentMarks = _getStudentMarks();
    if (studentMarks.isEmpty) return 0.0;
    
    double totalPercentage = 0.0;
    int validMarksCount = 0;
    
    for (var mark in studentMarks) {
      if (mark.mark != null && mark.subject.value != null) {
        final percentage = (mark.mark! / mark.subject.value!.maxMark) * 100;
        totalPercentage += percentage;
        validMarksCount++;
      }
    }
    
    return validMarksCount > 0 ? totalPercentage / validMarksCount : 0.0;
  }

  String _getStudentStatus() {
    final average = _calculateAverage();
    final studentMarks = _getStudentMarks();
    
    if (studentMarks.isEmpty || average == 0.0) return 'غير مقيم';
    
    // حساب عدد المواد الراسبة بناءً على النسبة المئوية
    int failedSubjects = 0;
    int incompleteSubjects = 0;
    
    for (var mark in studentMarks) {
      if (mark.mark != null && mark.subject.value != null) {
        final percentage = (mark.mark! / mark.subject.value!.maxMark) * 100;
        if (percentage < 50) {
          if (percentage >= 40) {
            incompleteSubjects++;
          } else {
            failedSubjects++;
          }
        }
      }
    }
    
    if (failedSubjects == 0 && incompleteSubjects == 0) {
      return 'ناجح';
    } else if (failedSubjects == 0 && incompleteSubjects <= 2) {
      return 'مكمل';
    } else {
      return 'راسب';
    }
  }

  List<Student> get filteredStudents {
    if (searchQuery.isEmpty) return students;
    return students.where((student) =>
      student.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
      (student.schoolclass.value?.name ?? '').toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  Color _getStatusColor() {
    final status = _getStudentStatus();
    switch (status) {
      case 'ناجح':
        return Colors.green;
      case 'مكمل':
        return Colors.orange;
      case 'راسب':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير درجات الطالب'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (selectedStudent != null)
            IconButton(
              onPressed: () => _exportStudentToExcel(),
              icon: const Icon(Icons.file_download),
              tooltip: 'تصدير إلى Excel',
            ),
          if (selectedStudent != null)
            IconButton(
              onPressed: () => _generatePrintableCertificate(),
              icon: const Icon(Icons.print),
              tooltip: 'طباعة الشهادة',
            ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/marks-management'),
            icon: const Icon(Icons.grade),
            tooltip: 'إدارة الدرجات',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildFiltersCard(),
                  if (selectedStudent != null) ...[
                    _buildStudentInfoCard(),
                    _buildGradesSummaryCard(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: _buildGradesTable(),
                    ),
                  ] else
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: const Center(
                        child: Text(
                          'اختر طالب لعرض درجاته',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
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
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'فلترة البيانات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Desktop layout
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<Student>(
                          value: selectedStudent,
                          decoration: const InputDecoration(
                            labelText: 'الطالب',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: filteredStudents.map((student) {
                            return DropdownMenuItem(
                              value: student,
                              child: Text('${student.fullName} - ${student.schoolclass.value?.name ?? 'غير محدد'}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStudent = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedEvaluationType,
                          decoration: const InputDecoration(
                            labelText: 'نوع التقييم',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.assignment),
                          ),
                          items: evaluationTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedEvaluationType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: selectedAcademicYear,
                          decoration: const InputDecoration(
                            labelText: 'السنة الدراسية',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          onChanged: (value) {
                            selectedAcademicYear = value;
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile layout
                  return Column(
                    children: [
                      DropdownButtonFormField<Student>(
                        value: selectedStudent,
                        decoration: const InputDecoration(
                          labelText: 'الطالب',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: filteredStudents.map((student) {
                          return DropdownMenuItem(
                            value: student,
                            child: Text('${student.fullName} - ${student.schoolclass.value?.name ?? 'غير محدد'}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStudent = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedEvaluationType,
                              decoration: const InputDecoration(
                                labelText: 'نوع التقييم',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.assignment),
                              ),
                              items: evaluationTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedEvaluationType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: selectedAcademicYear,
                              decoration: const InputDecoration(
                                labelText: 'السنة الدراسية',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              onChanged: (value) {
                                selectedAcademicYear = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'البحث عن طالب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                hintText: 'اكتب اسم الطالب أو الصف للبحث...',
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  // إعادة تعيين الطالب المحدد إذا لم يعد ضمن النتائج المفلترة
                  if (selectedStudent != null && !filteredStudents.contains(selectedStudent)) {
                    selectedStudent = null;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'معلومات الطالب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow('الاسم الكامل', selectedStudent!.fullName),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildInfoRow('الصف', selectedStudent!.schoolclass.value?.name ?? 'غير محدد'),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildInfoRow('السنة الدراسية', selectedAcademicYear),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildInfoRow('الاسم الكامل', selectedStudent!.fullName),
                      const SizedBox(height: 8),
                      _buildInfoRow('الصف', selectedStudent!.schoolclass.value?.name ?? 'غير محدد'),
                      const SizedBox(height: 8),
                      _buildInfoRow('السنة الدراسية', selectedAcademicYear),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildGradesSummaryCard() {
    final average = _calculateAverage();
    final status = _getStudentStatus();
    final statusColor = _getStatusColor();
    final studentMarks = _getStudentMarks();
    
    int passedSubjects = 0;
    int failedSubjects = 0;
    int incompleteSubjects = 0;
    
    for (var mark in studentMarks) {
      if (mark.mark != null && mark.subject.value != null) {
        final percentage = (mark.mark! / mark.subject.value!.maxMark) * 100;
        if (percentage >= 50) {
          passedSubjects++;
        } else if (percentage >= 40) {
          incompleteSubjects++;
        } else if (mark.mark! > 0) {
          failedSubjects++;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'ملخص الدرجات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSummaryItem(
                  'عدد المواد',
                  studentMarks.length.toString(),
                  Icons.subject,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'المعدل العام',
                  average > 0 ? '${average.toStringAsFixed(1)}%' : '-',
                  Icons.calculate,
                  Colors.purple,
                ),
                _buildSummaryItem(
                  'حالة الطالب',
                  status,
                  Icons.school,
                  statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSummaryItem(
                  'مواد ناجحة',
                  passedSubjects.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildSummaryItem(
                  'مواد مكملة',
                  incompleteSubjects.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'مواد راسبة',
                  failedSubjects.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTable() {
    final studentMarks = _getStudentMarks();
    
    if (studentMarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد درجات مسجلة لهذا الطالب',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.grade, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'تفاصيل الدرجات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.grey[300]!),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue[50]),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'المادة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'الدرجة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'من المجموع',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'الحالة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ...studentMarks.map((mark) => _buildGradeRow(mark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildGradeRow(SubjectMark mark) {
    final subjectName = mark.subject.value?.name ?? 'غير محدد';
    final grade = mark.mark ?? 0.0;
    final maxMark = mark.subject.value?.maxMark ?? 100.0;
    final percentage = grade > 0 ? (grade / maxMark) * 100 : 0.0;
    final status = percentage >= 50 ? 'ناجح' : percentage >= 40 ? 'مكمل' : grade > 0 ? 'راسب' : 'غير مقيم';
    final statusColor = percentage >= 50 ? Colors.green : percentage >= 40 ? Colors.orange : grade > 0 ? Colors.red : Colors.grey;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            subjectName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            grade > 0 ? grade.toStringAsFixed(1) : '-',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: grade > 0 ? Colors.black : Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            grade > 0 ? '${grade.toStringAsFixed(1)}/${maxMark.toStringAsFixed(0)}' : '-',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: grade > 0 ? Colors.blue[700] : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generatePrintableCertificate() async {
    if (selectedStudent == null) return;

    try {
      final pdf = pw.Document();
      final arabicFont =pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
      final arabicBoldFont = await PdfGoogleFonts.amiriBold();
      
      final studentMarks = _getStudentMarks();
      final average = _calculateAverage();
      final status = _getStudentStatus();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue200),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'شهادة درجات الطالب',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 24,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'للعام الدراسي $selectedAcademicYear - تقييم $selectedEvaluationType',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 14,
                          color: PdfColors.blue600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Student Info
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'معلومات الطالب',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'الاسم: ${selectedStudent!.fullName}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 12),
                          ),
                          pw.Text(
                            'الصف: ${selectedStudent!.schoolclass.value?.name ?? 'غير محدد'}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Grades Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'المادة',
                            style: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'الدرجة',
                            style: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'الحالة',
                            style: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Grades
                    ...studentMarks.map(
                      (mark) {
                        final maxMark = mark.subject.value?.maxMark ?? 100.0;
                        final percentage = mark.mark != null ? (mark.mark! / maxMark) * 100 : 0.0;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                mark.subject.value?.name ?? 'غير محدد',
                                style: pw.TextStyle(font: arabicFont, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                mark.mark != null ? '${mark.mark!.toStringAsFixed(1)}/${maxMark.toStringAsFixed(0)}' : '-',
                                style: pw.TextStyle(font: arabicFont, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                percentage >= 50 ? 'ناجح' : percentage >= 40 ? 'مكمل' : mark.mark != null && mark.mark! > 0 ? 'راسب' : 'غير مقيم',
                                style: pw.TextStyle(font: arabicFont, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Summary
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green200),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'ملخص النتائج',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 16,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          pw.Text(
                            'عدد المواد: ${studentMarks.length}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 12),
                          ),
                          pw.Text(
                            'المعدل العام: ${average.toStringAsFixed(1)}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 12),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          pw.Text(
                            'المواد الناجحة: ${studentMarks.where((mark) {
                              if (mark.mark == null || mark.subject.value == null) return false;
                              final percentage = (mark.mark! / mark.subject.value!.maxMark) * 100;
                              return percentage >= 50;
                            }).length}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 12),
                          ),
                          pw.Text(
                            'المواد المكملة: ${studentMarks.where((mark) {
                              if (mark.mark == null || mark.subject.value == null) return false;
                              final percentage = (mark.mark! / mark.subject.value!.maxMark) * 100;
                              return percentage >= 40 && percentage < 50;
                            }).length}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 12),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: status == 'ناجح' ? PdfColors.green100 : 
                                 status == 'مكمل' ? PdfColors.orange100 : PdfColors.red100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Text(
                          'حالة الطالب: $status',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 14,
                            color: status == 'ناجح' ? PdfColors.green800 : 
                                   status == 'مكمل' ? PdfColors.orange800 : PdfColors.red800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                
                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 1,
                        width: 200,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'تم إنشاء هذه الشهادة في ${DateTime.now().toString().split(' ')[0]}',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'نظام إدارة المدارس',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'شهادة_درجات_${selectedStudent!.fullName}_${selectedAcademicYear}',
      );

      _showSuccessMessage('تم إنشاء الشهادة بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في إنشاء الشهادة: $e');
    }
  }

  Future<void> _exportStudentToExcel() async {
    if (selectedStudent == null) return;
    
    try {
      // إنشاء ملف Excel جديد
      final excelFile = excel.Excel.createExcel();
      
      // تعيين اسم الصفحة
      excelFile.rename('Sheet1', 'درجات ${selectedStudent!.fullName}');
      final sheet = excelFile['درجات ${selectedStudent!.fullName}'];
      
      // معلومات الطالب
      final studentInfo = [
        ['معلومات الطالب', ''],
        ['الاسم', selectedStudent!.fullName],
        ['الصف', selectedStudent!.schoolclass.value?.name ?? 'غير محدد'],
        ['السنة الدراسية', selectedAcademicYear],
        ['نوع التقييم', selectedEvaluationType],
        ['تاريخ التقرير', DateTime.now().toString().split(' ')[0]],
        ['', ''], // مسافة فارغة
      ];
      
      // إضافة معلومات الطالب
      int currentRow = 0;
      for (final info in studentInfo) {
        for (int col = 0; col < info.length; col++) {
          final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow));
          cell.value = excel.TextCellValue(info[col]);
          
          // تنسيق العناوين
          if (currentRow == 0 || (info[0].isNotEmpty && col == 0)) {
            cell.cellStyle = excel.CellStyle(bold: true);
          }
        }
        currentRow++;
      }
      
      // رؤوس جدول الدرجات
      final gradeHeaders = ['المادة', 'الدرجة', 'الدرجة الكاملة', 'النسبة المئوية', 'الحالة'];
      for (int i = 0; i < gradeHeaders.length; i++) {
        final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
        cell.value = excel.TextCellValue(gradeHeaders[i]);
        cell.cellStyle = excel.CellStyle(bold: true);
      }
      currentRow++;
      
      // جلب درجات الطالب
      final studentMarks = _getStudentMarks();
      
      // حساب المتوسط والإحصائيات
      double totalMarks = 0;
      double totalMaxMarks = 0;
      int passedSubjects = 0;
      int failedSubjects = 0;
      
      // إضافة الدرجات
      for (final mark in studentMarks) {
        await mark.subject.load();
        final subject = mark.subject.value;
        
        if (subject != null && mark.mark != null) {
          final percentage = (mark.mark! / subject.maxMark * 100);
          final status = percentage >= 50 ? 'نجح' : 'راسب';
          
          if (percentage >= 50) {
            passedSubjects++;
          } else {
            failedSubjects++;
          }
          
          totalMarks += mark.mark!;
          totalMaxMarks += subject.maxMark;
          
          final rowData = [
            subject.name,
            mark.mark!.toString(),
            subject.maxMark.toString(),
            '${percentage.toStringAsFixed(2)}%',
            status,
          ];
          
          for (int i = 0; i < rowData.length; i++) {
            final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            cell.value = excel.TextCellValue(rowData[i]);
          }
          currentRow++;
        }
      }
      
      // إضافة الإحصائيات
      currentRow += 2; // مسافة فارغة
      
      final overallPercentage = totalMaxMarks > 0 ? (totalMarks / totalMaxMarks * 100) : 0;
      final overallStatus = overallPercentage >= 50 ? 'نجح' : 'راسب';
      
      final statistics = [
        ['الإحصائيات النهائية', ''],
        ['إجمالي الدرجات', totalMarks.toStringAsFixed(2)],
        ['إجمالي الدرجات الكاملة', totalMaxMarks.toStringAsFixed(2)],
        ['المعدل العام', '${overallPercentage.toStringAsFixed(2)}%'],
        ['الحالة العامة', overallStatus],
        ['المواد المجتازة', passedSubjects.toString()],
        ['المواد الراسبة', failedSubjects.toString()],
        ['إجمالي المواد', studentMarks.length.toString()],
      ];
      
      for (final stat in statistics) {
        for (int col = 0; col < stat.length; col++) {
          final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow));
          cell.value = excel.TextCellValue(stat[col]);
          
          // تنسيق العناوين
          if (stat[0] == 'الإحصائيات النهائية' || col == 0) {
            cell.cellStyle = excel.CellStyle(bold: true);
          }
        }
        currentRow++;
      }
      
      // تعديل عرض الأعمدة
      for (int i = 0; i < 5; i++) {
        sheet.setColumnWidth(i, 20.0);
      }
      
      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'درجات_${selectedStudent!.fullName}_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(excelFile.save()!);
      
      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير درجات ${selectedStudent!.fullName} بنجاح'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'موافق',
              onPressed: () {},
            ),
          ),
        );
      }
      
    } catch (e) {
      // إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التصدير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
