import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/school.dart';
import '../helpers/WhatsAppService.dart';
import '/localdatabase/student.dart';
import '/localdatabase/user.dart';
import '../localdatabase/log.dart';
import '../localdatabase/student_crud.dart';
import '../localdatabase/student_fee_status.dart';
import '../localdatabase/student_payment.dart';
import '../main.dart';
import '../dialogs/payment_dialog_ui.dart';
import '../helpers/auto_discount_helper.dart';
class StudentPaymentsScreen extends StatefulWidget {
  final int studentId;
  final String fullName;
  final Student? student;

  const StudentPaymentsScreen({super.key, required this.studentId, required this.fullName, this.student});

  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  List<StudentPayment> payments = [];
  StudentFeeStatus? feeStatus;
  bool isLoading = true;

  List<String> academicYears = [];
  String? selectedAcademicYear;

  final formatter = NumberFormat('#,###');
  String? schoolPhoneNumber;
 
 Future<void> getSchoolPhoneNumber() async {

 School? school= await isar.schools.where().findFirst();
    if (school != null) {
      schoolPhoneNumber = school.phone; // رقم هاتف المدرسة الافتراضي
    } else {
       // إذا لم يتم العثور على بيانات المدرسة، سيتم استخدام رقم هاتف افتراضي (مثال: '07800000000')
       schoolPhoneNumber = '07800000000'; // رقم هاتف المدرسة الافتراضي
      showDialog(
        context: context,
        builder: (context) {
          final phoneController = TextEditingController();
          return AlertDialog(
        title: const Text('إضافة رقم هاتف المدرسة'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: 'أدخل رقم هاتف المدرسة',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('حفظ'),
            onPressed: () async {
          final phone = phoneController.text.trim();
          if (phone.isNotEmpty) {
            await isar.writeTxn(() async {
              final newSchool = School()..phone = phone;
              await isar.schools.put(newSchool);
            });
            schoolPhoneNumber = phone;
          }
          Navigator.of(context).pop();
            },
          ),
        ],
          );
        },
      );
    }
  }



  @override
  void initState() {
    super.initState();
    loadAcademicYearsAndInit();
    getSchoolPhoneNumber();
  }
  Future<bool?> showEditPaymentDialogIsar({
    required BuildContext context,
    required StudentPayment payment,
    required String studentId,
    required String academicYear,
  }) async {
    final amountController = TextEditingController(text: payment.amount.toString());
    final receiptController = TextEditingController(text: payment.receiptNumber ?? '');
    final notesController = TextEditingController(text: payment.notes ?? '');
    DateTime paidAt = payment.paidAt;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الدفعة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                ),
                TextField(
                  controller: receiptController,
                  decoration: const InputDecoration(labelText: 'رقم الوصل'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('تاريخ الدفع: '),
                    TextButton(
                      child: Text('${paidAt.toLocal()}'.split(' ')[0]),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: paidAt,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          paidAt = picked;
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('حفظ'),
              onPressed: () async {
                final newAmount = double.tryParse(amountController.text) ?? 0;
                final oldAmount = payment.amount;

                payment.amount = newAmount;
                payment.receiptNumber = receiptController.text.trim().isEmpty ? null : receiptController.text.trim();
                payment.notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();
                payment.paidAt = paidAt;

                await isar.writeTxn(() async {
                  await isar.studentPayments.put(payment);

                  // تحديث حالة القسط
                  final feeStatus = await isar.studentFeeStatus
                      .filter()
                      .studentIdEqualTo(studentId)
                      .academicYearEqualTo(academicYear)
                      .findFirst();

                  if (feeStatus != null) {
                    // الفرق بين المبلغ الجديد والقديم
                    final diff = newAmount - oldAmount;
                    feeStatus.paidAmount = feeStatus.paidAmount + diff;
                    // التأكد من عدم تجاوز القيم المنطقية
                    if (feeStatus.paidAmount < 0) feeStatus.paidAmount = 0;
                    feeStatus.dueAmount = feeStatus.annualFee - feeStatus.paidAmount;
                    if (feeStatus.dueAmount! < 0) feeStatus.dueAmount = 0;
                    await isar.studentFeeStatus.put(feeStatus);
                  }
                });

                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> loadAcademicYearsAndInit() async {
    setState(() => isLoading = true);
    try {
      final yearsFromPayments = await isar.studentPayments
          .filter()
          .studentIdEqualTo(widget.studentId.toString())
          .findAll();
      final yearsFromFeeStatus = await isar.studentFeeStatus
          .filter()
          .studentIdEqualTo(widget.studentId.toString())
          .findAll();

      final yearsSet = <String>{};
      yearsSet.addAll(yearsFromPayments.map((e) => e.academicYear ?? 'غير معروف'));
      yearsSet.addAll(yearsFromFeeStatus.map((e) => e.academicYear));

      academicYears = yearsSet.where((y) => y.isNotEmpty).toList();
      academicYears.sort((a, b) => b.compareTo(a));

      selectedAcademicYear = academicYears.isNotEmpty ? academicYears.first : null;

      await reloadAllData();
    } catch (e) {
      debugPrint('Error loading academic years: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> reloadAllData() async {
    setState(() => isLoading = true);
    try {
      if (selectedAcademicYear == null) {
        payments = [];
        feeStatus = null;
      } else {
        payments = await isar.studentPayments
            .filter()
            .studentIdEqualTo(widget.studentId.toString())
            .academicYearEqualTo(selectedAcademicYear)
            .sortByPaidAtDesc()
            .findAll();

        feeStatus = await isar.studentFeeStatus
            .filter()
            .studentIdEqualTo(widget.studentId.toString())
            .academicYearEqualTo(selectedAcademicYear!)
            .findFirst();
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error during reloadAllData: $e');
    } finally {
      setState(() => isLoading = false);
    }
  } 
   void _sendPaymentToWhatsApp(StudentPayment payment) async {
    try {
      await WhatsAppService.sendPaymentDetails(
        schoolPhoneNumber:  "+964$schoolPhoneNumber",
        parentPhone: "+964${widget.student!.parentPhone}",
        studentName: "${widget.fullName}",
        amount: payment.amount.toDouble(),
        paymentType: payment.notes ?? 'دفعة',
        paymentDate: DateTime.parse(payment.paidAt.toString()),
      );
    } catch (e) {
      // معالجة الخطأ
      print('خطأ في إرسال الرسالة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (feeStatus == null || feeStatus!.dueAmount! <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا يمكن إضافة دفعة، القسط مدفوع بالكامل أو لا توجد حالة قسط')),
            );
            return;
          }
          final result = await showAddPaymentDialogIsar(
            context: context,
            studentId: widget.studentId.toString(),
            academicYear: selectedAcademicYear ?? academicYear, // استخدام السنة العامة عند عدم وجود سنة محلية
            student: widget.student!,
            isar: isar,
          );

          if (result == true) {
            await reloadAllData();
            
            // معالجة الخصومات التلقائية بعد إضافة الدفعة
            if (widget.student != null) {
              try {
                final processor = AutoDiscountProcessor(isar);
                final appliedDiscounts = await processor.processAllAutoDiscounts(
                  widget.student!, 
                  selectedAcademicYear ?? academicYear
                );
                
                if (appliedDiscounts.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تطبيق ${appliedDiscounts.length} خصم تلقائي'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  // إعادة تحميل البيانات لإظهار الخصومات الجديدة
                  await reloadAllData();
                }
              } catch (e) {
                debugPrint('خطأ في معالجة الخصومات التلقائية: $e');
              }
            }

            var user = await isar.users.where().findFirst();
            if (user != null) {
              final log = Log()
                ..action = 'اضافة دفعة'
                ..tableName = 'users'
                ..description = 'تم اضافة دفعة بواسطة ${user.username}'
                ..user.value = user;

              await isar.writeTxn(() async {
                await isar.logs.put(log);
                await log.user.save();
              });
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [                // إضافة معاينة سريعة للطالب
                _buildStudentQuickInfo(),
                  
                  if (academicYears.isNotEmpty)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'السنة الدراسية:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: DropdownButton<String>(
                                value: selectedAcademicYear,
                                underline: Container(),
                                items: academicYears
                                    .map((year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(
                                            year,
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) async {
                                  setState(() {
                                    selectedAcademicYear = value;
                                  });
                                  await reloadAllData();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (feeStatus != null)
                    Column(
                      children: [
                        // مؤشر الحالة السريع
                        _buildQuickStatusBadge(),
                        
                        // مؤشر الحالة المالية
                        _buildFinancialStatusIndicator(),
                        const SizedBox(height: 8),
                        
                        // إحصائيات سريعة
                        _buildQuickStats(),
                        const SizedBox(height: 8),
                        
                        // تفاصيل الخصومات
                        _buildDiscountDetails(),
                        const SizedBox(height: 8),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildStatCard('القسط السنوي', '${formatter.format(feeStatus!.annualFee)} د.ع', Colors.blue),
                            _buildStatCard('المدفوع', '${formatter.format(feeStatus!.paidAmount)} د.ع', Colors.green),
                            _buildStatCard('المتبقي', '${formatter.format(feeStatus!.dueAmount)} د.ع', Colors.red),
                            _buildStatCard('الخصم', '${formatter.format(feeStatus!.discountAmount)} د.ع', Colors.orangeAccent),
                            if (feeStatus!.transferredDebtAmount > 0)
                              _buildStatCard('دين منقول', '${formatter.format(feeStatus!.transferredDebtAmount)} د.ع', Colors.orange),
                          ],
                        ),
                        if (feeStatus!.transferredDebtAmount > 0 && feeStatus!.originalDebtAcademicYear != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'دين منقول من: ${feeStatus!.originalDebtAcademicYear} - ${feeStatus!.originalDebtClassName ?? ""}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (feeStatus == null)
                    const Text('لا توجد حالة قسط لهذه السنة', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  // أزرار الإدارة
                  if (feeStatus != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings, color: Colors.grey.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'أدوات الإدارة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildManagementButton(
                                'إدارة الخصومات',
                                Icons.discount,
                                Colors.green,
                                () {
                                  Navigator.pushNamed(
                                    context,
                                    '/student-discounts',
                                    arguments: {
                                      'student': widget.student,
                                      'academicYear': selectedAcademicYear,
                                    },
                                  );
                                },
                              ),
                              _buildManagementButton(
                                'طباعة التقرير',
                                Icons.print,
                                Colors.blue,
                                () => printStudentPayments(widget.student!, selectedAcademicYear!),
                              ),
                              if (feeStatus!.transferredDebtAmount > 0)
                                _buildManagementButton(
                                  'تاريخ الديون',
                                  Icons.history,
                                  Colors.orange,
                                  () => _showDebtHistory(),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'سجل الدفعات',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${payments.length} دفعة',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 140,
                            height: 32,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (feeStatus == null || feeStatus!.dueAmount! <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('لا يمكن إضافة دفعة، القسط مدفوع بالكامل')),
                                  );
                                  return;
                                }
                                final result = await showAddPaymentDialogIsar(
                                  context: context,
                                  studentId: widget.studentId.toString(),
                                  academicYear: selectedAcademicYear ?? academicYear,
                                  student: widget.student!,
                                  isar: isar,
                                );
                                if (result == true) {
                                  await reloadAllData();
                                  
                                  // معالجة الخصومات التلقائية بعد إضافة الدفعة
                                  if (widget.student != null) {
                                    try {
                                      final processor = AutoDiscountProcessor(isar);
                                      final appliedDiscounts = await processor.processAllAutoDiscounts(
                                        widget.student!, 
                                        selectedAcademicYear ?? academicYear
                                      );
                                      
                                      if (appliedDiscounts.isNotEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('تم تطبيق ${appliedDiscounts.length} خصم تلقائي'),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                        // إعادة تحميل البيانات لإظهار الخصومات الجديدة
                                        await reloadAllData();
                                      }
                                    } catch (e) {
                                      debugPrint('خطأ في معالجة الخصومات التلقائية: $e');
                                    }
                                  }
                                }
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('دفعة جديدة', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            height: 32,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => printStudentPayments(widget.student!, selectedAcademicYear!),
                              icon: const Icon(Icons.print, size: 16),
                              label: const Text('طباعة', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4, // ارتفاع ديناميكي بناءً على حجم الشاشة
                    child: payments.isEmpty
                        ? const Center(child: Text('لا توجد دفعات مسجلة'))
                        : ListView.builder(
                            itemCount: payments.length,
                            itemBuilder: (context, index) {
                              final p = payments[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Icon(
                                        Icons.payment,
                                        color: Colors.green.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      '${formatter.format(p.amount)} د.ع',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    subtitle: Container(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                              const SizedBox(width: 6),
                                              Text(
                                                'تاريخ: ${p.paidAt.toString().split(' ').first}',
                                                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.receipt, size: 16, color: Colors.grey.shade600),
                                              const SizedBox(width: 6),
                                              Text(
                                                'رقم الوصل: ${p.receiptNumber ?? 'بدون رقم'}',
                                                style: TextStyle(color: Colors.grey.shade700),
                                              ),
                                            ],
                                          ),
                                          if (p.notes != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'ملاحظات: ${p.notes}',
                                                    style: TextStyle(color: Colors.grey.shade700),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          Container(
                                            decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                            icon: Image.asset(
                                              'assets/whatsapp.png', // ضع مسار الصورة هنا
                                              width: 24,
                                              height: 24,
                                            ),
                                            onPressed: () async {
                                                     _sendPaymentToWhatsApp( p);
                                              await reloadAllData();
                                         
                                            },
                                            ),
                                          ),
                                        const SizedBox(width: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () async {
                                            await deleteStudentPayment(isar, p.id, widget.studentId.toString(), selectedAcademicYear!);
                                              await reloadAllData();
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                            onPressed: () async {
                                              final result = await showEditPaymentDialogIsar(
                                                context: context,
                                                payment: p,
                                                studentId: widget.studentId.toString(),
                                                academicYear: selectedAcademicYear ?? 'غير معروف',
                                              );
                                              if (result == true) {
                                                await reloadAllData();
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              printArabicInvoice2(
                                                studentName: widget.fullName,
                                                academicYear: selectedAcademicYear ?? 'غير معروف',
                                                amount: p.amount,
                                                paidAt: p.paidAt,
                                                receiptNumber: p.receiptNumber ?? 'غير متوفر',
                                                notes: p.notes ?? '',
                                                invoiceSerial: p.invoiceSerial
                                              );
                                            }, 
                                            icon: const Icon(Icons.print_outlined, color: Colors.green, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, 
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value, 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // إضافة مؤشرات بصرية للحالة المالية
  Widget _buildFinancialStatusIndicator() {
    if (feeStatus == null) return Container();
    
    final totalRequired = feeStatus!.annualFee + feeStatus!.transferredDebtAmount - feeStatus!.discountAmount;
    final totalPaid = feeStatus!.paidAmount;
    final remaining = totalRequired - totalPaid;
    final paymentProgress = totalRequired > 0 ? (totalPaid / totalRequired) : 0.0;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (remaining <= 0) {
      statusColor = Colors.green;
      statusText = 'مكتمل الدفع';
      statusIcon = Icons.check_circle;
    } else if (paymentProgress > 0.7) {
      statusColor = Colors.blue;
      statusText = 'قارب على الانتهاء';
      statusIcon = Icons.trending_up;
    } else if (paymentProgress > 0.3) {
      statusColor = Colors.orange;
      statusText = 'جاري السداد';
      statusIcon = Icons.access_time;
    } else {
      statusColor = Colors.red;
      statusText = 'متأخر في السداد';
      statusIcon = Icons.warning;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // العنوان والأيقونة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // شريط التقدم المحسن
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المدفوع: ${formatter.format(totalPaid)} د.ع',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'المطلوب: ${formatter.format(totalRequired)} د.ع',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // شريط التقدم مع تحسينات بصرية
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: paymentProgress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // النسبة المئوية مع تصميم محسن
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(paymentProgress * 100).toStringAsFixed(1)}% مدفوع',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // عرض المبلغ المتبقي إذا كان هناك باقي
                  if (remaining > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'المتبقي: ${formatter.format(remaining)} د.ع',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // إضافة مؤشر سريع للحالة المالية
  Widget _buildQuickStatusBadge() {
    if (feeStatus == null) return Container();
    
    final totalRequired = feeStatus!.annualFee + feeStatus!.transferredDebtAmount - feeStatus!.discountAmount;
    final totalPaid = feeStatus!.paidAmount;
    final remaining = totalRequired - totalPaid;
    
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (remaining <= 0) {
      statusText = 'مدفوع بالكامل';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (remaining <= totalRequired * 0.2) {
      statusText = 'قارب على الانتهاء';
      statusColor = Colors.blue;
      statusIcon = Icons.timer;
    } else if (remaining <= totalRequired * 0.5) {
      statusText = 'جاري السداد';
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    } else {
      statusText = 'متأخر في السداد';
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // إضافة عرض تفصيلي للخصومات
  Widget _buildDiscountDetails() {
    if (feeStatus == null || feeStatus!.discountAmount <= 0) return Container();
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.discount, color: Colors.green.shade700, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'تفاصيل الخصومات',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'إجمالي الخصم: ${formatter.format(feeStatus!.discountAmount)} د.ع',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (feeStatus!.discountDetails != null && feeStatus!.discountDetails!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'التفاصيل: ${feeStatus!.discountDetails}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // عرض تاريخ الديون للطالب
  Future<void> _showDebtHistory() async {
    if (widget.student == null) return;
    
    // جلب تاريخ الديون من helper
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تاريخ ديون الطالب'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<StudentFeeStatus>>(
              future: isar.studentFeeStatus
                  .filter()
                  .studentIdEqualTo(widget.student!.id.toString())
                  .sortByAcademicYear()
                  .findAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final feeStatuses = snapshot.data!;
                if (feeStatuses.isEmpty) {
                  return const Text('لا يوجد تاريخ أقساط للطالب');
                }
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var status in feeStatuses)
                      Card(
                        child: ListTile(
                          title: Text('${status.academicYear} - ${status.className}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('القسط: ${formatter.format(status.annualFee)} د.ع'),
                              Text('المدفوع: ${formatter.format(status.paidAmount)} د.ع'),
                              Text('المتبقي: ${formatter.format(status.dueAmount ?? 0)} د.ع'),
                              if (status.transferredDebtAmount > 0)
                                Text(
                                  'دين منقول: ${formatter.format(status.transferredDebtAmount)} د.ع',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              if (status.originalDebtAcademicYear != null)
                                Text(
                                  'من: ${status.originalDebtAcademicYear}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في عرض تاريخ الديون: $e')),
      );
    }
  }

  // دالة لبناء أزرار الإدارة المحسنة
  Widget _buildManagementButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(width: 200,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  // إضافة إحصائيات سريعة
  Widget _buildQuickStats() {
    if (feeStatus == null) return Container();
    
    final totalRequired = feeStatus!.annualFee + feeStatus!.transferredDebtAmount - feeStatus!.discountAmount;
    final totalPaid = feeStatus!.paidAmount;
    final remaining = totalRequired - totalPaid;
    final paymentProgress = totalRequired > 0 ? (totalPaid / totalRequired) : 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'ملخص سريع',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStatItem('نسبة السداد', '${(paymentProgress * 100).toStringAsFixed(1)}%', Icons.pie_chart, Colors.blue),
              _buildQuickStatItem('عدد الدفعات', '${payments.length}', Icons.receipt_long, Colors.green),
              _buildQuickStatItem('المتبقي', '${formatter.format(remaining)} د.ع', Icons.pending_actions, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // إضافة معاينة سريعة للطالب
  Widget _buildStudentQuickInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigo.shade100,
            child: Icon(Icons.person, color: Colors.indigo.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.student?.schoolclass.value?.name != null)
                  Text(
                    'الصف: ${widget.student!.schoolclass.value!.name}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (selectedAcademicYear != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedAcademicYear!,
                style: TextStyle(
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}