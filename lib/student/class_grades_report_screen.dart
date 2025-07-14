import 'package:flutter/material.dart';
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

class ClassGradesReportScreen extends StatefulWidget {
  const ClassGradesReportScreen({Key? key}) : super(key: key);

  @override
  State<ClassGradesReportScreen> createState() => _ClassGradesReportScreenState();
}

class _ClassGradesReportScreenState extends State<ClassGradesReportScreen> {
  List<Student> students = [];
  List<Subject> subjects = [];
  List<SubjectMark> marks = [];
  List<SchoolClass> classes = [];
  
  SchoolClass? selectedClass;
  String selectedEvaluationType = 'نهائي';
  String selectedAcademicYear =academicYear;
  
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

  List<Student> get classStudents {
    if (selectedClass == null) return [];
    return students.where((student) => 
      student.schoolclass.value?.id == selectedClass!.id
    ).toList();
  }

  List<Subject> get classSubjects {
    if (selectedClass == null) return [];
    return subjects.where((subject) => 
      subject.schoolClass.value?.id == selectedClass!.id
    ).toList();
  }

  List<SubjectMark> _getStudentMarksForSubject(Student student, Subject subject) {
    return marks.where((mark) =>
      mark.student.value?.id == student.id &&
      mark.subject.value?.id == subject.id &&
      mark.evaluationType == selectedEvaluationType &&
      mark.academicYear == selectedAcademicYear
    ).toList();
  }

  double _calculateStudentAverage(Student student) {
    final studentSubjects = classSubjects;
    if (studentSubjects.isEmpty) return 0.0;
    
    double totalPercentage = 0.0;
    int validMarksCount = 0;
    
    for (var subject in studentSubjects) {
      final studentMarks = _getStudentMarksForSubject(student, subject);
      if (studentMarks.isNotEmpty && studentMarks.first.mark != null) {
        final percentage = (studentMarks.first.mark! / subject.maxMark) * 100;
        totalPercentage += percentage;
        validMarksCount++;
      }
    }
    
    return validMarksCount > 0 ? totalPercentage / validMarksCount : 0.0;
  }

