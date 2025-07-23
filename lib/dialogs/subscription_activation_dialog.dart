import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/subscription_service.dart';
import '../services/subscription_notifications_service.dart';
import '../services/subscription_offers_service.dart';

/// دايلوك تفعيل اشتراك مزامنة التقارير
class SubscriptionActivationDialog extends StatefulWidget {
  final bool showOffers;
  final String? preSelectedOfferId;
  
  const SubscriptionActivationDialog({
    Key? key,
    this.showOffers = true,
    this.preSelectedOfferId,
  }) : super(key: key);
  
  /// عرض الدايلوك
  static Future<bool?> show(
    BuildContext context, {
    bool showOffers = true,
    String? preSelectedOfferId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubscriptionActivationDialog(
        showOffers: showOffers,
        preSelectedOfferId: preSelectedOfferId,
      ),
    );
  }
  
  @override
  _SubscriptionActivationDialogState createState() => _SubscriptionActivationDialogState();
}

class _SubscriptionActivationDialogState extends State<SubscriptionActivationDialog>
    with TickerProviderStateMixin {
  final TextEditingController _activationCodeController = TextEditingController();
  bool _isLoading = false;
  bool _showOffers = false;
  String? _selectedOfferId;
  List<SubscriptionOffer> _availableOffers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _showOffers = widget.showOffers;
    _selectedOfferId = widget.preSelectedOfferId;
    
    // إعداد الانيميشن
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
    _loadOffers();
  }
  
  @override
  void dispose() {
    _activationCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadOffers() async {
    if (!_showOffers) return;
    
    try {
      final offers = await SubscriptionOffersService.getAvailableOffers();
      setState(() {
        _availableOffers = offers;
        
        // اختيار أفضل عرض تلقائياً إذا لم يتم تحديد عرض مسبقاً
        if (_selectedOfferId == null && offers.isNotEmpty) {
          final bestOffer = offers.reduce((a, b) => 
            a.discountPercentage > b.discountPercentage ? a : b
          );
          _selectedOfferId = bestOffer.id;
        }
      });
    } catch (e) {
      debugPrint('خطأ في تحميل العروض: $e');
    }
  }
  
  Future<void> _activateSubscription() async {
    if (_activationCodeController.text.trim().isEmpty) {
      _showError('يرجى إدخال كود التفعيل');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      bool success = false;
      
      if (_selectedOfferId != null) {
        // تفعيل مع عرض
        final result = await SubscriptionOffersService.activateWithOffer(
          _selectedOfferId!,
          paymentMethod: 'activation_code',
        );
        success = result.success;
      } else {
        // تفعيل عادي
        final result = await SubscriptionService.activateReportsSync(
          paymentMethod: 'activation_code',
        );
        success = result.success;
      }
      
      if (success) {
        // إرسال إشعار نجاح التفعيل
        await SubscriptionNotificationsService.sendActivationSuccessNotification();
        
        // عرض رسالة نجاح
        await _showSuccessDialog();
        
        Navigator.of(context).pop(true);
      } else {
        _showError('كود التفعيل غير صحيح أو منتهي الصلاحية');
      }
    } catch (e) {
      _showError('حدث خطأ أثناء التفعيل: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'تم التفعيل بنجاح! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'يمكنك الآن الاستمتاع بمزامنة التقارير السحابية',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text('رائع!'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildActivationCodeField(),
                        if (_showOffers && _availableOffers.isNotEmpty) ...[
                          SizedBox(height: 20),
                          _buildOffersSection(),
                        ],
                        SizedBox(height: 20),
                        _buildPricingInfo(),
                        SizedBox(height: 30),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.cloud_sync,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفعيل اشتراك التقارير',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'استمتع بمزامنة التقارير السحابية',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivationCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كود التفعيل',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _activationCodeController,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل كود التفعيل',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              letterSpacing: 1,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            prefixIcon: Icon(Icons.key, color: Colors.blue),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          inputFormatters: [
            UpperCaseTextFormatter(),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
          ],
        ),
      ],
    );
  }
  
  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'العروض المتاحة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ..._availableOffers.map((offer) => _buildOfferTile(offer)),
      ],
    );
  }
  
  Widget _buildOfferTile(SubscriptionOffer offer) {
    final isSelected = _selectedOfferId == offer.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOfferId = isSelected ? null : offer.id;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        offer.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${offer.discountPercentage}% خصم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    offer.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (offer.savings > 0)
              Text(
                'توفر ${offer.savings.toInt()} د.ع',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPricingInfo() {
    final selectedOffer = _availableOffers.firstWhere(
      (offer) => offer.id == _selectedOfferId,
      orElse: () => SubscriptionOffer(
        id: 'regular',
        title: 'اشتراك عادي',
        description: 'اشتراك شهري عادي',
        originalPrice: 15000,
        discountedPrice: 15000,
        discountPercentage: 0,
        validUntil: DateTime.now().add(Duration(days: 30)),
        conditions: [],
        isActive: true,
      ),
    );
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('السعر الأصلي:'),
              Text(
                '${selectedOffer.originalPrice} د.ع',
                style: TextStyle(
                  decoration: selectedOffer.discountPercentage > 0
                      ? TextDecoration.lineThrough
                      : null,
                  color: selectedOffer.discountPercentage > 0
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ],
          ),
          if (selectedOffer.discountPercentage > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الخصم:'),
                Text(
                  '-${selectedOffer.savings.toInt()} د.ع',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السعر النهائي:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${selectedOffer.discountedPrice.toInt()} د.ع',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _activateSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 3,
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('جاري التفعيل...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_sync),
                      SizedBox(width: 8),
                      Text(
                        'تفعيل الاشتراك',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Formatter لتحويل النص إلى أحرف كبيرة
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
