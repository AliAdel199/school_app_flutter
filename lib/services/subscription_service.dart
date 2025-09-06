import '../services/database_service.dart';

/// خدمة إدارة الاشتراكات والتراخيص
/// تدير حالة الاشتراكات والميزات المختلفة
class SubscriptionService {
  
  /// التحقق من حالة اشتراك المؤسسة
  static Future<Map<String, dynamic>?> checkOrganizationSubscriptionStatus(int organizationId) async {
    if (!DatabaseService.isEnabled) return null;
    
    try {
      return await DatabaseService.executeWithRetry<Map<String, dynamic>?>(
        () async {
          print('🔄 جاري التحقق من حالة الاشتراك للمؤسسة: $organizationId');
          
          // جلب معلومات المؤسسة من view خاص
          final response = await DatabaseService.client
              .from('license_status_view')
              .select('*')
              .eq('id', organizationId)
              .maybeSingle();
          
          if (response == null) {
            print('⚠️ لم يتم العثور على المؤسسة بالمعرف: $organizationId');
            return null;
          }
          
          final status = response['subscription_status'] as String?;
          final isActive = response['is_active'] as bool? ?? false;
          final plan = response['subscription_plan'] as String?;
          final trialExpiresAt = response['trial_expires_at'] as String?;
          final subscriptionExpiresAt = response['subscription_expires_at'] as String?;
          
          // التحقق من الميزات المتاحة حسب الباقة
          Map<String, bool> features = {
            'basic_features': true, // متاح في جميع الباقات
            'student_management': true,
            'financial_management': true,
            'local_reports': true,
            'online_reports': false,
            'advanced_analytics': false,
            'multi_school_management': false,
            'api_access': false,
            'priority_support': false,
          };
          
          // تحديد الميزات حسب نوع الباقة
          if (plan == 'premium' || plan == 'enterprise') {
            features['online_reports'] = true;
            features['advanced_analytics'] = true;
            
            if (plan == 'enterprise') {
              features['multi_school_management'] = true;
              features['api_access'] = true;
              features['priority_support'] = true;
            }
          }
          
          // التحقق من الميزات المشتراة منفصلة
          final purchasedFeatures = await _getOrganizationPurchasedFeatures(organizationId);
          for (final feature in purchasedFeatures) {
            features[feature] = true;
          }
          
          print('✅ تم جلب حالة الاشتراك بنجاح');
          
          return {
            'organization_id': organizationId,
            'subscription_status': status,
            'subscription_plan': plan,
            'is_active': isActive,
            'trial_expires_at': trialExpiresAt,
            'subscription_expires_at': subscriptionExpiresAt,
            'features': features,
            'has_online_reports': features['online_reports'] ?? false,
            'has_advanced_analytics': features['advanced_analytics'] ?? false,
            'can_manage_multiple_schools': features['multi_school_management'] ?? false,
            'days_remaining': _calculateDaysRemaining(status, trialExpiresAt, subscriptionExpiresAt),
          };
        },
        operationName: 'التحقق من حالة الاشتراك',
      );
    } catch (e) {
      print('❌ خطأ في التحقق من حالة الاشتراك: $e');
      return null;
    }
  }

  /// حساب الأيام المتبقية في الاشتراك
  static int? _calculateDaysRemaining(String? status, String? trialExpiresAt, String? subscriptionExpiresAt) {
    try {
      DateTime? expiryDate;
      
      if (status == 'trial' && trialExpiresAt != null) {
        expiryDate = DateTime.parse(trialExpiresAt);
      } else if (status == 'active' && subscriptionExpiresAt != null) {
        expiryDate = DateTime.parse(subscriptionExpiresAt);
      }
      
      if (expiryDate != null) {
        final now = DateTime.now();
        final difference = expiryDate.difference(now).inDays;
        return difference > 0 ? difference : 0;
      }
      
      return null;
    } catch (e) {
      print('❌ خطأ في حساب الأيام المتبقية: $e');
      return null;
    }
  }

