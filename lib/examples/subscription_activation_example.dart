import 'package:flutter/material.dart';
import '../dialogs/subscription_activation_dialog.dart';
import '../services/subscription_service.dart';

/// مثال على كيفية استخدام دايلوك تفعيل الاشتراك
class SubscriptionActivationExample {
  
  /// عرض دايلوك التفعيل من أي مكان في التطبيق
  static Future<void> showActivationDialog(BuildContext context) async {
    final result = await SubscriptionActivationDialog.show(context);
    
    if (result == true) {
      // تم التفعيل بنجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('تم تفعيل اشتراك مزامنة التقارير بنجاح!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  /// عرض دايلوك التفعيل مع عرض محدد
  static Future<void> showActivationDialogWithOffer(
    BuildContext context,
    String offerId,
  ) async {
    final result = await SubscriptionActivationDialog.show(
      context,
      preSelectedOfferId: offerId,
    );
    
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تفعيل الاشتراك مع العرض الخاص!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  /// فحص حالة الاشتراك وعرض الدايلوك حسب الحاجة
  static Future<void> checkAndShowActivationIfNeeded(BuildContext context) async {
    final status = await SubscriptionService.getReportsSyncStatus();
    
    if (!status.isActive) {
      // عرض دايلوك التفعيل
      await showActivationDialog(context);
    } else if (status.daysRemaining != null && status.daysRemaining! <= 7) {
      // عرض دايلوك التجديد
      await _showRenewalDialog(context, status.daysRemaining!);
    }
  }
  
  static Future<void> _showRenewalDialog(BuildContext context, int daysRemaining) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('تذكير بالتجديد'),
          ],
        ),
        content: Text(
          'سينتهي اشتراك مزامنة التقارير خلال $daysRemaining أيام.\nهل تريد تجديد الاشتراك الآن؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showActivationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('تجديد الآن'),
          ),
        ],
      ),
    );
  }
  
  /// إنشاء زر تفعيل الاشتراك
  static Widget buildActivationButton(BuildContext context) {
    return FutureBuilder<SubscriptionStatus>(
      future: SubscriptionService.getReportsSyncStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        
        final status = snapshot.data!;
        
        if (status.isActive) {
          return _buildActiveSubscriptionButton(context, status);
        } else {
          return _buildInactiveSubscriptionButton(context);
        }
      },
    );
  }
  
  static Widget _buildActiveSubscriptionButton(BuildContext context, SubscriptionStatus status) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_sync, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مزامنة التقارير مفعلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (status.daysRemaining != null)
                  Text(
                    'متبقي ${status.daysRemaining} يوم',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (status.daysRemaining != null && status.daysRemaining! <= 7)
            ElevatedButton(
              onPressed: () => showActivationDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('تجديد'),
            ),
        ],
      ),
    );
  }
  
  static Widget _buildInactiveSubscriptionButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => showActivationDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفعيل مزامنة التقارير',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'اضغط للتفعيل والاستفادة من العروض',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'تفعيل',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// إنشاء عنصر قائمة للاشتراك
  static Widget buildSubscriptionListTile(BuildContext context) {
    return FutureBuilder<SubscriptionStatus>(
      future: SubscriptionService.getReportsSyncStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListTile(
            leading: CircularProgressIndicator(),
            title: Text('جاري التحقق من الاشتراك...'),
          );
        }
        
        final status = snapshot.data!;
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: status.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            child: Icon(
              status.isActive ? Icons.cloud_sync : Icons.cloud_off,
              color: status.isActive ? Colors.green : Colors.grey,
            ),
          ),
          title: Text('مزامنة التقارير السحابية'),
          subtitle: Text(
            status.isActive 
                ? 'مفعل - متبقي ${status.daysRemaining ?? 0} يوم'
                : 'غير مفعل - اضغط للتفعيل',
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => showActivationDialog(context),
        );
      },
    );
  }
  
  /// إنشاء بطاقة الاشتراك للوحة التحكم
  static Widget buildSubscriptionCard(BuildContext context) {
    return FutureBuilder<SubscriptionStatus>(
      future: SubscriptionService.getReportsSyncStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final status = snapshot.data!;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: status.isActive 
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.grey.shade50, Colors.grey.shade100],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      status.isActive ? Icons.cloud_sync : Icons.cloud_off,
                      color: status.isActive ? Colors.green : Colors.grey,
                      size: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'مزامنة التقارير السحابية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.isActive ? 'مفعل' : 'غير مفعل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (status.isActive) ...[
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.grey[600], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'متبقي ${status.daysRemaining ?? 0} يوم',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (status.daysRemaining != null && status.daysRemaining! <= 7)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'ينصح بالتجديد قريباً',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => showActivationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status.isActive ? Colors.blue : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      status.isActive ? 'تجديد الاشتراك' : 'تفعيل الاشتراك',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
