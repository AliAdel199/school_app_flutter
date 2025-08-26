import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/class.dart';
import 'package:school_app_flutter/localdatabase/student.dart';
import 'package:school_app_flutter/localdatabase/user.dart';
import 'LicenseCheckScreen.dart';
import 'main.dart';
import 'helpers/program_info.dart';
import 'services/offline_license_service.dart';
import 'services/license_database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int studentCount = 0;
  int classCount = 0;
  String subscriptionAlert = '';
  int remainingDays = 0;
  int userCount = 0; // يمكنك إضافة عداد المستخدمين هنا
  bool isTrial = false;
  bool isLoading = false;
  bool isOfflineMode = false;

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    fetchStats();
  }

  // تحديث البيانات عند العودة إلى الشاشة
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة جلب البيانات في حالة تغيير حالة الترخيص
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
      // جلب البيانات المحلية أولاً
      List<Student> students = await isar.students.where().findAll();
      studentCount = students.length;

      List<SchoolClass> classes = await isar.schoolClass.where().findAll();
      classCount = classes.length;

      List<User> users = await isar.users.where().findAll();
      userCount = users.length;

      // فحص الترخيص (أونلاين أو أوفلاين)
      final licenseStatus = await OfflineLicenseService.checkLicense();
      
      // تحديث قاعدة البيانات المحلية
      await LicenseDatabaseService.updateAllLicenseViews();
      
      // معالجة حالة الترخيص
      remainingDays = licenseStatus['remainingDays'] ?? 0;
      isTrial = licenseStatus['isTrialActive'] ?? false;
      final isActivated = licenseStatus['isActivated'] ?? false;
      isOfflineMode = licenseStatus['status'] == 'requires_internet';
      
      // تحديد رسالة الاشتراك
      if (isOfflineMode) {
        subscriptionAlert = licenseStatus['error'] ?? 'يرجى الاتصال بالإنترنت';
      } else if (isActivated) {
        subscriptionAlert = 'النسخة مُفعَّلة';
        isTrial = false;
      } else if (isTrial && remainingDays > 0) {
        subscriptionAlert = 'تبقى $remainingDays يومًا للفترة التجريبية';
      } else if (remainingDays <= 0) {
        subscriptionAlert = 'انتهت الفترة التجريبية!';
        isTrial = false;
      } else {
        subscriptionAlert = 'يحتاج تفعيل';
        isTrial = false;
      }
      
      // طباعة معلومات التشخيص
      print('🔍 حالة الترخيص: ${licenseStatus['status']}');
      print('🔍 وضع عدم الاتصال: $isOfflineMode');
      print('🔍 مُفعَّل: $isActivated');
      print('🔍 فترة تجريبية نشطة: $isTrial');
      print('🔍 أيام متبقية: $remainingDays');
      
    } catch (e) {
      debugPrint('Error fetching dashboard stats: \n$e');
      subscriptionAlert = 'خطأ في جلب البيانات';
      remainingDays = 0;
      isTrial = false;
      isOfflineMode = true;
    } finally {
      setState(() => isLoading = false);
    }
  }
  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان مع مؤشر السكرول
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text(
                'الإحصائيات السريعة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.swipe_left,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                'اسحب لعرض المزيد',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        // البطاقات مع السكرول
        Container(
          height: 120, // تثبيت الارتفاع
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListView(
            scrollDirection: Axis.horizontal, // تفعيل السكرول الأفقي
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildStatCardFixed(
                'عدد الطلاب',
                '$studentCount',
                Icons.people,
                Colors.blue,
                'طالب',
              ),
              const SizedBox(width: 12),
              _buildStatCardFixed(
                'عدد الصفوف',
                '$classCount',
                Icons.class_,
                Colors.green,
                'صف دراسي',
              ),
              const SizedBox(width: 12),
              _buildStatCardFixed(
                'أيام متبقية',
                subscriptionAlert == 'النسخة مُفعَّلة' ? '∞' : '$remainingDays',
                Icons.timer,
                subscriptionAlert == 'النسخة مُفعَّلة' ? Colors.green : 
                isTrial ? Colors.orange : Colors.red,
                subscriptionAlert == 'النسخة مُفعَّلة' ? 'مُفعَّل' : 'يوم',
              ),
              const SizedBox(width: 12),
              _buildStatCardFixed(
                'المستخدمين',
                '$userCount', // يمكنك إضافة عداد المستخدمين هنا
                Icons.admin_panel_settings,
                Colors.teal,
                'مستخدم',
              ),
              // const SizedBox(width: 12),
              // _buildStatCardFixed(
              //   'التقارير',
              //   '12', // يمكنك إضافة عداد التقارير هنا
              //   Icons.assessment,
              //   Colors.purple,
              //   'تقرير',
              // ),
              // const SizedBox(width: 12),
              // _buildStatCardFixed(
              //   'الفواتير',
              //   '25', // يمكنك إضافة عداد الفواتير هنا
              //   Icons.receipt_long,
              //   Colors.indigo,
              //   'فاتورة',
              // ),
              // const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardFixed(String title, String value, IconData icon, Color color, String unit) {
    return Container(
      width: 160, // عرض ثابت لكل بطاقة
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title:  Row(
          children: [
            // إضافة مؤشر الوضع (أونلاين/أوفلاين)
            if (isOfflineMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.cloud_off, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('بدون إنترنت', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
            if (isOfflineMode) const SizedBox(width: 8),
            // Text('لوحة التحكم'),
            // const SizedBox(width: 8),
            Text(' ${academicYear==''? 'غير محدد':academicYear} :العام الدراسي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            IconButton(onPressed: (){
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController yearController = TextEditingController(text: academicYear);
                  return AlertDialog(
                    title: const Text('تعديل العام الدراسي'),
                    content: TextField(
                      controller: yearController,
                      decoration: const InputDecoration(hintText: 'مثال: 2023-2024',
                        labelText: 'العام الدراسي',
                        border: OutlineInputBorder(),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            saveAcademicYear(yearController.text);
                                loadAcademicYear();

                           
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('حفظ'),
                      ),
                    ],
                  );
                },
              );

            }, icon: const Icon(Icons.edit_outlined)),

          ],
        ),
        actions: [

      

          ProgramInfo.buildInfoButton(context),
          // عرض زر التفعيل فقط إذا لم يكن مُفعَّلاً
          if (isTrial || subscriptionAlert.contains('يحتاج تفعيل') || subscriptionAlert.contains('انتهت'))
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isTrial ? Colors.orange.shade800 : Colors.red.shade800,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LicenseCheckScreen()),
              ),
              icon: const Icon(Icons.lock_open),
              label: Text(isTrial ? 'فترة تجريبية - تفعيل' : 'تفعيل'),
            ),
          // عرض حالة التفعيل إذا كان مُفعَّلاً
          if (subscriptionAlert == 'النسخة مُفعَّلة')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.verified, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('مُفعَّل', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, '/'),
            icon: const Icon(Icons.logout_outlined),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 16),
                    _buildActionCards(context),
                    // const SizedBox(height: 16),
                    // _buildOverviewPanel(),
                  ],
                ),
              )
      ),
      bottomNavigationBar: ProgramInfo.buildCopyrightFooter(),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final actions = [
      
      {'label': 'الطلاب', 'icon': Icons.people, 'route': '/students'},
      {'label': 'إضافة طالب', 'icon': Icons.person_add, 'route': '/add-student'},
      {'label': 'المراحل', 'icon': Icons.score, 'route': '/classes'},
      {'label': 'إدارة الدرجات', 'icon': Icons.grade, 'route': '/marks-management'},
      {'label': 'الحضور والانصراف', 'icon': Icons.how_to_reg, 'route': '/attendance-management'}, // إضافة جديدة
      {'label': 'تقرير درجات الطالب', 'icon': Icons.school, 'route': '/student-grades-report'},
      {'label': 'إدارة الخصومات', 'icon': Icons.percent, 'route': '/discount-management'},
      {'label': 'التقارير العامة', 'icon': Icons.bar_chart, 'route': '/reportsscreen'},
      // {'label': 'التقارير المرفوعة', 'icon': Icons.cloud_upload, 'route': '/uploaded-reports'},
      // {'label': 'تشخيص التقارير', 'icon': Icons.engineering, 'route': '/reports-diagnostic'},
      // {'label': 'اختبار جلب التقارير', 'icon': Icons.bug_report, 'route': '/test-fetch-reports'},
      {'label': 'تقرير حالة الطلاب', 'icon': Icons.assignment, 'route': '/student-payment-status'},
      {'label': 'قائمة المصروفات', 'icon': Icons.money_off, 'route': '/expense-list'},
      {'label': 'قائمة الدخل', 'icon': Icons.account_balance_wallet, 'route': '/income'},
      {'label': 'سجل الفواتير', 'icon': Icons.receipt_long, 'route': '/payment-list'},
      {'label': 'إدارة المستخدمين', 'icon': Icons.admin_panel_settings, 'route': '/user-screen'},
      {'label': 'سجل العمليات', 'icon': Icons.history, 'route': '/logs-screen'},
      {'label': 'إدارة الاشتراكات', 'icon': Icons.subscriptions, 'route': '/admin-dashboard'}, // جديد
      // {'label': 'اختبار قاعدة البيانات', 'icon': Icons.bug_report, 'route': '/database-test'},
      // {'label': 'اختبار النظام الشامل', 'icon': Icons.verified_user, 'route': '/system-test'},
      // {'label': 'بيانات تجريبية', 'icon': Icons.science, 'route': '/test-data-generator'}, // جديد
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, action['route'] as String),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action['icon'] as IconData, size: 32, color: Colors.teal),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    action['label']! as String,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}