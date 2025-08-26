import 'package:flutter/material.dart';
import '../admin/subscription_management_screen.dart';
import '../admin/reports_management_screen.dart';

class AdminMenuHelper {
  static List<Map<String, dynamic>> get _adminMenuItems => [
    {
      'title': 'إدارة الاشتراكات',
      'icon': Icons.subscriptions,
      'route': '/admin/subscription-management',
      'screen': () => const SubscriptionManagementScreen(),
      'description': 'إدارة اشتراكات المؤسسة والميزات المدفوعة',
    },
    {
      'title': 'إدارة رفع التقارير',
      'icon': Icons.cloud_upload,
      'route': '/admin/reports-management',
      'screen': () => const ReportsManagementScreen(),
      'description': 'إعدادات رفع التقارير التلقائي والإدارة',
    },
  ];

  static List<Map<String, dynamic>> get menuItems => _adminMenuItems;

  static Widget buildMenuCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToScreen(context, item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'],
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _navigateToScreen(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => item['screen'](),
      ),
    );
  }

  // بناء قائمة admin كاملة
  static Widget buildAdminMenu(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الإدارة'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _adminMenuItems.length,
        itemBuilder: (context, index) {
          return buildMenuCard(context, _adminMenuItems[index]);
        },
      ),
    );
  }

  // إضافة عنصر قائمة سريع
  static Widget buildQuickMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue.shade700),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // إنشاء شبكة من العناصر
  static Widget buildMenuGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _adminMenuItems.length,
      itemBuilder: (context, index) {
        final item = _adminMenuItems[index];
        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () => _navigateToScreen(context, item),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'],
                      color: Colors.blue.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
