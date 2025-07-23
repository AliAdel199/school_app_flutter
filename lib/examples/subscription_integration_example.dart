import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/reports_sync_service.dart';
import '../services/subscription_notifications_service.dart';
import '../services/subscription_offers_service.dart';
import '../screens/subscription_management_screen.dart';
import '../screens/subscription_offers_screen.dart';

/// مثال على كيفية دمج نظام الاشتراكات في التطبيق
class SubscriptionIntegrationExample {
  
  /// إضافة فحص الاشتراك في main.dart
  static Future<void> initializeSubscriptionSystem() async {
    print('🔄 تهيئة نظام الاشتراكات المحدث...');
    
    try {
      // تهيئة الإشعارات
      await SubscriptionNotificationsService.initialize();
      
      // فحص الاشتراكات المنتهية
      await SubscriptionService.checkExpiredSubscriptions();
      
      // فحص وإرسال إشعارات انتهاء الاشتراك
      await SubscriptionNotificationsService.checkAndSendExpirationNotifications();
      
      // بدء الفحص الدوري
      await ReportsSyncService.startPeriodicSubscriptionCheck();
      
      print('✅ تم تهيئة نظام الاشتراكات المحدث بنجاح');
    } catch (e) {
      print('❌ خطأ في تهيئة نظام الاشتراكات: $e');
    }
  }
  
  /// إضافة زر مزامنة التقارير في الشاشة الرئيسية
  static Widget buildReportsSyncButton(BuildContext context) {
    return FutureBuilder<bool>(
      future: ReportsSyncService.canSyncReports(),
      builder: (context, snapshot) {
        final canSync = snapshot.data ?? false;
        
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: canSync 
                    ? () => _syncReports(context)
                    : () => _showSubscriptionRequired(context),
                icon: Icon(canSync ? Icons.cloud_sync : Icons.cloud_off),
                label: Text(canSync ? 'مزامنة التقارير' : 'تفعيل المزامنة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSync ? Colors.green : Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (!canSync) ...[
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionOffersScreen(),
                    ),
                  ),
                  icon: Icon(Icons.local_offer),
                  label: Text('العروض'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  /// إضافة حالة الاشتراك في درج التطبيق
  static Widget buildSubscriptionStatusDrawerItem(BuildContext context) {
    return FutureBuilder<SubscriptionStatus>(
      future: SubscriptionService.getReportsSyncStatus(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        
        return Column(
          children: [
            // عنصر حالة الاشتراك
            ListTile(
              leading: SubscriptionNotificationsService.buildNotificationBadge(
                child: Icon(
                  status?.isActive == true ? Icons.cloud_done : Icons.cloud_off,
                  color: status?.isActive == true ? Colors.green : Colors.grey,
                ),
              ),
              title: const Text('مزامنة التقارير'),
              subtitle: Text(
                status?.message ?? 'جاري التحميل...',
                style: TextStyle(fontSize: 12),
              ),
              trailing: status?.isActive == true 
                  ? Text('${status!.daysRemaining} يوم',
                         style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                  : Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionManagementScreen(),
                  ),
                );
              },
            ),
            
            // عنصر العروض والخصومات
            if (status?.isActive != true)
              ListTile(
                leading: Icon(Icons.local_offer, color: Colors.purple),
                title: Text('العروض والخصومات'),
                subtitle: Text('وفر المال مع العروض الخاصة', style: TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'جديد',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionOffersScreen(),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
  
  /// إضافة تحقق من الاشتراك قبل إنشاء التقارير
  static Future<bool> checkSubscriptionBeforeReport(BuildContext context, String reportType) async {
    // للتقارير الأساسية - لا تحتاج اشتراك
    if (['local_students', 'local_grades', 'local_attendance'].contains(reportType)) {
      return true;
    }
    
    // للتقارير السحابية - تحتاج اشتراك
    final canSync = await ReportsSyncService.canSyncReports();
    if (!canSync) {
      _showSubscriptionRequired(context);
      return false;
    }
    
    return true;
  }
  
  /// عرض تنبيه انتهاء الاشتراك
  static Future<void> showExpirationWarning(BuildContext context, int daysRemaining) async {
    if (daysRemaining <= 7) {
      final shouldShowOffers = daysRemaining <= 3;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('تنبيه انتهاء الاشتراك'),
            ],
          ),
          content: Text(
            'سينتهي اشتراك مزامنة التقارير خلال $daysRemaining أيام.\n\n'
            'يرجى التجديد لتجنب انقطاع الخدمة.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لاحقاً'),
            ),
            if (shouldShowOffers)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionOffersScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text('عرض العروض'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionManagementScreen(),
                  ),
                );
              },
              child: Text('تجديد الآن'),
            ),
          ],
        ),
      );
    }
  }
  
  /// عرض أفضل عرض متاح
  static Future<void> showBestOfferPrompt(BuildContext context) async {
    try {
      final bestOffer = await SubscriptionOffersService.getBestAvailableOffer();
      
      if (bestOffer != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text('عرض خاص لك!'),
              ],
            ),
            content: Text(SubscriptionOffersService.generatePromotionalMessage(bestOffer)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('لاحقاً'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionOffersScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text('عرض العروض'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('خطأ في عرض العرض الأفضل: $e');
    }
  }
  
  /// إنشاء widget للإشعارات
  static Widget buildNotificationsButton(BuildContext context) {
    return SubscriptionNotificationsService.buildNotificationBadge(
      child: IconButton(
        onPressed: () => _showNotificationsBottomSheet(context),
        icon: Icon(Icons.notifications),
        tooltip: 'الإشعارات',
      ),
    );
  }
  
  /// عرض الإشعارات في bottom sheet
  static void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // العنوان
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'الإشعارات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      SubscriptionNotificationsService.markAllAsRead();
                    },
                    child: Text('قراءة الكل'),
                  ),
                ],
              ),
            ),
            
            // قائمة الإشعارات
            Expanded(
              child: SubscriptionNotificationsService.buildNotificationsList(
                onNotificationTap: (notification) {
                  // التعامل مع الضغط على الإشعار
                  if (notification.type == NotificationType.offer) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionOffersScreen(),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionManagementScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// دوال مساعدة خاصة
  static Future<void> _syncReports(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('جاري مزامنة التقارير...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await ReportsSyncService.syncReportsWithSupabase();
      Navigator.pop(context); // إغلاق dialog التحميل
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في المزامنة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  static void _showSubscriptionRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اشتراك مطلوب'),
        content: Text(
          'مزامنة التقارير تتطلب اشتراك شهري.\n\n'
          'السعر:15000 د ع شهرياً\n'
          'الميزات: نسخ احتياطي سحابي، وصول من أي جهاز، تحليلات متقدمة'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionManagementScreen(),
                ),
              );
            },
            child: Text('عرض الاشتراكات'),
          ),
        ],
      ),
    );
  }
}

