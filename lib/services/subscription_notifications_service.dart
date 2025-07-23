import 'package:flutter/material.dart';
import 'subscription_service.dart';

/// نموذج بيانات الإشعار
class NotificationData {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  
  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
  
  NotificationData copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  expiry,
  activation,
  renewal,
  offer,
  warning,
}

/// خدمة إدارة إشعارات الاشتراكات (نسخة مبسطة)
class SubscriptionNotificationsService {
  static final List<NotificationData> _notifications = [];
  static final ValueNotifier<int> unreadCount = ValueNotifier(0);
  static final ValueNotifier<List<NotificationData>> notificationsNotifier = 
      ValueNotifier([]);
  
  /// تهيئة نظام الإشعارات
  static Future<void> initialize() async {
    try {
      debugPrint('✅ تم تهيئة نظام الإشعارات بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة الإشعارات: $e');
    }
  }
  
  /// فحص وإرسال إشعارات انتهاء الاشتراك
  static Future<void> checkAndSendExpirationNotifications() async {
    try {
      final status = await SubscriptionService.getReportsSyncStatus();
      
      if (status.isActive && status.daysRemaining != null) {
        final daysRemaining = status.daysRemaining!;
        
        // إشعار قبل 7 أيام
        if (daysRemaining == 7) {
          await _addNotification(
            'تنبيه اشتراك مزامنة التقارير',
            'سينتهي اشتراكك خلال 7 أيام. جدد الآن لتجنب انقطاع الخدمة.',
            NotificationType.warning,
            'expiry_7_days',
          );
        }
        
        // إشعار قبل 3 أيام
        if (daysRemaining == 3) {
          await _addNotification(
            'تحذير: انتهاء الاشتراك قريب',
            'سينتهي اشتراك مزامنة التقارير خلال 3 أيام فقط!',
            NotificationType.warning,
            'expiry_3_days',
          );
        }
        
        // إشعار قبل يوم واحد
        if (daysRemaining == 1) {
          await _addNotification(
            'إنذار أخير: انتهاء الاشتراك غداً',
            'سينتهي اشتراك مزامنة التقارير غداً. جدد الآن!',
            NotificationType.expiry,
            'expiry_1_day',
          );
        }
      }
    } catch (e) {
      debugPrint('خطأ في فحص إشعارات الاشتراك: $e');
    }
  }
  
  /// إرسال إشعار نجاح التفعيل
  static Future<void> sendActivationSuccessNotification() async {
    await _addNotification(
      'تم تفعيل الاشتراك بنجاح! 🎉',
      'يمكنك الآن الاستمتاع بمزامنة التقارير السحابية لمدة 30 يوم.',
      NotificationType.activation,
      'activation_success',
    );
  }
  
  /// إرسال إشعار انتهاء الاشتراك
  static Future<void> sendExpirationNotification() async {
    await _addNotification(
      'انتهى اشتراك مزامنة التقارير',
      'تم إيقاف مزامنة التقارير السحابية. جدد اشتراكك لاستعادة الخدمة.',
      NotificationType.expiry,
      'subscription_expired',
    );
  }
  
  /// إرسال إشعار تذكير بالتجديد
  static Future<void> sendRenewalReminderNotification(int daysRemaining) async {
    await _addNotification(
      'تذكير بتجديد الاشتراك',
      'متبقي $daysRemaining أيام على انتهاء اشتراك مزامنة التقارير. جدد اشتراكك الآن.',
      NotificationType.renewal,
      'renewal_reminder_$daysRemaining',
    );
  }
  
  /// إرسال إشعار عرض خاص
  static Future<void> sendSpecialOfferNotification(String offerTitle, String offerDescription) async {
    await _addNotification(
      'عرض خاص: $offerTitle',
      offerDescription,
      NotificationType.offer,
      'special_offer_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
  
  /// إضافة إشعار جديد
  static Future<void> _addNotification(
    String title, 
    String body, 
    NotificationType type, 
    String id
  ) async {
    try {
      // تحقق من عدم وجود إشعار بنفس الـ ID
      final existingIndex = _notifications.indexWhere((n) => n.id == id);
      
      final notification = NotificationData(
        id: id,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
      );
      
      if (existingIndex != -1) {
        _notifications[existingIndex] = notification;
      } else {
        _notifications.insert(0, notification);
      }
      
      // تحديث العدادات
      _updateNotifiers();
      
      debugPrint('✅ تم إضافة إشعار: $title');
    } catch (e) {
      debugPrint('❌ خطأ في إضافة الإشعار: $e');
    }
  }
  
  /// الحصول على جميع الإشعارات
  static List<NotificationData> getAllNotifications() {
    return List.from(_notifications);
  }
  
  /// الحصول على الإشعارات غير المقروءة
  static List<NotificationData> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }
  
  /// عدد الإشعارات غير المقروءة
  static int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }
  
  /// تحديد إشعار كمقروء
  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateNotifiers();
    }
  }
  
  /// تحديد جميع الإشعارات كمقروءة
  static void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateNotifiers();
  }
  
  /// حذف إشعار
  static void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateNotifiers();
  }
  
  /// حذف جميع الإشعارات
  static void deleteAllNotifications() {
    _notifications.clear();
    _updateNotifiers();
  }
  
  /// حذف الإشعارات القديمة (أكثر من 30 يوم)
  static void deleteOldNotifications() {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    _notifications.removeWhere((n) => n.timestamp.isBefore(thirtyDaysAgo));
    _updateNotifiers();
  }
  
  /// تحديث المراقبات
  static void _updateNotifiers() {
    unreadCount.value = getUnreadCount();
    notificationsNotifier.value = List.from(_notifications);
  }
  
  /// إنشاء widget لعرض شارة الإشعارات
  static Widget buildNotificationBadge({
    required Widget child,
    Color? badgeColor,
    Color? textColor,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: unreadCount,
      builder: (context, count, _) {
        if (count == 0) return child;
        
        return Stack(
          children: [
            child,
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// إنشاء widget لعرض قائمة الإشعارات
  static Widget buildNotificationsList({
    EdgeInsetsGeometry? padding,
    void Function(NotificationData)? onNotificationTap,
  }) {
    return ValueListenableBuilder<List<NotificationData>>(
      valueListenable: notificationsNotifier,
      builder: (context, notifications, _) {
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد إشعارات',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: padding ?? EdgeInsets.all(8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationTile(
              notification, 
              onTap: onNotificationTap,
            );
          },
        );
      },
    );
  }
  
  static Widget _buildNotificationTile(
    NotificationData notification, {
    void Function(NotificationData)? onTap,
  }) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.expiry:
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      case NotificationType.activation:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case NotificationType.renewal:
        iconData = Icons.refresh;
        iconColor = Colors.blue;
        break;
      case NotificationType.offer:
        iconData = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      case NotificationType.warning:
        iconData = Icons.warning_amber;
        iconColor = Colors.orange;
        break;
    }
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: notification.isRead ? Colors.grey[50] : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            markAsRead(notification.id);
          }
          onTap?.call(notification);
        },
      ),
    );
  }
  
  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
