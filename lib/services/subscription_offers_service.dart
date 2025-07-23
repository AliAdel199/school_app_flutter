import 'package:flutter/foundation.dart';
import 'subscription_service.dart';

/// نموذج بيانات العرض
class SubscriptionOffer {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final double originalPrice;
  final double discountedPrice;
  final DateTime validUntil;
  final List<String> conditions;
  final bool isActive;
  final int bonusDays;
  final String currency;
  
  SubscriptionOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.originalPrice,
    required this.discountedPrice,
    required this.validUntil,
    required this.conditions,
    required this.isActive,
    this.bonusDays = 0,
    this.currency = 'د.ع',
  });
  
  bool get isValid => isActive && validUntil.isAfter(DateTime.now());
  
  int get daysUntilExpiry => validUntil.difference(DateTime.now()).inDays;
  
  double get savings => originalPrice - discountedPrice;
}

/// خدمة إدارة العروض والخصومات
class SubscriptionOffersService {
  
  /// الحصول على العروض المتاحة
  static Future<List<SubscriptionOffer>> getAvailableOffers() async {
    try {
      await Future.delayed(Duration(milliseconds: 500)); // محاكاة استدعاء API
      
      return [
        SubscriptionOffer(
          id: 'first_time_50',
          title: 'عرض المرة الأولى',
          description: 'خصم 50% على أول اشتراك في مزامنة التقارير',
          discountPercentage: 50,
          originalPrice: 15000,
          discountedPrice: 7500,
          validUntil: DateTime.now().add(Duration(days: 30)),
          conditions: ['للمشتركين الجدد فقط', 'صالح لمدة شهر واحد'],
          isActive: true,
          currency: 'د.ع',
        ),
        
        SubscriptionOffer(
          id: 'quarterly_discount',
          title: 'اشتراك ربع سنوي',
          description: 'ادفع لـ 3 أشهر واحصل على خصم 20%',
          discountPercentage: 20,
          originalPrice: 45000, // 3 أشهر × 15000
          discountedPrice: 36000,
          validUntil: DateTime.now().add(Duration(days: 90)),
          conditions: ['صالح لمدة 3 أشهر', 'توفير 9000 د.ع'],
          isActive: true,
          currency: 'د.ع',
        ),
        
        SubscriptionOffer(
          id: 'renewal_bonus',
          title: 'مكافأة التجديد المبكر',
          description: 'جدد قبل انتهاء اشتراكك واحصل على 10 أيام إضافية مجاناً',
          discountPercentage: 0,
          originalPrice: 15000,
          discountedPrice: 15000,
          bonusDays: 10,
          validUntil: DateTime.now().add(Duration(days: 60)),
          conditions: ['للتجديد قبل انتهاء الاشتراك الحالي', 'أيام إضافية مجانية'],
          isActive: true,
          currency: 'د.ع',
        ),
        
        SubscriptionOffer(
          id: 'summer_special',
          title: 'عرض الصيف الخاص',
          description: 'خصم 30% على جميع اشتراكات مزامنة التقارير',
          discountPercentage: 30,
          originalPrice: 15000,
          discountedPrice: 10500,
          validUntil: DateTime.now().add(Duration(days: 15)),
          conditions: ['عرض محدود الوقت', 'ينتهي خلال أسبوعين'],
          isActive: true,
          currency: 'د.ع',
        ),
        
        SubscriptionOffer(
          id: 'loyalty_reward',
          title: 'مكافأة الولاء',
          description: 'خصم 25% للعملاء المخلصين',
          discountPercentage: 25,
          originalPrice: 15000,
          discountedPrice: 11250,
          validUntil: DateTime.now().add(Duration(days: 45)),
          conditions: ['للعملاء الذين استخدموا الخدمة أكثر من 3 أشهر'],
          isActive: true,
          currency: 'د.ع',
        ),
      ];
    } catch (e) {
      debugPrint('خطأ في الحصول على العروض: $e');
      return [];
    }
  }
  
