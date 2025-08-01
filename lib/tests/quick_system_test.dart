import '../services/supabase_service.dart';
import '../helpers/network_helper.dart';

class QuickSystemTest {
  static Future<void> runAllTests() async {
    print('🚀 بدء الاختبار السريع للنظام...\n');
    
    // 1. اختبار الشبكة
    await _testNetwork();
    
    // 2. اختبار Supabase
    await _testSupabase();
    
    // 3. اختبار العمليات الأساسية
    await _testBasicOperations();
    
    print('\n🎉 انتهى الاختبار السريع!');
  }
  
  static Future<void> _testNetwork() async {
    print('🌐 اختبار الشبكة...');
    try {
      final status = await NetworkHelper.checkNetworkStatus();
      if (status['is_connected']) {
        print('✅ الشبكة متصلة');
        if (status['can_reach_supabase']) {
          print('✅ يمكن الوصول لـ Supabase');
        } else {
          print('⚠️ لا يمكن الوصول لـ Supabase');
        }
      } else {
        print('❌ لا يوجد اتصال بالشبكة');
      }
    } catch (e) {
      print('❌ خطأ في اختبار الشبكة: $e');
    }
    print('');
  }
  
  static Future<void> _testSupabase() async {
    print('🔗 اختبار Supabase...');
    try {
      final response = await SupabaseService.client
          .from('educational_organizations')
          .select('id')
          .limit(1);
      print('✅ الاتصال مع Supabase يعمل - جلب ${response.length} سجل');
    } catch (e) {
      print('❌ خطأ في الاتصال مع Supabase: $e');
    }
    print('');
  }
  
  static Future<void> _testBasicOperations() async {
    print('⚙️ اختبار العمليات الأساسية...');
    
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // اختبار إنشاء مؤسسة
      print('📝 إنشاء مؤسسة تجريبية...');
      final org = await SupabaseService.createEducationalOrganization(
        name: 'اختبار سريع $timestamp',
        email: 'quicktest$timestamp@example.com',
      );
      
      if (org != null) {
        print('✅ تم إنشاء المؤسسة - ID: ${org['id']}');
        
        // اختبار إنشاء مدرسة
        print('🏫 إنشاء مدرسة تجريبية...');
        final school = await SupabaseService.createSchool(
          organizationId: org['id'],
          name: 'مدرسة اختبار سريع $timestamp',
          schoolType: 'مختلطة',
        );
        
        if (school != null) {
          print('✅ تم إنشاء المدرسة - ID: ${school['id']}');
          
          // اختبار حالة الاشتراك
          print('📊 فحص حالة الاشتراك...');
          final isActive = await SupabaseService.checkOrganizationSubscriptionStatus(org['id']);
          print('✅ حالة الاشتراك: ${isActive ? "نشط" : "غير نشط"}');
          
        } else {
          print('❌ فشل في إنشاء المدرسة');
        }
      } else {
        print('❌ فشل في إنشاء المؤسسة');
      }
    } catch (e) {
      print('❌ خطأ في العمليات الأساسية: $e');
    }
  }
}
