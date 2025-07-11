import 'package:isar/isar.dart';
import '../localdatabase/auto_discount_settings.dart';

/// مدير إعدادات الخصومات التلقائية
class AutoDiscountSettingsManager {
  final Isar isar;
  
  AutoDiscountSettingsManager(this.isar);

  /// الحصول على الإعدادات الحالية
  Future<AutoDiscountSettings> getSettings() async {
    final settings = await isar.autoDiscountSettings.where().findFirst();
    
    if (settings == null) {
      // إنشاء إعدادات افتراضية
      return await createDefaultSettings();
    }
    
    return settings;
  }

  /// إنشاء إعدادات افتراضية
  Future<AutoDiscountSettings> createDefaultSettings() async {
    final defaultSettings = AutoDiscountSettings()
      ..globalEnabled = true
      ..siblingDiscountEnabled = true
      ..siblingDiscountRate2nd = 10.0
      ..siblingDiscountRate3rd = 15.0
      ..siblingDiscountRate4th = 20.0
      ..earlyPaymentDiscountEnabled = true
      ..earlyPaymentDiscountRate = 5.0
      ..earlyPaymentDays = 30
      ..fullPaymentDiscountEnabled = true
      ..fullPaymentDiscountRate = 3.0
      ..autoApplyOnPayment = true
      ..showNotifications = true
      ..allowDuplicateDiscounts = false
      ..minDiscountAmount = 0.0
      ..maxDiscountAmount = 1000000.0
      ..minDiscountPercentage = 0.0
      ..maxDiscountPercentage = 100.0
      ..lastUpdated = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.autoDiscountSettings.put(defaultSettings);
    });
    
    return defaultSettings;
  }

  /// حفظ الإعدادات
  Future<void> saveSettings(AutoDiscountSettings settings) async {
    settings.lastUpdated = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.autoDiscountSettings.put(settings);
    });
  }

  /// فحص إذا كان النظام مفعل بشكل عام
  Future<bool> isGloballyEnabled() async {
    final settings = await getSettings();
    return settings.globalEnabled;
  }

  /// فحص إذا كان خصم الأشقاء مفعل
  Future<bool> isSiblingDiscountEnabled() async {
    final settings = await getSettings();
    return settings.siblingDiscountEnabled;
  }

  /// فحص إذا كان خصم الدفع المبكر مفعل
  Future<bool> isEarlyPaymentDiscountEnabled() async {
    final settings = await getSettings();
    return settings.earlyPaymentDiscountEnabled;
  }

  /// فحص إذا كان خصم الدفع الكامل مفعل
  Future<bool> isFullPaymentDiscountEnabled() async {
    final settings = await getSettings();
    return settings.fullPaymentDiscountEnabled;
  }

  /// الحصول على نسبة خصم الأشقاء
  Future<double> getSiblingDiscountRate(int siblingOrder) async {
    final settings = await getSettings();
    switch (siblingOrder) {
      case 2:
        return settings.siblingDiscountRate2nd;
      case 3:
        return settings.siblingDiscountRate3rd;
      case 4:
      default:
        return settings.siblingDiscountRate4th;
    }
  }

  /// الحصول على نسبة خصم الدفع المبكر
  Future<double> getEarlyPaymentDiscountRate() async {
    final settings = await getSettings();
    return settings.earlyPaymentDiscountRate;
  }

  /// الحصول على عدد أيام الدفع المبكر
  Future<int> getEarlyPaymentDays() async {
    final settings = await getSettings();
    return settings.earlyPaymentDays;
  }

  /// الحصول على نسبة خصم الدفع الكامل
  Future<double> getFullPaymentDiscountRate() async {
    final settings = await getSettings();
    return settings.fullPaymentDiscountRate;
  }

  /// فحص نوع خصم محدد
  Future<bool> isDiscountTypeEnabled(String discountType) async {
    switch (discountType) {
      case 'sibling':
        return await isSiblingDiscountEnabled();
      case 'early_payment':
        return await isEarlyPaymentDiscountEnabled();
      case 'full_payment':
        return await isFullPaymentDiscountEnabled();
      default:
        return false;
    }
  }

  /// تفعيل أو إيقاف النظام بالكامل
  Future<void> setGlobalEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.globalEnabled = enabled;
    await saveSettings(settings);
  }

  /// تفعيل أو إيقاف خصم الأشقاء
  Future<void> setSiblingDiscountEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.siblingDiscountEnabled = enabled;
    await saveSettings(settings);
  }

  /// تفعيل أو إيقاف خصم الدفع المبكر
  Future<void> setEarlyPaymentDiscountEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.earlyPaymentDiscountEnabled = enabled;
    await saveSettings(settings);
  }

  /// تفعيل أو إيقاف خصم الدفع الكامل
  Future<void> setFullPaymentDiscountEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.fullPaymentDiscountEnabled = enabled;
    await saveSettings(settings);
  }

  /// الحصول على جميع نسب خصم الأشقاء كخريطة
  Future<Map<int, double>> getSiblingDiscountRates() async {
    final settings = await getSettings();
    return {
      1: 0.0, // الطالب الأول لا يحصل على خصم أشقاء
      2: settings.siblingDiscountRate2nd,
      3: settings.siblingDiscountRate3rd,
      4: settings.siblingDiscountRate4th,
    };
  }
}
