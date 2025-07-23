import 'package:flutter/material.dart';
import '../services/subscription_offers_service.dart';
import '../services/subscription_notifications_service.dart';

class SubscriptionOffersScreen extends StatefulWidget {
  @override
  _SubscriptionOffersScreenState createState() => _SubscriptionOffersScreenState();
}

class _SubscriptionOffersScreenState extends State<SubscriptionOffersScreen> {
  List<SubscriptionOffer> offers = [];
  bool isLoading = true;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadOffers();
  }
  
  Future<void> _loadOffers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final availableOffers = await SubscriptionOffersService.getEligibleOffers();
      setState(() {
        offers = availableOffers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل العروض: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_offer, color: Colors.white),
            SizedBox(width: 8),
            Text('العروض والخصومات'),
          ],
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadOffers,
            icon: Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.withOpacity(0.1), Colors.white],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }
  
  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'جاري تحميل العروض...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    if (errorMessage != null) {
      return _buildErrorWidget();
    }
    
    if (offers.isEmpty) {
      return _buildNoOffersWidget();
    }
    
    return _buildOffersList();
  }
  
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOffers,
              icon: Icon(Icons.refresh),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoOffersWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: Colors.grey[400]),
            SizedBox(height: 24),
            Text(
              'لا توجد عروض متاحة حالياً',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'تحقق لاحقاً للحصول على عروض وخصومات جديدة',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOffers,
              icon: Icon(Icons.refresh),
              label: Text('تحديث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOffersList() {
    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: Colors.purple,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: offers.length + 1, // +1 للعنوان
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderCard();
          }
          
          final offer = offers[index - 1];
          return _buildOfferCard(offer);
        },
      ),
    );
  }
  
  Widget _buildHeaderCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[600]!, Colors.purple[400]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.celebration, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'عروض خاصة لك!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'وفر المال واحصل على أفضل قيمة لاشتراكك',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOfferCard(SubscriptionOffer offer) {
    final isExpiringSoon = offer.daysUntilExpiry <= 3;
    final isHighDiscount = offer.discountPercentage >= 30;
    
    return Card(
      elevation: 6,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isHighDiscount
                ? [Colors.orange[100]!, Colors.orange[50]!]
                : [Colors.blue[100]!, Colors.blue[50]!],
          ),
          border: isExpiringSoon 
              ? Border.all(color: Colors.red, width: 2)
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: العنوان والخصم
              Row(
                children: [
                  Expanded(
                    child: Text(
                      offer.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (offer.discountPercentage > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHighDiscount ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${offer.discountPercentage.toInt()}% خصم',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // الوصف
              Text(
                offer.description,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 16),
              
              // الأسعار
              Row(
                children: [
                  if (offer.discountPercentage > 0) ...[
                    Text(
                      '${offer.originalPrice.toInt()} ${offer.currency}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                  Text(
                    '${offer.discountedPrice.toInt()} ${offer.currency}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Spacer(),
                  if (offer.bonusDays > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${offer.bonusDays} يوم مجاناً',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // التوفير
              if (offer.savings > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.savings, size: 16, color: Colors.green[700]),
                      SizedBox(width: 6),
                      Text(
                        'توفر ${offer.savings.toInt()} ${offer.currency}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 16),
              
              // الشروط
              if (offer.conditions.isNotEmpty) ...[
                Text(
                  'الشروط:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 6),
                ...offer.conditions.take(2).map((condition) => Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: Colors.grey[600])),
                      Expanded(
                        child: Text(
                          condition,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                )),
                if (offer.conditions.length > 2)
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      '... والمزيد',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ),
                SizedBox(height: 12),
              ],
              
              // تاريخ انتهاء العرض
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isExpiringSoon ? Colors.red : Colors.grey[600],
                  ),
                  SizedBox(width: 6),
                  Text(
                    isExpiringSoon
                        ? 'ينتهي خلال ${offer.daysUntilExpiry} أيام!'
                        : 'ينتهي في: ${_formatDate(offer.validUntil)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpiringSoon ? Colors.red : Colors.grey[600],
                      fontWeight: isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // زر التفعيل
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: offer.isValid ? () => _showActivationDialog(offer) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighDiscount ? Colors.orange[600] : Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(offer.isValid ? Icons.flash_on : Icons.lock),
                      SizedBox(width: 8),
                      Text(
                        offer.isValid ? 'تفعيل هذا العرض' : 'العرض منتهي الصلاحية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _showActivationDialog(SubscriptionOffer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.local_offer, color: Colors.purple),
            SizedBox(width: 8),
            Expanded(child: Text('تأكيد تفعيل العرض')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد تفعيل العرض التالي؟'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text('السعر: ${offer.discountedPrice.toInt()} ${offer.currency}'),
                  if (offer.discountPercentage > 0)
                    Text('خصم: ${offer.discountPercentage.toInt()}%'),
                  if (offer.bonusDays > 0)
                    Text('مكافأة: ${offer.bonusDays} يوم إضافي'),
                  if (offer.savings > 0)
                    Text(
                      'التوفير: ${offer.savings.toInt()} ${offer.currency}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('تفعيل العرض'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _activateOffer(offer);
    }
  }
  
  Future<void> _activateOffer(SubscriptionOffer offer) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(width: 16),
            Expanded(child: Text('جاري تفعيل العرض...')),
          ],
        ),
      ),
    );
    
    try {
      final result = await SubscriptionOffersService.activateWithOffer(
        offer.id,
        paymentMethod: 'manual',
        transactionId: 'OFFER_${offer.id}_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      Navigator.pop(context); // إغلاق dialog التحميل
      
      if (result.success) {
        // إرسال إشعار نجاح
        await SubscriptionNotificationsService.sendActivationSuccessNotification();
        
        // عرض رسالة نجاح
        _showSuccessDialog(result.message);
        
        // العودة مع إشارة نجاح
        Navigator.pop(context, true);
      } else {
        _showSnackBar(result.message, Colors.red);
      }
    } catch (e) {
      Navigator.pop(context); // إغلاق dialog التحميل
      _showSnackBar('خطأ في تفعيل العرض: $e', Colors.red);
    }
  }
  
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('تم بنجاح!'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('ممتاز'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.red ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