  /// الحصول على عرض محدد بالـ ID
  static Future<SubscriptionOffer?> getOfferById(String offerId) async {
    try {
      final offers = await getAvailableOffers();
      return offers.firstWhere(
        (offer) => offer.id == offerId,
        orElse: () => throw Exception('العرض غير موجود'),
      );
    } catch (e) {
      debugPrint('خطأ في الحصول على العرض: $e');
      return null;
    }
  }
  
  /// تطبيق عرض على الاشتراك
  static Future<SubscriptionResult> activateWithOffer(
    String offerId, {
    required String paymentMethod,
    String? transactionId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final offer = await getOfferById(offerId);
      
      if (offer == null) {
        return SubscriptionResult(
          success: false,
          message: 'العرض غير موجود',
        );
      }
      
      if (!offer.isValid) {
        return SubscriptionResult(
          success: false,
          message: 'العرض غير متاح أو منتهي الصلاحية',
        );
      }
      
      // حساب مدة الاشتراك حسب العرض
      int durationDays = 30; // افتراضي شهر واحد
      if (offer.id == 'quarterly_discount') {
        durationDays = 90; // 3 أشهر
      }
      
      // إضافة الأيام الإضافية إن وجدت
      durationDays += offer.bonusDays;
      
      // تفعيل الاشتراك بالسعر المخفض
      final result = await SubscriptionService.activateReportsSync(
        paymentMethod: paymentMethod,
        transactionId: transactionId ?? 'OFFER_${offer.id}_${DateTime.now().millisecondsSinceEpoch}',
        paymentDetails: {
          'offer_applied': offer.id,
          'offer_title': offer.title,
          'original_price': offer.originalPrice,
          'discounted_price': offer.discountedPrice,
          'discount_percentage': offer.discountPercentage,
          'bonus_days': offer.bonusDays,
          'savings': offer.savings,
          'currency': offer.currency,
          'duration_days': durationDays,
          ...?additionalData,
        },
      );
      
      if (result.success) {
        // تسجيل استخدام العرض
        await _recordOfferUsage(offer);
        
        return SubscriptionResult(
          success: true,
          message: 'تم تفعيل الاشتراك بنجاح مع العرض: ${offer.title}\nتوفير: ${offer.savings.toInt()} ${offer.currency}',
        );
      }
      
      return result;
    } catch (e) {
      return SubscriptionResult(
        success: false,
        message: 'خطأ في تطبيق العرض: $e',
      );
    }
  }
  
  /// فحص أهلية المستخدم للحصول على عرض معين
  static Future<bool> isEligibleForOffer(String offerId) async {
    try {
      final offer = await getOfferById(offerId);
      if (offer == null || !offer.isValid) return false;
      
      // فحص الأهلية حسب نوع العرض
      switch (offerId) {
        case 'first_time_50':
          // للمشتركين الجدد فقط
          return await _isFirstTimeUser();
          
        case 'renewal_bonus':
          // للمستخدمين الذين لديهم اشتراك نشط
          return await _hasActiveSubscription();
          
        case 'loyalty_reward':
          // للعملاء المخلصين
          return await _isLoyalCustomer();
          
        default:
          return true; // العروض العامة متاحة للجميع
      }
    } catch (e) {
      debugPrint('خطأ في فحص الأهلية: $e');
      return false;
    }
  }
  
  /// الحصول على العروض المناسبة للمستخدم
  static Future<List<SubscriptionOffer>> getEligibleOffers() async {
    try {
      final allOffers = await getAvailableOffers();
      final eligibleOffers = <SubscriptionOffer>[];
      
      for (final offer in allOffers) {
        if (await isEligibleForOffer(offer.id)) {
          eligibleOffers.add(offer);
        }
      }
      
      // ترتيب العروض حسب نسبة الخصم (الأعلى أولاً)
      eligibleOffers.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
      
      return eligibleOffers;
    } catch (e) {
      debugPrint('خطأ في الحصول على العروض المناسبة: $e');
      return [];
    }
  }
  
