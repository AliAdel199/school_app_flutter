import 'package:flutter/material.dart';
import 'supabase_service.dart';

class PremiumFeaturesService {
  static const Map<String, Map<String, dynamic>> FEATURE_PRICES = {
    'online_reports': {
      'name_ar': 'التقارير الأونلاين',
      'name_en': 'Online Reports',
      'description': 'رفع وحفظ التقارير على السحابة مع إمكانية الوصول من أي مكان',
      'price_monthly': 25000, // 25 ألف دينار شهرياً
      'price_yearly': 250000, // 250 ألف دينار سنوياً
      'currency': 'IQD',
      'features': [
        'رفع التقارير على السحابة',
        'الوصول للتقارير من أي جهاز',
        'نسخ احتياطي آمن',
        'مشاركة التقارير',
        'تخزين غير محدود',
      ]
    },
  };

  // التحقق من حالة الميزة
  static Future<Map<String, dynamic>> checkFeatureStatus(
    int organizationId,
    String featureName,
  ) async {
    final subscriptionStatus = await SupabaseService.checkOrganizationSubscriptionStatus(organizationId);
    
    if (subscriptionStatus == null) {
      return {
        'available': false,
        'reason': 'لا يمكن التحقق من حالة الاشتراك'
      };
    }
    
    final hasFeature = subscriptionStatus['has_$featureName'] == true;
    
    if (!hasFeature) {
      return {
        'available': false,
        'reason': 'الميزة غير مفعلة',
        'can_purchase': true,
        'current_plan': subscriptionStatus['subscription_plan']
      };
    }
    
    return {
      'available': true,
      'expires_at': subscriptionStatus['subscription_expires_at']
    };
  }

  // عرض شاشة شراء الميزة
  static void showPurchaseDialog(
    BuildContext context,
    String featureName,
    int organizationId,
    VoidCallback onPurchaseSuccess,
  ) {
    final featureInfo = FEATURE_PRICES[featureName];
    if (featureInfo == null) return;

    showDialog(
      context: context,
      builder: (context) => PremiumFeaturePurchaseDialog(
        featureName: featureName,
        featureInfo: featureInfo,
        organizationId: organizationId,
        onPurchaseSuccess: onPurchaseSuccess,
      ),
    );
  }
}

// ويدجت شراء الميزة المدفوعة
class PremiumFeaturePurchaseDialog extends StatefulWidget {
  final String featureName;
  final Map<String, dynamic> featureInfo;
  final int organizationId;
  final VoidCallback onPurchaseSuccess;

  const PremiumFeaturePurchaseDialog({
    Key? key,
    required this.featureName,
    required this.featureInfo,
    required this.organizationId,
    required this.onPurchaseSuccess,
  }) : super(key: key);

  @override
  State<PremiumFeaturePurchaseDialog> createState() => _PremiumFeaturePurchaseDialogState();
}

