import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../main.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_fee_status.dart';
import '../helpers/program_info.dart';

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
          ProgramInfo.buildInfoButton(context),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveReportAsPdf,
            tooltip: 'حفظ التقرير كملف PDF',
          ),
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
      bottomNavigationBar: ProgramInfo.buildCopyrightFooter(),
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

  // حفظ التقرير كملف PDF
  Future<void> _saveReportAsPdf() async {
    try {
      final pdf = await _generatePdfDocument();
      final fileName = 'تقرير_حالة_دفع_الطلاب_${DateFormat('yyyy_MM_dd_HH_mm').format(DateTime.now())}.pdf';
      
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: fileName,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التقرير بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ التقرير: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // طباعة التقرير
  Future<void> _printReport() async {
    try {
      final pdf = await _generatePdfDocument();
      final fileName = 'تقرير_حالة_دفع_الطلاب_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf';
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في طباعة التقرير: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // إنشاء مستند PDF (مشترك بين الطباعة والحفظ)
  Future<pw.Document> _generatePdfDocument() async {
    // تحميل الخط العربي
    final arabicFont = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final arabicBoldFont = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final ttfArabic = pw.Font.ttf(arabicFont);
    final ttfArabicBold = pw.Font.ttf(arabicBoldFont);
    
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: ttfArabic,
          bold: ttfArabicBold,
        ),
        build: (pw.Context context) {
          return [
            // علامة مائية في الخلفية
            pw.Positioned.fill(
              child: pw.Center(
                child: pw.Transform.rotate(
                  angle: -0.5,
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Text(
                      'نظام إدارة المدارس الذكي\nSmart School Management System',
                      style: pw.TextStyle(
                        fontSize: 48,
                        fontWeight: pw.FontWeight.bold,
                        font: ttfArabicBold,
                        color: PdfColors.grey600,
                      ),
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            
            // عنوان التقرير مع شعار البرنامج
            pw.Container(
              alignment: pw.Alignment.center,
              margin: const pw.EdgeInsets.only(bottom: 30),
              child: pw.Column(
                children: [
                  // شعار أو علامة البرنامج
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo50,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: PdfColors.indigo200),
                    ),
                    child: pw.Text(
                      '🏫 نظام إدارة المدارس الذكي',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttfArabicBold,
                        color: PdfColors.indigo800,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    'تقرير حالة دفع الطلاب',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: ttfArabicBold,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    height: 3,
                    width: 200,
                    color: PdfColors.indigo,
                  ),
                ],
              ),
            ),
            
            // معلومات التقرير
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              margin: const pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey100,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'معلومات التقرير',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      font: ttfArabicBold,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'السنة الدراسية: ${selectedAcademicYear ?? "غير محدد"}',
                        style: pw.TextStyle(fontSize: 12, font: ttfArabic),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'الصف: ${selectedClass ?? "جميع الصفوف"}',
                        style: pw.TextStyle(fontSize: 12, font: ttfArabic),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        'تاريخ التقرير: ${DateFormat('yyyy/MM/dd', 'ar').format(DateTime.now())}',
                        style: pw.TextStyle(fontSize: 12, font: ttfArabic),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // الإحصائيات المحسنة
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 25),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPdfStatCard(
                    'الطلاب المتأخرين',
                    totalLateStudents.toString(),
                    '${formatter.format(totalLateAmount)} د.ع',
                    PdfColors.red,
                    ttfArabic,
                    ttfArabicBold,
                  ),
                  _buildPdfStatCard(
                    'مكتملي الدفع',
                    totalFullyPaidStudents.toString(),
                    '${formatter.format(totalPaidAmount)} د.ع',
                    PdfColors.green,
                    ttfArabic,
                    ttfArabicBold,
                  ),
                  _buildPdfStatCard(
                    'قرب الاستحقاق',
                    totalUpcomingDueStudents.toString(),
                    '${formatter.format(totalUpcomingAmount)} د.ع',
                    PdfColors.orange,
                    ttfArabic,
                    ttfArabicBold,
                  ),
                ],
              ),
            ),
            
            // جدول الطلاب المتأخرين
            if (latePaymentStudents.isNotEmpty) ...[
              _buildPdfSectionHeader(
                'الطلاب المتأخرين في الدفع (${latePaymentStudents.length})',
                PdfColors.red,
                ttfArabicBold,
              ),
              pw.SizedBox(height: 10),
              _buildPdfTable(latePaymentStudents, StudentListType.late, ttfArabic, ttfArabicBold),
              pw.SizedBox(height: 25),
            ],
            
            // جدول الطلاب مكتملي الدفع
            if (fullyPaidStudents.isNotEmpty) ...[
              _buildPdfSectionHeader(
                'الطلاب مكتملي الدفع (${fullyPaidStudents.length})',
                PdfColors.green,
                ttfArabicBold,
              ),
              pw.SizedBox(height: 10),
              _buildPdfTable(fullyPaidStudents, StudentListType.fullyPaid, ttfArabic, ttfArabicBold),
              pw.SizedBox(height: 25),
            ],
            
            // جدول الطلاب قرب الاستحقاق
            if (upcomingDueStudents.isNotEmpty) ...[
              _buildPdfSectionHeader(
                'الطلاب قرب موعد الاستحقاق (${upcomingDueStudents.length})',
                PdfColors.orange,
                ttfArabicBold,
              ),
              pw.SizedBox(height: 10),
              _buildPdfTable(upcomingDueStudents, StudentListType.upcoming, ttfArabic, ttfArabicBold),
            ],
            
            // التوقيع والختم
            pw.SizedBox(height: 40),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'إعداد التقرير:',
                      style: pw.TextStyle(fontSize: 12, font: ttfArabic),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: 100,
                      height: 1,
                      color: PdfColors.black,
                    ),
                    pw.Text(
                      'المسؤول المالي',
                      style: pw.TextStyle(fontSize: 10, font: ttfArabic),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'اعتماد التقرير:',
                      style: pw.TextStyle(fontSize: 12, font: ttfArabic),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: 100,
                      height: 1,
                      color: PdfColors.black,
                    ),
                    pw.Text(
                      'مدير المدرسة',
                      style: pw.TextStyle(fontSize: 10, font: ttfArabic),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // حقوق البرنامج
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      'تم إنشاء هذا التقرير بواسطة نظام إدارة المدارس',
                      style: pw.TextStyle(fontSize: 8, font: ttfArabic, color: PdfColors.grey600),
                      textDirection: pw.TextDirection.rtl,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '© ${DateTime.now().year} جميع الحقوق محفوظة - نظام إدارة المدارس الذكي',
                      style: pw.TextStyle(fontSize: 7, font: ttfArabic, color: PdfColors.grey500),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ],
                ),
                // رقم الصفحة
                pw.Text(
                  'صفحة ${context.pageNumber} من ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 10, font: ttfArabic),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          );
        },
      ),
    );
    
    return pdf;
  }

  // إنشاء بطاقة إحصائية للـ PDF
  pw.Widget _buildPdfStatCard(
    String title,
    String count,
    String amount,
    PdfColor color,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
              color: color,
            ),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            count,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
              color: color,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: 10,
              font: font,
              color: color,
            ),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // إنشاء عنوان القسم
  pw.Widget _buildPdfSectionHeader(String title, PdfColor color, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        border: pw.Border(
          right: pw.BorderSide(color: color, width: 4),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          font: boldFont,
          color: color,
        ),
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  pw.Widget _buildPdfTable(List<StudentWithStatus> students, StudentListType type, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // اسم الطالب
        1: const pw.FlexColumnWidth(2), // الصف
        2: const pw.FlexColumnWidth(2), // المبلغ
        3: const pw.FlexColumnWidth(2), // التاريخ
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: type == StudentListType.late ? PdfColors.red.shade(0.2) :
                   type == StudentListType.fullyPaid ? PdfColors.green.shade(0.2) :
                   PdfColors.orange.shade(0.2),
          ),
          children: [
            _buildPdfCell('اسم الطالب', isHeader: true, font: boldFont),
            _buildPdfCell('الصف', isHeader: true, font: boldFont),
            if (type != StudentListType.fullyPaid)
              _buildPdfCell('المبلغ المتبقي', isHeader: true, font: boldFont),
            if (type == StudentListType.fullyPaid)
              _buildPdfCell('المبلغ المدفوع', isHeader: true, font: boldFont),
            _buildPdfCell('تاريخ الاستحقاق', isHeader: true, font: boldFont),
          ],
        ),
        // Data rows
        ...students.asMap().entries.map((entry) {
          final index = entry.key;
          final studentWithStatus = entry.value;
          final student = studentWithStatus.student;
          final feeStatus = studentWithStatus.feeStatus;
          final remainingAmount = (feeStatus.annualFee - feeStatus.discountAmount) - feeStatus.paidAmount;
          
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
            ),
            children: [
              _buildPdfCell(student.fullName, font: font),
              _buildPdfCell(feeStatus.className, font: font),
              if (type != StudentListType.fullyPaid)
                _buildPdfCell('${formatter.format(remainingAmount)} د.ع', font: font),
              if (type == StudentListType.fullyPaid)
                _buildPdfCell('${formatter.format(feeStatus.paidAmount)} د.ع', font: font),
              _buildPdfCell(
                feeStatus.nextDueDate != null 
                    ? DateFormat('yyyy/MM/dd', 'ar').format(feeStatus.nextDueDate!)
                    : 'غير محدد',
                font: font,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPdfCell(String text, {bool isHeader = false, required pw.Font font}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: font,
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
