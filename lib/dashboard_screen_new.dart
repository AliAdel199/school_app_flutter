import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int studentCount = 0;
  int classCount = 0;
  String subscriptionAlert = '';
  bool isTrial = false;
  int remainingDays = 0;

  @override
  void initState() {
    super.initState();
    _checkLicenseStatus();
  }

  Future<void> _checkLicenseStatus() async {
    try {
      // تبسيط منطق التحقق من الترخيص
      if (mounted) {
        setState(() {
          isTrial = true;
          remainingDays = 30;
          subscriptionAlert = 'نسخة تجريبية - 30 يوم متبقي';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          subscriptionAlert = 'خطأ في التحقق من الترخيص';
          isTrial = true;
          remainingDays = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة التحكم الرئيسية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkLicenseStatus,
            tooltip: 'تحديث حالة الترخيص',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/logs'),
            tooltip: 'سجل العمليات',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // لوحة الإحصائيات والتنبيهات
                _buildOverviewPanel(),
                
                const SizedBox(height: 24),
                
                // قسم البطاقات المصنفة
                _buildActionCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          // بطاقة الإحصائيات السريعة
          _buildStatsCards(),
          const SizedBox(height: 16),
          
          // بطاقة التنبيهات والمعلومات
          _buildAlertsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'عدد الطلاب',
            '$studentCount',
            Icons.people,
            Colors.blue,
            'طالب',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'عدد الصفوف',
            '$classCount',
            Icons.class_,
            Colors.green,
            'صف دراسي',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'أيام متبقية',
            '$remainingDays',
            Icons.timer,
            isTrial ? Colors.orange : Colors.purple,
            'يوم',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
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
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.orange.shade600, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'التنبيهات والمعلومات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (isTrial) ...[
                _buildAlertItem(
                  Icons.hourglass_bottom,
                  'الفترة التجريبية',
                  'تبقّى $remainingDays يومًا',
                  Colors.orange,
                ),
                const SizedBox(height: 12),
              ],
              
              _buildAlertItem(
                Icons.info_outline,
                'حالة الاشتراك',
                subscriptionAlert,
                remainingDays < 7 ? Colors.red : Colors.green,
              ),
              
              const SizedBox(height: 16),
              
              if (isTrial)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.lock_open),
                    label: const Text('تفعيل النسخة الآن'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
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
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Column(
      children: [
        _buildCategorySection(
          'إدارة الطلاب',
          Colors.blue,
          Icons.people,
          [
            {'label': 'إدارة الطلاب', 'route': '/users', 'icon': Icons.person_add},
            {'label': 'إضافة طالب', 'route': '/add_student', 'icon': Icons.person_add_alt_1},
            {'label': 'تقرير حضور', 'route': '/attendance_report', 'icon': Icons.fact_check},
            {'label': 'بيانات الطلاب', 'route': '/student_data', 'icon': Icons.assignment_ind},
          ],
        ),
        const SizedBox(height: 24),
        
        _buildCategorySection(
          'إدارة الدرجات',
          Colors.green,
          Icons.grade,
          [
            {'label': 'إدارة المواد والدرجات', 'route': '/marks_management', 'icon': Icons.edit_note},
            {'label': 'تقرير درجات الطالب', 'route': '/student_grades_report', 'icon': Icons.assessment},
            {'label': 'تقرير درجات الصف', 'route': '/class_grades_report', 'icon': Icons.class_},
            {'label': 'التقييمات', 'route': '/evaluations', 'icon': Icons.star_rate},
          ],
        ),
        const SizedBox(height: 24),
        
        _buildCategorySection(
          'الشؤون المالية',
          Colors.orange,
          Icons.account_balance_wallet,
          [
            {'label': 'إدارة الإيرادات والمصاريف', 'route': '/income_expense', 'icon': Icons.monetization_on},
            {'label': 'تقارير مالية', 'route': '/financial_reports', 'icon': Icons.analytics},
            {'label': 'حالة الدفع', 'route': '/payment_status', 'icon': Icons.payment},
            {'label': 'الفواتير', 'route': '/invoices', 'icon': Icons.receipt_long},
          ],
        ),
        const SizedBox(height: 24),
        
        _buildCategorySection(
          'التقارير والإحصائيات',
          Colors.purple,
          Icons.bar_chart,
          [
            {'label': 'تقارير شاملة', 'route': '/comprehensive_reports', 'icon': Icons.description},
            {'label': 'إحصائيات الأداء', 'route': '/performance_stats', 'icon': Icons.trending_up},
            {'label': 'تقارير مخصصة', 'route': '/custom_reports', 'icon': Icons.dashboard_customize},
            {'label': 'تحليل البيانات', 'route': '/data_analysis', 'icon': Icons.insights},
          ],
        ),
        const SizedBox(height: 24),
        
        _buildCategorySection(
          'الإدارة والإعدادات',
          Colors.teal,
          Icons.settings,
          [
            {'label': 'إدارة المستخدمين', 'route': '/users', 'icon': Icons.admin_panel_settings},
            {'label': 'إعدادات النظام', 'route': '/system_settings', 'icon': Icons.settings_applications},
            {'label': 'أرشيف الملفات', 'route': '/file_archive', 'icon': Icons.archive},
            {'label': 'سجل العمليات', 'route': '/logs', 'icon': Icons.history},
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title, Color color, IconData categoryIcon, List<Map<String, dynamic>> actions) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان القسم
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // بطاقات الإجراءات
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _buildActionCard(action, color);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, action['route'] as String),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action['label'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