class _PremiumFeaturePurchaseDialogState extends State<PremiumFeaturePurchaseDialog> {
  bool _isLoading = false;
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('شراء ${widget.featureInfo['name_ar']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.featureInfo['description'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // خطط التسعير
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('سنوياً'),
                    subtitle: Text('${widget.featureInfo['price_yearly']} د.ع'),
                    value: 'yearly',
                    groupValue: _selectedPlan,
                    onChanged: (value) => setState(() => _selectedPlan = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('شهرياً'),
                    subtitle: Text('${widget.featureInfo['price_monthly']} د.ع'),
                    value: 'monthly',
                    groupValue: _selectedPlan,
                    onChanged: (value) => setState(() => _selectedPlan = value!),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Text('المميزات المتضمنة:', style: Theme.of(context).textTheme.titleSmall),
            ...List<Widget>.from(
              (widget.featureInfo['features'] as List).map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _purchaseFeature,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('شراء'),
        ),
      ],
    );
  }

  Future<void> _purchaseFeature() async {
    setState(() => _isLoading = true);

    final amount = _selectedPlan == 'yearly'
        ? widget.featureInfo['price_yearly'].toDouble()
        : widget.featureInfo['price_monthly'].toDouble();

    final result = await SupabaseService.purchaseOnlineReportsFeature(
      organizationId: widget.organizationId,
      paymentMethod: 'manual', // يمكن تطويرها لاحقاً
      amount: amount,
      duration: _selectedPlan,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pop(context);
      widget.onPurchaseSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'تم الشراء بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'حدث خطأ أثناء الشراء'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // إرسال طلب شراء بدلاً من الشراء المباشر
  static Future<Map<String, dynamic>> submitPurchaseRequest({
    required int organizationId,
    required String schoolName,
    required String contactEmail,
    String? contactPhone,
    required String featureName,
    required String planDuration,
    String? requestMessage,
  }) async {
    final featureInfo = PremiumFeaturesService.FEATURE_PRICES[featureName];
    if (featureInfo == null) {
      return {
        'success': false,
        'error': 'الميزة المطلوبة غير موجودة'
      };
    }

    final amount = planDuration == 'yearly'
        ? featureInfo['price_yearly'].toDouble()
        : featureInfo['price_monthly'].toDouble();

    return await SupabaseService.submitServicePurchaseRequest(
      organizationId: organizationId,
      schoolName: schoolName,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      requestedService: featureName,
      planDuration: planDuration,
      requestedAmount: amount,
      requestMessage: requestMessage,
    );
  }

  // عرض شاشة طلب الشراء
  static void showPurchaseRequestDialog(
    BuildContext context,
    String featureName,
    int organizationId,
    VoidCallback onRequestSent,
  ) {
    final featureInfo = PremiumFeaturesService.FEATURE_PRICES[featureName];
    if (featureInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الميزة المطلوبة غير متوفرة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // استيراد وعرض شاشة طلب الشراء
    showDialog(
      context: context,
      builder: (context) {
        // سنقوم بإنشاء الشاشة مباشرة هنا لتجنب مشاكل الاستيراد
        return _buildPurchaseRequestDialog(
          context,
          featureName,
          featureInfo,
          organizationId,
          onRequestSent,
        );
      },
    );
  }

  // بناء شاشة طلب الشراء
  static Widget _buildPurchaseRequestDialog(
    BuildContext context,
    String featureName,
    Map<String, dynamic> featureInfo,
    int organizationId,
    VoidCallback onRequestSent,
  ) {
    // استخدام late للإستيراد المتأخر
    return FutureBuilder<Widget>(
      future: _createPurchaseRequestDialog(featureName, featureInfo, organizationId, onRequestSent),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('جاري التحميل...'),
            ],
          ),
        );
      },
    );
  }

  static Future<Widget> _createPurchaseRequestDialog(
    String featureName,
    Map<String, dynamic> featureInfo,
    int organizationId,
    VoidCallback onRequestSent,
  ) async {
    // نستخدم dynamic import هنا
    try {
      // سنحتاج لإنشاء الواجهة مباشرة بدلاً من الاستيراد
      return _SimplePurchaseRequestDialog(
        featureName: featureName,
        featureInfo: featureInfo,
        organizationId: organizationId,
        onRequestSent: onRequestSent,
      );
    } catch (e) {
      return AlertDialog(
        title: const Text('خطأ'),
        content: Text('حدث خطأ في تحميل شاشة الطلب: $e'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('حسناً'),
          ),
        ],
      );
    }
  }
}

// شاشة طلب الشراء المبسطة
class _SimplePurchaseRequestDialog extends StatefulWidget {
  final String featureName;
  final Map<String, dynamic> featureInfo;
  final int organizationId;
  final VoidCallback onRequestSent;

  const _SimplePurchaseRequestDialog({
    required this.featureName,
    required this.featureInfo,
    required this.organizationId,
    required this.onRequestSent,
  });

  @override
  State<_SimplePurchaseRequestDialog> createState() => _SimplePurchaseRequestDialogState();
}

class _SimplePurchaseRequestDialogState extends State<_SimplePurchaseRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController(text: 'مدرسة تجريبية');
  final _emailController = TextEditingController(text: 'test@school.com');
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedPlan = 'yearly';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('طلب شراء ${widget.featureInfo['name_ar']}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _schoolNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المدرسة *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPlan,
                decoration: const InputDecoration(
                  labelText: 'نوع الاشتراك',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text('شهري - ${widget.featureInfo['price_monthly']} د.ع'),
                  ),
                  DropdownMenuItem(
                    value: 'yearly',
                    child: Text('سنوي - ${widget.featureInfo['price_yearly']} د.ع'),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedPlan = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'رسالة إضافية',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitRequest,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('إرسال الطلب'),
        ),
      ],
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final featureInfo = PremiumFeaturesService.FEATURE_PRICES[widget.featureName];
    if (featureInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الميزة غير موجودة'), backgroundColor: Colors.red),
      );
      return;
    }

    final amount = _selectedPlan == 'yearly'
        ? featureInfo['price_yearly'].toDouble()
        : featureInfo['price_monthly'].toDouble();

    final result = await SupabaseService.submitServicePurchaseRequest(
      organizationId: widget.organizationId,
      schoolName: _schoolNameController.text,
      contactEmail: _emailController.text,
      contactPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      requestedService: widget.featureName,
      planDuration: _selectedPlan,
      requestedAmount: amount,
      requestMessage: _messageController.text.isNotEmpty ? _messageController.text : null,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pop(context);
      widget.onRequestSent();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال الطلب بنجاح! رقم الطلب: ${result['request_id']}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