  /// حساب التوفير المتوقع من عرض معين
  static double calculateSavings(SubscriptionOffer offer) {
    return offer.originalPrice - offer.discountedPrice;
  }
  
  /// تسجيل استخدام العرض (للإحصائيات)
  static Future<void> _recordOfferUsage(SubscriptionOffer offer) async {
    try {
      final usageData = {
        'offer_id': offer.id,
        'offer_title': offer.title,
        'discount_amount': offer.savings,
        'used_at': DateTime.now().toIso8601String(),
      };
      
      debugPrint('تم استخدام العرض: ${offer.title}');
      debugPrint('بيانات الاستخدام: $usageData');
    } catch (e) {
      debugPrint('خطأ في تسجيل استخدام العرض: $e');
    }
  }
  
  /// فحص إذا كان المستخدم جديد (أول مرة)
  static Future<bool> _isFirstTimeUser() async {
    try {
      final status = await SubscriptionService.getReportsSyncStatus();
      // إذا لم يكن لديه أي اشتراك سابق
      return !status.isActive;
    } catch (e) {
      return true; // افتراض أنه مستخدم جديد في حالة الخطأ
    }
  }
  
  /// فحص إذا كان لديه اشتراك نشط
  static Future<bool> _hasActiveSubscription() async {
    try {
      final status = await SubscriptionService.getReportsSyncStatus();
      return status.isActive;
    } catch (e) {
      return false;
    }
  }
  
  /// فحص إذا كان عميل مخلص (استخدم الخدمة لفترة طويلة)
  static Future<bool> _isLoyalCustomer() async {
    try {
      // منطق لتحديد العميل المخلص
      // يمكن تطوير هذا ليفحص تاريخ الاشتراكات السابقة
      final status = await SubscriptionService.getReportsSyncStatus();
      
      // مثال: إذا كان لديه اشتراك نشط حالياً
      return status.isActive;
    } catch (e) {
      return false;
    }
  }
  
  /// الحصول على أفضل عرض متاح
  static Future<SubscriptionOffer?> getBestAvailableOffer() async {
    try {
      final eligibleOffers = await getEligibleOffers();
      
      if (eligibleOffers.isEmpty) return null;
      
      // العثور على العرض بأعلى توفير
      SubscriptionOffer bestOffer = eligibleOffers.first;
      double maxSavings = calculateSavings(bestOffer);
      
      for (final offer in eligibleOffers) {
        final savings = calculateSavings(offer);
        if (savings > maxSavings) {
          maxSavings = savings;
          bestOffer = offer;
        }
      }
      
      return bestOffer;
    } catch (e) {
      debugPrint('خطأ في الحصول على أفضل عرض: $e');
      return null;
    }
  }
  
  /// إنشاء رسالة ترويجية للعرض
  static String generatePromotionalMessage(SubscriptionOffer offer) {
    final savings = calculateSavings(offer);
    final daysLeft = offer.daysUntilExpiry;
    
    String message = '🎉 ${offer.title}\n\n';
    message += '${offer.description}\n\n';
    
    if (offer.discountPercentage > 0) {
      message += '💰 وفر ${savings.toInt()} ${offer.currency} (${offer.discountPercentage.toInt()}% خصم)\n';
    }
    
    if (offer.bonusDays > 0) {
      message += '🎁 احصل على ${offer.bonusDays} يوم إضافي مجاناً\n';
    }
    
    message += '\n⏰ العرض ينتهي خلال $daysLeft يوم';
    
    if (offer.conditions.isNotEmpty) {
      message += '\n\n📋 الشروط:\n';
      for (final condition in offer.conditions) {
        message += '• $condition\n';
      }
    }
    
    return message;
  }
}
