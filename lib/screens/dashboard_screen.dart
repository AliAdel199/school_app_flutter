
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  int studentCount = 0;
  int classCount = 0;
  String subscriptionAlert = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
      final profile = await supabase
          .from('profiles')
          .select('school_id')
          .eq('id', supabase.auth.currentUser!.id)
          .single();

      final schoolId = profile['school_id'];

      final studentRes = await supabase
          .from('students')
          .select('id')
          .eq('school_id', schoolId);

      final classRes = await supabase
          .from('classes')
          .select('id');

      final subscriptionRes = await supabase
          .from('schools')
          .select()
          .eq('id', schoolId)
          .maybeSingle();

      final endDate = DateTime.tryParse(subscriptionRes?['end_date'] ?? '');
      final now = DateTime.now();
      if (endDate != null) {
        final diff = endDate.difference(now).inDays;
        if (diff < 0) {
          subscriptionAlert = 'انتهى الاشتراك!';
        } else if (diff <= 7) {
          subscriptionAlert = 'الاشتراك ينتهي بعد $diff يوم';
        } else {
          subscriptionAlert = 'الاشتراك فعّال';
        }
      }

      setState(() {
        studentCount = studentRes.length;
      });
    } catch (e) {
      debugPrint('Error fetching dashboard stats: \n\n$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة التحكم')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildActionCards(context)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildOverviewPanel()),
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
      {'label': 'المواد', 'icon': Icons.book, 'route': '/subjects'},
      {'label': 'المراحل', 'icon': Icons.score, 'route': '/classes'},
      // {'label': 'المدفوعات', 'icon': Icons.score, 'route': '/studentpayments'},
   

      
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
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
