import 'package:school_app_flutter/services/supabase_service.dart';

Future<void> testSupabaseConnection() async {
  print('🧪 بدء اختبار الاتصال بـ Supabase...');
  
  if (!SupabaseService.isEnabled) {
    print('❌ Supabase غير مفعل');
    return;
  }
  
  try {
    // محاولة الاتصال بجدول المؤسسات التعليمية
    await SupabaseService.client
        .from('educational_organizations')
        .select('id')
        .limit(1);
    
    print('✅ تم الاتصال بـ Supabase بنجاح!');
    print('📊 جدول المؤسسات متوفر');
    
    // اختبار جدول المدارس
    await SupabaseService.client
        .from('schools')
        .select('id')
        .limit(1);
    
    print('🏫 جدول المدارس متوفر');
    print('🎉 جميع الجداول متوفرة ويمكن إنشاء المؤسسة!');
    
  } catch (e) {
    print('❌ فشل الاتصال بـ Supabase: $e');
    
    if (e.toString().contains('host lookup')) {
      print('💡 تحقق من الاتصال بالإنترنت');
    } else if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
      print('💡 الجداول غير موجودة - تحتاج لتنفيذ SQL في Supabase Dashboard');
    }
  }
}

// يمكن استدعاء هذه الدالة من أي مكان في التطبيق لاختبار الاتصال
// مثال: await testSupabaseConnection();