  /// جلب الميزات المشتراة للمؤسسة
  static Future<List<String>> _getOrganizationPurchasedFeatures(int organizationId) async {
    try {
      final response = await DatabaseService.client
          .from('feature_purchases')
          .select('feature_name, expires_at')
          .eq('organization_id', organizationId)
          .eq('status', 'active');
      
      final features = <String>[];
      for (final purchase in response) {
        final expiresAt = purchase['expires_at'] as String?;
        
        // التحقق من تاريخ الانتهاء
        if (expiresAt == null || DateTime.parse(expiresAt).isAfter(DateTime.now())) {
          features.add(purchase['feature_name'] as String);
        }
      }
      
      return features;
    } catch (e) {
      print('❌ خطأ في جلب الميزات المشتراة: $e');
      return [];
    }
  }

  /// التحقق من ميزة محددة
  static Future<bool> checkFeatureAccess(int organizationId, String featureName) async {
    final subscriptionStatus = await checkOrganizationSubscriptionStatus(organizationId);
    if (subscriptionStatus == null) return false;
    
    final features = subscriptionStatus['features'] as Map<String, bool>? ?? {};
    return features[featureName] ?? false;
  }

  /// شراء ميزة إضافية
  static Future<Map<String, dynamic>> purchaseFeature({
    required int organizationId,
    required String featureName,
    required String paymentMethod,
    required double amount,
    required String duration, // 'monthly', 'yearly', 'lifetime'
    String? transactionId,
  }) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
      };
    }
    
    try {
      DateTime? expiresAt;
      if (duration == 'monthly') {
        expiresAt = DateTime.now().add(const Duration(days: 30));
      } else if (duration == 'yearly') {
        expiresAt = DateTime.now().add(const Duration(days: 365));
      }
      // lifetime = null (لا تنتهي)
      
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('feature_purchases')
              .insert({
                'organization_id': organizationId,
                'feature_name': featureName,
                'payment_method': paymentMethod,
                'amount': amount,
                'currency': 'IQD',
                'duration': duration,
                'expires_at': expiresAt?.toIso8601String(),
                'status': 'active',
                'transaction_id': transactionId,
                'purchase_date': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
        },
        operationName: 'شراء ميزة',
      );
      
      if (result != null) {
        return {
          'success': true,
          'purchase_id': result['id'],
          'feature_name': featureName,
          'expires_at': expiresAt?.toIso8601String(),
          'message': 'تم شراء الميزة بنجاح',
        };
      }
      
      return {
        'success': false,
        'error': 'فشل في تسجيل عملية الشراء',
      };
    } catch (e) {
      print('❌ خطأ في شراء الميزة: $e');
      return {
        'success': false,
        'error': 'خطأ في عملية الشراء: $e',
      };
    }
  }

  /// إرسال طلب شراء خدمة
  static Future<Map<String, dynamic>> submitServicePurchaseRequest({
    required int organizationId,
    required String schoolName,
    required String contactEmail,
    String? contactPhone,
    required String requestedService,
    required String planDuration,
    required double requestedAmount,
    String? requestMessage,
  }) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
      };
    }
    
    try {
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('service_purchase_requests')
              .insert({
                'organization_id': organizationId,
                'school_name': schoolName,
                'contact_email': contactEmail,
                'contact_phone': contactPhone,
                'requested_service': requestedService,
                'plan_duration': planDuration,
                'requested_amount': requestedAmount,
                'currency': 'IQD',
                'request_message': requestMessage,
                'request_status': 'pending',
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
        },
        operationName: 'إرسال طلب شراء',
      );
      
      if (result != null) {
        return {
          'success': true,
          'request_id': result['id'],
          'status': 'pending',
          'message': 'تم إرسال طلب الشراء بنجاح. سنتواصل معك قريباً.',
        };
      }
      
      return {
        'success': false,
        'error': 'فشل في إرسال طلب الشراء',
      };
    } catch (e) {
      print('❌ خطأ في إرسال طلب الشراء: $e');
      return {
        'success': false,
        'error': 'خطأ في إرسال الطلب: $e',
      };
    }
  }

  /// الحصول على جميع الاشتراكات (للمديرين)
  static Future<Map<String, dynamic>> getAllSubscriptions() async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
        'subscriptions': [],
      };
    }

    try {
      final response = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('license_status_view')
              .select('*')
              .order('created_at', ascending: false);
        },
        operationName: 'جلب جميع الاشتراكات',
      );

      if (response == null) {
        return {
          'success': false,
          'error': 'فشل في جلب البيانات',
          'subscriptions': [],
        };
      }

      // تحويل البيانات لتسهيل العرض
      final subscriptions = response.map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
          'email': item['email'],
          'subscription_status': item['subscription_status'],
          'subscription_plan': item['subscription_plan'],
          'is_active': item['is_active'],
          'trial_expires_at': item['trial_expires_at'],
          'subscription_expires_at': item['subscription_expires_at'],
          'days_remaining': _calculateDaysRemaining(
            item['subscription_status'],
            item['trial_expires_at'],
            item['subscription_expires_at'],
          ),
        };
      }).toList();

      return {
        'success': true,
        'subscriptions': subscriptions,
        'total': subscriptions.length,
      };

    } catch (e) {
      print('❌ خطأ في جلب جميع الاشتراكات: $e');
      return {
        'success': false,
        'error': 'خطأ في جلب البيانات: $e',
        'subscriptions': [],
      };
    }
  }

  /// تحديث حالة اشتراك المؤسسة
  static Future<Map<String, dynamic>> updateOrganizationSubscription({
    required int organizationId,
    String? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? subscriptionExpiresAt,
    String? updatedBy,
  }) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
      };
    }
    
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (subscriptionStatus != null) {
        updateData['subscription_status'] = subscriptionStatus;
      }
      
      if (subscriptionPlan != null) {
        updateData['subscription_plan'] = subscriptionPlan;
      }
      
      if (subscriptionExpiresAt != null) {
        updateData['subscription_expires_at'] = subscriptionExpiresAt.toIso8601String();
      }
      
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('educational_organizations')
              .update(updateData)
              .eq('id', organizationId)
              .select()
              .single();
        },
        operationName: 'تحديث الاشتراك',
      );
      
      if (result != null) {
        return {
          'success': true,
          'organization_id': organizationId,
          'message': 'تم تحديث الاشتراك بنجاح',
        };
      }
      
      return {
        'success': false,
        'error': 'فشل في تحديث الاشتراك',
      };
    } catch (e) {
      print('❌ خطأ في تحديث الاشتراك: $e');
      return {
        'success': false,
        'error': 'خطأ في تحديث الاشتراك: $e',
      };
    }
  }

  /// التحقق من ترخيص محدد بالإيميل
  static Future<Map<String, dynamic>?> checkLicenseByEmail(String email) async {
    if (!DatabaseService.isEnabled) return null;
    
    try {
      final response = await DatabaseService.client
          .from('license_status_view')
          .select('*')
          .eq('email', email)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('❌ خطأ في فحص حالة الترخيص: $e');
      return null;
    }
  }

  /// تجديد فترة التجربة للمؤسسة
  static Future<Map<String, dynamic>> extendTrial({
    required int organizationId,
    required int additionalDays,
    String? reason,
  }) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
      };
    }
    
    try {
      // الحصول على تاريخ انتهاء التجربة الحالي
      final currentOrg = await DatabaseService.client
          .from('educational_organizations')
          .select('trial_expires_at')
          .eq('id', organizationId)
          .single();
      
      final currentExpiryString = currentOrg['trial_expires_at'] as String?;
      final currentExpiry = currentExpiryString != null 
          ? DateTime.parse(currentExpiryString)
          : DateTime.now();
      
      final newExpiry = currentExpiry.add(Duration(days: additionalDays));
      
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('educational_organizations')
              .update({
                'trial_expires_at': newExpiry.toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', organizationId)
              .select()
              .single();
        },
        operationName: 'تمديد فترة التجربة',
      );
      
      if (result != null) {
        return {
          'success': true,
          'organization_id': organizationId,
          'new_expiry': newExpiry.toIso8601String(),
          'additional_days': additionalDays,
          'message': 'تم تمديد فترة التجربة بنجاح',
        };
      }
      
      return {
        'success': false,
        'error': 'فشل في تمديد فترة التجربة',
      };
    } catch (e) {
      print('❌ خطأ في تمديد فترة التجربة: $e');
      return {
        'success': false,
        'error': 'خطأ في تمديد فترة التجربة: $e',
      };
    }
  }
}
