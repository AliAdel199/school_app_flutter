import 'package:flutter/material.dart';
import '../license_manager.dart';
import 'LicenseCheckScreen.dart';
import 'main.dart';

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
  bool isTrial = false;
  bool isLoading = false;

  @override
   void initState() {
    super.initState();
    loadAcademicYear();
    fetchStats();
    
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
      // TODO: Replace with actual student/class count logic
      studentCount = 5;
      classCount = 6;

      final now = DateTime.now();
      final endDate = await LicenseManager.getEndDate();
      print(endDate); // Debugging line to see the end date
      if (endDate != null) {
        final diff = endDate.difference(now).inDays;
        remainingDays = diff;
        if (diff < 0) {
          subscriptionAlert = 'انتهت الفترة!';
        } else {
          subscriptionAlert = 'تبقى $diff يومًا للاشتراك';
        }
      }
      isTrial = await LicenseManager.isTrialLicense();
    } catch (e) {
      debugPrint('Error fetching dashboard stats: \n$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title:  Row(
          children: [
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
              if (isTrial)
      TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: Colors.white,backgroundColor: isTrial ? Colors.orange.shade800 : Colors.green.shade800,),
onPressed: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const LicenseCheckScreen()),
),
        icon: const Icon(Icons.lock_open),
        label:  Text(' $subscriptionAlert تفعيل' ),
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
            : isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildActionCards(context)),
                      const SizedBox(width: 16),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildActionCards(context),
                        const SizedBox(height: 16),
                        _buildOverviewPanel(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final actions = [
      {'label': 'الطلاب', 'icon': Icons.people, 'route': '/students'},
      {'label': 'إضافة طالب', 'icon': Icons.person_add, 'route': '/add-student'},
      {'label': 'المراحل', 'icon': Icons.score, 'route': '/classes'},
      {'label': 'إدارة الخصومات', 'icon': Icons.percent, 'route': '/discount-management'}, // إضافة جديدة
      {'label': 'التقارير العامة', 'icon': Icons.bar_chart, 'route': '/reportsscreen'},
      {'label': 'قائمة المصروفات', 'icon': Icons.money_off, 'route': '/expense-list'},
      {'label': 'قائمة الدخل', 'icon': Icons.account_balance_wallet, 'route': '/income'},
      {'label': 'سجل الفواتير', 'icon': Icons.receipt_long, 'route': '/payment-list'},
      {'label': 'إدارة المستخدمين', 'icon': Icons.admin_panel_settings, 'route': '/user-screen'},
      {'label': 'سجل العمليات', 'icon': Icons.history, 'route': '/logs-screen'},
    ];

    return Center(
      child: GridView.builder(
        itemCount: actions.length,
        shrinkWrap: true,
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
                  Text(
                    action['label']! as String,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewPanel() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('التقارير والتنبيهات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (isTrial)
              _buildItem(Icons.hourglass_bottom, 'الفترة التجريبية', 'تبقّى $remainingDays يومًا'),
            _buildItem(Icons.notifications, 'تنبيهات الاشتراك', subscriptionAlert),
            const Divider(),
            _buildItem(Icons.bar_chart, 'عدد الطلاب', '$studentCount طالبًا'),
            const Divider(),
            _buildItem(Icons.school, 'عدد الصفوف', '$classCount صفًا دراسيًا'),
            const Divider(),
            if (isTrial)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/'),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('تفعيل النسخة الآن'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}