/// مثال لاستخدام النظام في شاشة التقارير
class ReportsScreenWithSubscription extends StatefulWidget {
  @override
  _ReportsScreenWithSubscriptionState createState() => _ReportsScreenWithSubscriptionState();
}

class _ReportsScreenWithSubscriptionState extends State<ReportsScreenWithSubscription> {
  
  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }
  
  Future<void> _checkSubscriptionStatus() async {
    final status = await SubscriptionService.getReportsSyncStatus();
    if (status.isActive && status.daysRemaining != null) {
      if (status.daysRemaining! <= 7) {
        // عرض تنبيه انتهاء الاشتراك
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SubscriptionIntegrationExample.showExpirationWarning(context, status.daysRemaining!);
        });
      }
    } else {
      // عرض أفضل عرض متاح للمستخدمين غير المشتركين
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(seconds: 2)); // تأخير قصير
        SubscriptionIntegrationExample.showBestOfferPrompt(context);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقارير'),
        actions: [
          // زر الإشعارات
          SubscriptionIntegrationExample.buildNotificationsButton(context),
          
          // زر مزامنة التقارير
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: SubscriptionIntegrationExample.buildReportsSyncButton(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // بطاقة حالة المزامنة
          Card(
            margin: EdgeInsets.all(16),
            child: SubscriptionIntegrationExample.buildSubscriptionStatusDrawerItem(context),
          ),
          
          // بطاقة العروض الخاصة (للمستخدمين غير المشتركين)
          FutureBuilder<bool>(
            future: ReportsSyncService.canSyncReports(),
            builder: (context, snapshot) {
              final canSync = snapshot.data ?? false;
              
              if (!canSync) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.purple[50],
                  child: ListTile(
                    leading: Icon(Icons.local_offer, color: Colors.purple),
                    title: Text('عروض خاصة متاحة!'),
                    subtitle: Text('وفر المال مع خصومات تصل إلى 50%'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionOffersScreen(),
                        ),
                      );
                    },
                  ),
                );
              }
              
              return SizedBox.shrink();
            },
          ),
          
          // قائمة التقارير
          Expanded(
            child: ListView(
              children: [
                // التقارير المحلية (مجانية)
                _buildReportSection('التقارير المحلية (مجانية)', [
                  _buildReportTile('تقرير الطلاب', 'local_students', Icons.people),
                  _buildReportTile('تقرير الدرجات', 'local_grades', Icons.grade),
                  _buildReportTile('تقرير الحضور', 'local_attendance', Icons.check_circle),
                ]),
                
                // التقارير السحابية (تتطلب اشتراك)
                _buildReportSection('التقارير السحابية (تتطلب اشتراك)', [
                  _buildReportTile('تقرير مقارن للفروع', 'cloud_comparison', Icons.compare),
                  _buildReportTile('تحليلات متقدمة', 'cloud_analytics', Icons.analytics),
                  _buildReportTile('تقرير شامل', 'cloud_comprehensive', Icons.assessment),
                ]),
              ],
            ),
          ),
        ],
      ),
      
      // زر الانتقال لإدارة الاشتراكات
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubscriptionManagementScreen(),
            ),
          );
        },
        icon: Icon(Icons.subscriptions),
        label: Text('إدارة الاشتراكات'),
      ),
    );
  }
  
  Widget _buildReportSection(String title, List<Widget> reports) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...reports,
        Divider(),
      ],
    );
  }
  
  Widget _buildReportTile(String title, String reportType, IconData icon) {
    final isCloudReport = reportType.startsWith('cloud_');
    
    return ListTile(
      leading: Icon(icon, color: isCloudReport ? Colors.blue : Colors.green),
      title: Text(title),
      subtitle: Text(isCloudReport ? 'يتطلب اشتراك مزامنة التقارير' : 'متاح مجاناً'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () async {
        // فحص الاشتراك قبل فتح التقرير
        final canProceed = await SubscriptionIntegrationExample.checkSubscriptionBeforeReport(
          context, 
          reportType
        );
        
        if (canProceed) {
          // فتح التقرير
          _openReport(reportType);
        }
      },
    );
  }
  
  void _openReport(String reportType) {
    // هنا يتم فتح شاشة التقرير المطلوب
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فتح تقرير: $reportType')),
    );
  }
}