  String _getStudentStatus(Student student) {
    final average = _calculateStudentAverage(student);
    final studentSubjects = classSubjects;
    
    if (studentSubjects.isEmpty || average == 0.0) return 'غير مقيم';
    
    int failedSubjects = 0;
    int incompleteSubjects = 0;
    
    for (var subject in studentSubjects) {
      final studentMarks = _getStudentMarksForSubject(student, subject);
      if (studentMarks.isNotEmpty && studentMarks.first.mark != null) {
        final percentage = (studentMarks.first.mark! / subject.maxMark) * 100;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير درجات الصف'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (selectedClass != null && classStudents.isNotEmpty)
            IconButton(
              onPressed: () => _exportClassToExcel(),
              icon: const Icon(Icons.file_download),
              tooltip: 'تصدير إلى Excel',
            ),
          if (selectedClass != null && classStudents.isNotEmpty)
            IconButton(
              onPressed: () => _printClassReport(),
              icon: const Icon(Icons.print),
              tooltip: 'طباعة التقرير',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildFiltersCard(),
                  if (selectedClass != null && classStudents.isNotEmpty) ...[
                    _buildClassSummaryCard(),
                    _buildGradesTable(),
                  ] else if (selectedClass != null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'لا يوجد طلاب في هذا الصف',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'اختر صف لعرض درجات الطلاب',
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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<SchoolClass>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'الصف',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                    ),
                    items: [
                      const DropdownMenuItem<SchoolClass>(
                        value: null,
                        child: Text('اختر الصف'),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSummaryCard() {
    final students = classStudents;
    final subjects = classSubjects;
    
    int passedStudents = 0;
    int failedStudents = 0;
    int incompleteStudents = 0;
    double totalAverage = 0;
    
    for (var student in students) {
      final status = _getStudentStatus(student);
      final average = _calculateStudentAverage(student);
      
      switch (status) {
        case 'ناجح':
          passedStudents++;
          break;
        case 'راسب':
          failedStudents++;
          break;
        case 'مكمل':
          incompleteStudents++;
          break;
      }
      
      totalAverage += average;
    }
    
    final classAverage = students.isNotEmpty ? totalAverage / students.length : 0.0;

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
                Text(
                  'ملخص الصف: ${selectedClass?.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSummaryItem(
                  'عدد الطلاب',
                  students.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'عدد المواد',
                  subjects.length.toString(),
                  Icons.subject,
                  Colors.purple,
                ),
                _buildSummaryItem(
                  'متوسط الصف',
                  '${classAverage.toStringAsFixed(1)}%',
                  Icons.calculate,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'طلاب ناجحون',
                  passedStudents.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildSummaryItem(
                  'طلاب مكملون',
                  incompleteStudents.toString(),
                  Icons.pending,
                  Colors.amber,
                ),
                _buildSummaryItem(
                  'طلاب راسبون',
                  failedStudents.toString(),
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
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTable() {
    final students = classStudents;
    final subjects = classSubjects;
    
    if (students.isEmpty || subjects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'لا توجد بيانات لعرضها',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
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
                const Icon(Icons.table_chart, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'جدول درجات الصف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(color: Colors.grey[300]!),
              headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
              columns: [
                const DataColumn(
                  label: Text(
                    'الطالب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...subjects.map((subject) => DataColumn(
                  label: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )),
                const DataColumn(
                  label: Text(
                    'المعدل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: students.map((student) {
                final average = _calculateStudentAverage(student);
                final status = _getStudentStatus(student);
                final statusColor = status == 'ناجح' ? Colors.green : 
                                   status == 'مكمل' ? Colors.orange : Colors.red;
                
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        student.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...subjects.map((subject) {
                      final studentMarks = _getStudentMarksForSubject(student, subject);
                      final mark = studentMarks.isNotEmpty ? studentMarks.first.mark : null;
                      final percentage = mark != null ? (mark / subject.maxMark * 100) : 0.0;
                      
                      return DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: mark != null 
                              ? (percentage >= 50 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
                              : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            mark != null ? mark.toStringAsFixed(1) : '-',
                            style: TextStyle(
                              color: mark != null 
                                ? (percentage >= 50 ? Colors.green[700] : Colors.red[700])
                                : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                    DataCell(
                      Text(
                        average > 0 ? '${average.toStringAsFixed(1)}%' : '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: average >= 50 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportClassToExcel() async {
    if (selectedClass == null) return;
    
    try {
      final excelFile = excel.Excel.createExcel();
      final className = selectedClass!.name;
      
      excelFile.rename('Sheet1', 'درجات_$className');
      final sheet = excelFile['درجات_$className'];
      
      final students = classStudents;
      final subjects = classSubjects;
      
      // معلومات الصف
      final classInfo = [
        ['تقرير درجات الصف', ''],
        ['اسم الصف', className],
        ['نوع التقييم', selectedEvaluationType],
        ['السنة الدراسية', selectedAcademicYear],
        ['عدد الطلاب', students.length.toString()],
        ['عدد المواد', subjects.length.toString()],
        ['تاريخ التقرير', DateTime.now().toString().split(' ')[0]],
        ['', ''], // مسافة فارغة
      ];
      
      // إضافة معلومات الصف
      int currentRow = 0;
      for (final info in classInfo) {
        for (int col = 0; col < info.length; col++) {
          final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow));
          cell.value = excel.TextCellValue(info[col]);
          
          if (currentRow == 0 || (info[0].isNotEmpty && col == 0)) {
            cell.cellStyle = excel.CellStyle(bold: true);
          }
        }
        currentRow++;
      }
      
      // رؤوس جدول الدرجات
      final headers = ['الطالب', ...subjects.map((s) => s.name), 'المعدل', 'الحالة'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
        cell.value = excel.TextCellValue(headers[i]);
        cell.cellStyle = excel.CellStyle(bold: true);
      }
      currentRow++;
      
      // إضافة بيانات الطلاب
      for (final student in students) {
        final rowData = <String>[student.fullName];
        
        // إضافة درجات المواد
        for (final subject in subjects) {
          final studentMarks = _getStudentMarksForSubject(student, subject);
          final mark = studentMarks.isNotEmpty ? studentMarks.first.mark : null;
          rowData.add(mark?.toStringAsFixed(1) ?? '-');
        }
        
        // إضافة المعدل والحالة
        final average = _calculateStudentAverage(student);
        final status = _getStudentStatus(student);
        rowData.add(average > 0 ? '${average.toStringAsFixed(1)}%' : '-');
        rowData.add(status);
        
        for (int i = 0; i < rowData.length; i++) {
          final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
          cell.value = excel.TextCellValue(rowData[i]);
        }
        currentRow++;
      }
      
      // إضافة إحصائيات نهائية
      currentRow += 2;
      
      // حساب الإحصائيات
      int passedStudents = 0;
      int failedStudents = 0;
      int incompleteStudents = 0;
      double totalAverage = 0;
      
      for (var student in students) {
        final status = _getStudentStatus(student);
        final average = _calculateStudentAverage(student);
        
        switch (status) {
          case 'ناجح': passedStudents++; break;
          case 'راسب': failedStudents++; break;
          case 'مكمل': incompleteStudents++; break;
        }
        
        totalAverage += average;
      }
      
      final classAverage = students.isNotEmpty ? totalAverage / students.length : 0.0;
      
      final statistics = [
        ['إحصائيات الصف', ''],
        ['متوسط الصف العام', '${classAverage.toStringAsFixed(2)}%'],
        ['عدد الطلاب الناجحين', passedStudents.toString()],
        ['عدد الطلاب المكملين', incompleteStudents.toString()],
        ['عدد الطلاب الراسبين', failedStudents.toString()],
        ['معدل النجاح', students.isNotEmpty ? '${(passedStudents / students.length * 100).toStringAsFixed(1)}%' : '0%'],
      ];
      
      for (final stat in statistics) {
        for (int col = 0; col < stat.length; col++) {
          final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow));
          cell.value = excel.TextCellValue(stat[col]);
          
          if (stat[0] == 'إحصائيات الصف' || col == 0) {
            cell.cellStyle = excel.CellStyle(bold: true);
          }
        }
        currentRow++;
      }
      
      // تعديل عرض الأعمدة
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      
      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'درجات_صف_${className}_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(excelFile.save()!);
      
      if (mounted) {
        _showSuccessMessage('تم تصدير درجات صف $className بنجاح');
      }
      
    } catch (e) {
      if (mounted) {
        _showErrorMessage('حدث خطأ أثناء التصدير: $e');
      }
    }
  }

  Future<void> _printClassReport() async {
    if (selectedClass == null) return;

    try {
      final pdf = pw.Document();
      final arabicFont = await PdfGoogleFonts.amiriRegular();
      final arabicBoldFont = await PdfGoogleFonts.amiriBold();
      
      final students = classStudents;
      final subjects = classSubjects;
      final className = selectedClass!.name;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
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
                        'تقرير درجات صف $className',
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
                
                // Summary Stats
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('عدد الطلاب: ${students.length}', style: pw.TextStyle(font: arabicFont, fontSize: 12)),
                    pw.Text('عدد المواد: ${subjects.length}', style: pw.TextStyle(font: arabicFont, fontSize: 12)),
                    pw.Text('تاريخ التقرير: ${DateTime.now().toString().split(' ')[0]}', style: pw.TextStyle(font: arabicFont, fontSize: 12)),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Grades Table
                pw.Expanded(
                  child: pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'الطالب',
                              style: pw.TextStyle(font: arabicBoldFont, fontSize: 8),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          ...subjects.map((subject) => pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              subject.name,
                              style: pw.TextStyle(font: arabicBoldFont, fontSize: 7),
                              textAlign: pw.TextAlign.center,
                            ),
                          )),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'المعدل',
                              style: pw.TextStyle(font: arabicBoldFont, fontSize: 8),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              'الحالة',
                              style: pw.TextStyle(font: arabicBoldFont, fontSize: 8),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Student Rows
                      ...students.map((student) {
                        final average = _calculateStudentAverage(student);
                        final status = _getStudentStatus(student);
                        
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                student.fullName,
                                style: pw.TextStyle(font: arabicFont, fontSize: 7),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            ...subjects.map((subject) {
                              final studentMarks = _getStudentMarksForSubject(student, subject);
                              final mark = studentMarks.isNotEmpty ? studentMarks.first.mark : null;
                              
                              return pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  mark != null ? mark.toStringAsFixed(1) : '-',
                                  style: pw.TextStyle(font: arabicFont, fontSize: 7),
                                  textAlign: pw.TextAlign.center,
                                ),
                              );
                            }),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                average > 0 ? '${average.toStringAsFixed(1)}%' : '-',
                                style: pw.TextStyle(font: arabicFont, fontSize: 7),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                status,
                                style: pw.TextStyle(font: arabicFont, fontSize: 7),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Footer with stats
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Text(
                    'نظام إدارة المدارس - تم إنشاء هذا التقرير في ${DateTime.now().toString().split(' ')[0]}',
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'تقرير_درجات_صف_${className}_$selectedAcademicYear',
      );

      _showSuccessMessage('تم إنشاء تقرير الطباعة بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في إنشاء التقرير: $e');
    }
  }
}
