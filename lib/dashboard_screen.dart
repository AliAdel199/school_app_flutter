import 'package:flutter/material.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // final supabase = Supabase.instance.client;
  int studentCount = 0;
  int classCount = 0;
  String subscriptionAlert = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // fetchStats();
  }


  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
    

 
      // final schoolId = await isar.schools.where().findFirst().id;

      // if (schoolId == null) {
      //   throw Exception('School ID not found in local profile');
      // }

      // final classCountQuery = await isar.schoolClass.filter().schoolIdEqualTo (schoolId).count();

      // final school = await isar.schools.filter().idEqualTo(schoolId).findFirst();
      // final endDate = school?.endDate;
      final now = DateTime.now();
      String alert = '';
      // if (endDate != null) {
      //   final diff = endDate.difference(now).inDays;
      //   if (diff < 0) {
      //     alert = 'انتهى الاشتراك!';
      //   } else if (diff <= 7) {
      //     alert = 'الاشتراك ينتهي بعد $diff يوم';
      //   } else {
      //     alert = 'الاشتراك فعّال';
      //   }
      // }

      setState(() {
        studentCount = 5;// studentCountQuery;
        classCount = 6;//classCountQuery;
        subscriptionAlert = "alert";
      });
    } catch (e) {
      debugPrint('Error fetching dashboard stats from Isar: \n$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Future<void> fetchStats() async {
  //   setState(() => isLoading = true);
  //   try {
  //     final profile = await supabase
  //         .from('profiles')
  //         .select('school_id')
  //         .eq('id', supabase.auth.currentUser!.id)
  //         .single();

  //     final schoolId = profile['school_id'];

  //     final studentRes = await supabase
  //         .from('students')
  //         .select('id')
  //         .eq('school_id', schoolId);

  //     final classRes = await supabase
  //         .from('classes')
  //         .select('id')
  //         .eq('school_id', schoolId);

  //     final subscriptionRes = await supabase
  //         .from('schools')
  //         .select()
  //         .eq('id', schoolId)
  //         .maybeSingle();

  //     final endDate = DateTime.tryParse(subscriptionRes?['end_date'] ?? '');
  //     final now = DateTime.now();
  //     if (endDate != null) {
  //       final diff = endDate.difference(now).inDays;
  //       if (diff < 0) {
  //         subscriptionAlert = 'انتهى الاشتراك!';
  //       } else if (diff <= 7) {
  //         subscriptionAlert = 'الاشتراك ينتهي بعد $diff يوم';
  //       } else {
  //         subscriptionAlert = 'الاشتراك فعّال';
  //       }
  //     }

  //     setState(() {
  //       studentCount = studentRes.length;
  //       classCount = classRes.length;
  //     });
  //   } catch (e) {
  //     debugPrint('Error fetching dashboard stats: \n$e');
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة التحكم'),actions: [IconButton(onPressed: ()=>Navigator.popAndPushNamed(context, '/'), icon: Icon(Icons.logout_outlined))],),
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
                      // Expanded(child: _buildOverviewPanel()),
                      // Expanded(child: Container()),

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
      // {'label': 'المواد', 'icon': Icons.book, 'route': '/subjects'},
      {'label': 'المراحل', 'icon': Icons.score, 'route': '/classes'},
      // {'label': 'إضافة مرحلة', 'icon': Icons.add, 'route': '/add-class'},
      // {'label': 'التقارير المالية', 'icon': Icons.monetization_on, 'route': '/financial-reports'},
      {'label': 'التقارير العامة', 'icon': Icons.bar_chart, 'route': '/reportsscreen'},
      // {'label': 'إضافة موظف', 'icon': Icons.person_add_alt, 'route': '/add-edit-employee'},
    // {'label': 'قائمة الموظفين', 'icon': Icons.work, 'route': '/employee-list'},
    // {'label': 'الرواتب الشهرية', 'icon': Icons.payments, 'route': '/monthly-salary'},
    // {'label': 'تقرير الرواتب', 'icon': Icons.receipt, 'route': '/salary-report'},
    {'label': 'قائمة المصروفات', 'icon': Icons.money_off, 'route': '/expense-list'},
    {'label': 'قائمة الدخل', 'icon': Icons.account_balance_wallet, 'route': '/income'},
    {'label': 'سجل الفواتير', 'icon': Icons.account_balance_wallet, 'route': '/payment-list'},
    
    {'label': 'إدارة المستخدمين', 'icon': Icons.admin_panel_settings, 'route': '/user-screen'},
    {'label': 'سجل العمليات', 'icon': Icons.history, 'route': '/logs-screen'},
    // {'label': 'إضافة مصروف', 'icon': Icons.add_circle, 'route': '/add-expense'},

    
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
            _buildItem(Icons.notifications, 'تنبيهات الاشتراك', subscriptionAlert),
            const Divider(),
            _buildItem(Icons.bar_chart, 'عدد الطلاب', '$studentCount طالبًا'),
            const Divider(),
            _buildItem(Icons.school, 'عدد الصفوف', '$classCount صفًا دراسيًا'),
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
