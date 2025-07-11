import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../main.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_fee_status.dart';

class StudentPaymentStatusReport extends StatefulWidget {
  const StudentPaymentStatusReport({super.key});

  @override
  State<StudentPaymentStatusReport> createState() => _StudentPaymentStatusReportState();
}

class _StudentPaymentStatusReportState extends State<StudentPaymentStatusReport> {
  final formatter = NumberFormat('#,###');
  bool isLoading = true;
  
  // قوائم الطلاب حسب الحالة
  List<StudentWithStatus> latePaymentStudents = [];
  List<StudentWithStatus> fullyPaidStudents = [];
  List<StudentWithStatus> upcomingDueStudents = [];
  
  // فلاتر
  String? selectedAcademicYear;
  String? selectedClass;
  List<String> academicYears = [];
  List<String> classes = [];
  
  // إحصائيات
  int totalLateStudents = 0;
  int totalFullyPaidStudents = 0;
  int totalUpcomingDueStudents = 0;
  double totalLateAmount = 0;
  double totalPaidAmount = 0;
  double totalUpcomingAmount = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    
    await loadFilters();
    await loadStudentReports();
    
    setState(() => isLoading = false);
  }

  Future<void> loadFilters() async {
    // جلب السنوات الدراسية
    final feeStatuses = await isar.studentFeeStatus.where().findAll();
    academicYears = feeStatuses
        .map((fs) => fs.academicYear)
        .toSet()
        .toList()
        ..sort((a, b) => b.compareTo(a));
    
    // تعيين السنة الحالية كافتراضي
    if (academicYears.isNotEmpty && selectedAcademicYear == null) {
      selectedAcademicYear = academicYear.isNotEmpty ? academicYear : academicYears.first;
    }
    
    // جلب الصفوف للسنة المختارة
    if (selectedAcademicYear != null) {
      final classesSet = feeStatuses
          .where((fs) => fs.academicYear == selectedAcademicYear)
          .map((fs) => fs.className)
          .toSet()
          .toList();
      classes = classesSet..sort();
    }
  }

  Future<void> loadStudentReports() async {
    if (selectedAcademicYear == null) return;
    
    // استعلام قاعدة البيانات
    var query = isar.studentFeeStatus
        .filter()
        .academicYearEqualTo(selectedAcademicYear!);
    
    if (selectedClass != null) {
      query = query.classNameEqualTo(selectedClass!);
    }
    
    final feeStatuses = await query.findAll();
    
    // جلب بيانات الطلاب
    final studentsWithStatus = <StudentWithStatus>[];
    
    for (var feeStatus in feeStatuses) {
      await feeStatus.student.load();
      if (feeStatus.student.value != null) {
        studentsWithStatus.add(StudentWithStatus(
          student: feeStatus.student.value!,
          feeStatus: feeStatus,
        ));
      }
    }
    
    // تصنيف الطلاب
    classifyStudents(studentsWithStatus);
    calculateStatistics();
  }

  void classifyStudents(List<StudentWithStatus> students) {
    latePaymentStudents.clear();
    fullyPaidStudents.clear();
    upcomingDueStudents.clear();
    
    final now = DateTime.now();
    
    for (var studentWithStatus in students) {
      final feeStatus = studentWithStatus.feeStatus;
      final remainingAmount = (feeStatus.annualFee - feeStatus.discountAmount) - feeStatus.paidAmount;
      
      // الطلاب المتأخرين في الدفع
      if (feeStatus.nextDueDate != null && 
          feeStatus.nextDueDate!.isBefore(now) && 
          remainingAmount > 0) {
        latePaymentStudents.add(studentWithStatus);
      }
      // الطلاب الذين دفعوا كامل المبلغ
      else if (remainingAmount <= 0) {
        fullyPaidStudents.add(studentWithStatus);
      }
      // الطلاب الذين يقترب موعد استحقاقهم (خلال 7 أيام)
      else if (feeStatus.nextDueDate != null && 
               feeStatus.nextDueDate!.isAfter(now) &&
               feeStatus.nextDueDate!.difference(now).inDays <= 7 &&
               remainingAmount > 0) {
        upcomingDueStudents.add(studentWithStatus);
      }
    }
    
    // ترتيب حسب التاريخ أو المبلغ
    latePaymentStudents.sort((a, b) => a.feeStatus.nextDueDate?.compareTo(b.feeStatus.nextDueDate ?? DateTime.now()) ?? 0);
    upcomingDueStudents.sort((a, b) => a.feeStatus.nextDueDate?.compareTo(b.feeStatus.nextDueDate ?? DateTime.now()) ?? 0);
  }

  void calculateStatistics() {
    totalLateStudents = latePaymentStudents.length;
    totalFullyPaidStudents = fullyPaidStudents.length;
    totalUpcomingDueStudents = upcomingDueStudents.length;
    
    totalLateAmount = latePaymentStudents.fold(0.0, (sum, s) => 
        sum + ((s.feeStatus.annualFee - s.feeStatus.discountAmount) - s.feeStatus.paidAmount));
    
    totalPaidAmount = fullyPaidStudents.fold(0.0, (sum, s) => 
        sum + s.feeStatus.paidAmount);
    
    totalUpcomingAmount = upcomingDueStudents.fold(0.0, (sum, s) => 
        sum + ((s.feeStatus.annualFee - s.feeStatus.discountAmount) - s.feeStatus.paidAmount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير حالة دفع الطلاب'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
            tooltip: 'طباعة التقرير',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                _buildStatistics(),
                Expanded(child: _buildReportTabs()),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedAcademicYear,
              decoration: const InputDecoration(
                labelText: 'السنة الدراسية',
                border: OutlineInputBorder(),
              ),
              items: academicYears.map((year) {
                return DropdownMenuItem(value: year, child: Text(year));
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  selectedAcademicYear = value;
                  selectedClass = null;
                });
                await loadData();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: const InputDecoration(
                labelText: 'الصف (اختياري)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('جميع الصفوف')),
                ...classes.map((className) {
                  return DropdownMenuItem(value: className, child: Text(className));
                }).toList(),
              ],
              onChanged: (value) async {
                setState(() => selectedClass = value);
                await loadStudentReports();
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'المتأخرين',
              totalLateStudents.toString(),
              '${formatter.format(totalLateAmount)} د.ع',
              Colors.red,
              Icons.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'مكتملي الدفع',
              totalFullyPaidStudents.toString(),
              '${formatter.format(totalPaidAmount)} د.ع',
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'قرب الاستحقاق',
              totalUpcomingDueStudents.toString(),
              '${formatter.format(totalUpcomingAmount)} د.ع',
              Colors.orange,
              Icons.schedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(
                text: 'المتأخرين (${totalLateStudents})',
                icon: const Icon(Icons.warning, size: 16),
              ),
              Tab(
                text: 'مكتملي الدفع (${totalFullyPaidStudents})',
                icon: const Icon(Icons.check_circle, size: 16),
              ),
              Tab(
                text: 'قرب الاستحقاق (${totalUpcomingDueStudents})',
                icon: const Icon(Icons.schedule, size: 16),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStudentList(latePaymentStudents, StudentListType.late),
                _buildStudentList(fullyPaidStudents, StudentListType.fullyPaid),
                _buildStudentList(upcomingDueStudents, StudentListType.upcoming),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<StudentWithStatus> students, StudentListType type) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == StudentListType.late ? Icons.warning :
              type == StudentListType.fullyPaid ? Icons.check_circle :
              Icons.schedule,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              type == StudentListType.late ? 'لا يوجد طلاب متأخرين' :
              type == StudentListType.fullyPaid ? 'لا يوجد طلاب مكتملي الدفع' :
              'لا يوجد طلاب قرب الاستحقاق',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        return _buildStudentCard(students[index], type);
      },
    );
  }

  Widget _buildStudentCard(StudentWithStatus studentWithStatus, StudentListType type) {
    final student = studentWithStatus.student;
    final feeStatus = studentWithStatus.feeStatus;
    final remainingAmount = (feeStatus.annualFee - feeStatus.discountAmount) - feeStatus.paidAmount;
    
    Color cardColor;
    Color textColor;
    IconData icon;
    
    switch (type) {
      case StudentListType.late:
        cardColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.warning;
        break;
      case StudentListType.fullyPaid:
        cardColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case StudentListType.upcoming:
        cardColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.schedule;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الصف: ${feeStatus.className}',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                if (type != StudentListType.fullyPaid) ...[
                  const SizedBox(height: 4),
                  Text(
                    'المبلغ المتبقي: ${formatter.format(remainingAmount)} د.ع',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
                if (feeStatus.nextDueDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    type == StudentListType.late 
                        ? 'متأخر منذ: ${DateFormat('yyyy/MM/dd').format(feeStatus.nextDueDate!)}'
                        : 'تاريخ الاستحقاق: ${DateFormat('yyyy/MM/dd').format(feeStatus.nextDueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (type == StudentListType.fullyPaid)
            Text(
              '${formatter.format(feeStatus.paidAmount)} د.ع',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _printReport() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'تقرير حالة دفع الطلاب',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Text(
                'السنة الدراسية: ${selectedAcademicYear ?? "غير محدد"}\n'
                'الصف: ${selectedClass ?? "جميع الصفوف"}\n'
                'تاريخ التقرير: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            
            // إحصائيات
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text('المتأخرين: $totalLateStudents', textDirection: pw.TextDirection.rtl),
                  pw.Text('مكتملي الدفع: $totalFullyPaidStudents', textDirection: pw.TextDirection.rtl),
                  pw.Text('قرب الاستحقاق: $totalUpcomingDueStudents', textDirection: pw.TextDirection.rtl),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // جدول الطلاب المتأخرين
            if (latePaymentStudents.isNotEmpty) ...[
              pw.Text(
                'الطلاب المتأخرين في الدفع',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 10),
              _buildPdfTable(latePaymentStudents, StudentListType.late),
              pw.SizedBox(height: 20),
            ],
            
            // جدول الطلاب مكتملي الدفع
            if (fullyPaidStudents.isNotEmpty) ...[
              pw.Text(
                'الطلاب مكتملي الدفع',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 10),
              _buildPdfTable(fullyPaidStudents, StudentListType.fullyPaid),
              pw.SizedBox(height: 20),
            ],
            
            // جدول الطلاب قرب الاستحقاق
            if (upcomingDueStudents.isNotEmpty) ...[
              pw.Text(
                'الطلاب قرب موعد الاستحقاق',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 10),
              _buildPdfTable(upcomingDueStudents, StudentListType.upcoming),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfTable(List<StudentWithStatus> students, StudentListType type) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildPdfCell('اسم الطالب', isHeader: true),
            _buildPdfCell('الصف', isHeader: true),
            if (type != StudentListType.fullyPaid)
              _buildPdfCell('المبلغ المتبقي', isHeader: true),
            if (type == StudentListType.fullyPaid)
              _buildPdfCell('المبلغ المدفوع', isHeader: true),
            _buildPdfCell('تاريخ الاستحقاق', isHeader: true),
          ],
        ),
        // Data rows
        ...students.map((studentWithStatus) {
          final student = studentWithStatus.student;
          final feeStatus = studentWithStatus.feeStatus;
          final remainingAmount = (feeStatus.annualFee - feeStatus.discountAmount) - feeStatus.paidAmount;
          
          return pw.TableRow(
            children: [
              _buildPdfCell(student.fullName),
              _buildPdfCell(feeStatus.className),
              if (type != StudentListType.fullyPaid)
                _buildPdfCell('${formatter.format(remainingAmount)} د.ع'),
              if (type == StudentListType.fullyPaid)
                _buildPdfCell('${formatter.format(feeStatus.paidAmount)} د.ع'),
              _buildPdfCell(
                feeStatus.nextDueDate != null 
                    ? DateFormat('yyyy/MM/dd').format(feeStatus.nextDueDate!)
                    : 'غير محدد'
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}

// مساعدات
class StudentWithStatus {
  final Student student;
  final StudentFeeStatus feeStatus;

  StudentWithStatus({
    required this.student,
    required this.feeStatus,
  });
}

enum StudentListType {
  late,
  fullyPaid,
  upcoming,
}
