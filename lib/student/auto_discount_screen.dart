import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../helpers/simple_auto_discount_processor.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_discount.dart';
import '../main.dart';

class AutoDiscountScreen extends StatefulWidget {
  const AutoDiscountScreen({Key? key}) : super(key: key);

  @override
  State<AutoDiscountScreen> createState() => _AutoDiscountScreenState();
}

class _AutoDiscountScreenState extends State<AutoDiscountScreen> {
  final formatter = NumberFormat('#,###');
  late AutoDiscountProcessor processor;
  bool isLoading = false;
  Map<String, dynamic> stats = {};
  
  // إعدادات الخصومات
  bool siblingDiscountEnabled = true;
  bool earlyPaymentDiscountEnabled = true;
  bool fullPaymentDiscountEnabled = true;
  
  @override
  void initState() {
    super.initState();
    processor = AutoDiscountProcessor(isar);
    loadStats();
  }
  
  Future<void> loadStats() async {
    setState(() => isLoading = true);
    try {
      final stats = await processor.getAutoDiscountStats(academicYear);
      setState(() {
        this.stats = stats;
      });
    } catch (e) {
      debugPrint('خطأ في تحميل الإحصائيات: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الخصومات التلقائية'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة الإحصائيات
                  _buildStatsCard(),
                  const SizedBox(height: 20),
                  
                  // بطاقة الإعدادات
                  _buildSettingsCard(),
                  const SizedBox(height: 20),
                  
                  // بطاقة الإجراءات
                  _buildActionsCard(),
                  const SizedBox(height: 20),
                  
                  // بطاقة اختبار دقة تحديد الأشقاء
                  _buildSiblingTestCard(),
                  const SizedBox(height: 20),
                  
                  // قائمة أنواع الخصومات
                  _buildDiscountTypesList(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildStatsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.indigo.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'إحصائيات الخصومات التلقائية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (stats.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'إجمالي الخصومات',
                      '${stats['totalDiscounts'] ?? 0}',
                      Icons.discount,
                      Colors.white,
                    ),
                    _buildStatItem(
                      'المبلغ الإجمالي',
                      '${formatter.format(stats['totalDiscountAmount'] ?? 0)} د.ع',
                      Icons.money,
                      Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'خصم الأشقاء',
                      '${stats['siblingDiscounts'] ?? 0}',
                      Icons.family_restroom,
                      Colors.white,
                    ),
                    _buildStatItem(
                      'خصم الدفع المبكر',
                      '${stats['earlyPaymentDiscounts'] ?? 0}',
                      Icons.schedule,
                      Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: _buildStatItem(
                    'خصم الدفع الكامل',
                    '${stats['fullPaymentDiscounts'] ?? 0}',
                    Icons.payment,
                    Colors.white,
                  ),
                ),
              ] else ...[
                const Center(
                  child: Text(
                    'لا توجد إحصائيات متاحة',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.indigo.shade600, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'إعدادات الخصومات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingSwitch(
              'خصم الأشقاء',
              'تطبيق خصم تلقائي للأشقاء في المدرسة',
              siblingDiscountEnabled,
              (value) => setState(() => siblingDiscountEnabled = value),
            ),
            _buildSettingSwitch(
              'خصم الدفع المبكر',
              'خصم 5% للدفع قبل 30 يوم من بداية العام',
              earlyPaymentDiscountEnabled,
              (value) => setState(() => earlyPaymentDiscountEnabled = value),
            ),
            _buildSettingSwitch(
              'خصم الدفع الكامل',
              'خصم 3% للدفع الكامل في دفعة واحدة',
              fullPaymentDiscountEnabled,
              (value) => setState(() => fullPaymentDiscountEnabled = value),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_arrow, color: Colors.green.shade600, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'تطبيق الخصومات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processAllDiscounts(),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('تطبيق جميع الخصومات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _processSpecificDiscount(),
                    icon: const Icon(Icons.person_search),
                    label: const Text('تطبيق لطالب محدد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDiscountTypesList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: Colors.indigo.shade600, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'أنواع الخصومات المتاحة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDiscountTypeItem(
              'خصم الأشقاء',
              'خصم متدرج للأشقاء: 10% للثاني، 15% للثالث، 20% للرابع فما فوق',
              Icons.family_restroom,
              Colors.purple,
              siblingDiscountEnabled,
            ),
            _buildDiscountTypeItem(
              'خصم الدفع المبكر',
              'خصم 5% للطلاب الذين يدفعون قبل 30 يوم من بداية العام الدراسي',
              Icons.schedule,
              Colors.orange,
              earlyPaymentDiscountEnabled,
            ),
            _buildDiscountTypeItem(
              'خصم الدفع الكامل',
              'خصم 3% للطلاب الذين يدفعون كامل القسط في دفعة واحدة',
              Icons.payment,
              Colors.green,
              fullPaymentDiscountEnabled,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDiscountTypeItem(String title, String description, IconData icon, Color color, bool isEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled ? color.withOpacity(0.2) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              color: isEnabled ? color : Colors.grey.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? color : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (isEnabled)
            Icon(Icons.check_circle, color: color, size: 20)
          else
            Icon(Icons.pause_circle, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
  
  Future<void> _processAllDiscounts() async {
    if (!siblingDiscountEnabled && !earlyPaymentDiscountEnabled && !fullPaymentDiscountEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تفعيل نوع واحد على الأقل من الخصومات')),
      );
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد العملية'),
        content: const Text('هل تريد تطبيق الخصومات التلقائية على جميع الطلاب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => isLoading = true);
    
    try {
      final results = await processor.processAllStudentsDiscounts(academicYear);
      
      await loadStats();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تطبيق الخصومات على ${results.length} طالب'),
          backgroundColor: Colors.green,
        ),
      );
      
      // عرض تفاصيل النتائج
      _showResultsDialog(results);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تطبيق الخصومات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  void _showResultsDialog(Map<String, List<StudentDiscount>> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نتائج تطبيق الخصومات'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final entry = results.entries.elementAt(index);
              final studentName = entry.key;
              final discounts = entry.value;
              
              return Card(
                child: ListTile(
                  title: Text(studentName),
                  subtitle: Text('تم تطبيق ${discounts.length} خصم'),
                  trailing: Text(
                    '${formatter.format(discounts.fold<double>(0, (sum, d) => sum + d.discountValue))} د.ع',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
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
  }
  
  Future<void> _processSpecificDiscount() async {
    // إظهار قائمة الطلاب لاختيار طالب محدد
    final allStudents = await isar.students.where().findAll();
    
    if (allStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد طلاب مسجلين')),
      );
      return;
    }
    
    final selectedStudent = await showDialog<Student>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر طالباً'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: allStudents.length,
            itemBuilder: (context, index) {
              final student = allStudents[index];
              return ListTile(
                title: Text(student.fullName),
                subtitle: Text(student.parentName ?? ''),
                onTap: () => Navigator.pop(context, student),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
    
    if (selectedStudent == null) return;
    
    setState(() => isLoading = true);
    
    try {
      final appliedDiscounts = await processor.processAllAutoDiscounts(selectedStudent, academicYear);
      
      await loadStats();
      
      if (appliedDiscounts.isNotEmpty) {
        final totalDiscount = appliedDiscounts.fold<double>(0, (sum, d) => sum + d.discountValue);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تطبيق ${appliedDiscounts.length} خصم للطالب ${selectedStudent.fullName} بقيمة ${formatter.format(totalDiscount)} د.ع'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يحق للطالب ${selectedStudent.fullName} أي خصم تلقائي'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تطبيق الخصم: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Widget _buildSiblingTestCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'اختبار دقة تحديد الأشقاء',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'استخدم هذه الأدوات للتحقق من دقة تحديد الأشقاء في النظام ومعالجة أي أخطاء',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runSiblingAccuracyTest,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('تشغيل اختبار الدقة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showSiblingStatistics,
                    icon: const Icon(Icons.analytics),
                    label: const Text('إحصائيات الأشقاء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fixSiblingIssues,
                icon: const Icon(Icons.build),
                label: const Text('إصلاح مشاكل تحديد الأشقاء'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _runSiblingAccuracyTest() async {
    setState(() => isLoading = true);
    
    try {
      // تشغيل اختبار دقة تحديد الأشقاء
      await processor.testSiblingDetection();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تشغيل اختبار الدقة. راجع سجل التطبيق للتفاصيل.'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تشغيل الاختبار: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> _showSiblingStatistics() async {
    setState(() => isLoading = true);
    
    try {
      final siblingStats = await processor.getSiblingStatistics();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إحصائيات الأشقاء'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('إجمالي الطلاب', '${siblingStats['totalStudents']}'),
                _buildStatRow('الطلاب الذين لديهم أشقاء', '${siblingStats['studentsWithSiblings']}'),
                _buildStatRow('مجموعات الآباء', '${siblingStats['parentGroups']}'),
                _buildStatRow('مجموعات الأشقاء', '${siblingStats['siblingGroups']}'),
                _buildStatRow('أكبر مجموعة أشقاء', '${siblingStats['largestSiblingGroup']} طلاب'),
                _buildStatRow('نسبة الطلاب الذين لديهم أشقاء', '${siblingStats['percentageWithSiblings']}%'),
              ],
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
        SnackBar(
          content: Text('خطأ في جلب الإحصائيات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
  
  Future<void> _fixSiblingIssues() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إصلاح مشاكل تحديد الأشقاء'),
        content: const Text(
          'سيتم فحص جميع الطلاب وإصلاح المشاكل التي يمكن إصلاحها تلقائياً. '
          'هل تريد المتابعة؟'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إصلاح'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => isLoading = true);
    
    try {
      final result = await processor.identifyAndFixSiblingIssues();
      
      // عرض النتائج
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('نتائج إصلاح المشاكل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('إجمالي المشاكل المكتشفة', '${result['totalIssues']}'),
              _buildStatRow('المشاكل المحلولة', '${result['fixedIssues']}'),
              _buildStatRow('المشاكل المتبقية', '${result['remainingIssues']}'),
              const SizedBox(height: 16),
              if (result['remainingIssues'] > 0)
                const Text(
                  'المشاكل المتبقية تتطلب تدخل يدوي لحلها. '
                  'راجع سجل التطبيق لمزيد من التفاصيل.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إصلاح ${result['fixedIssues']} مشكلة من أصل ${result['totalIssues']}'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إصلاح المشاكل: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
