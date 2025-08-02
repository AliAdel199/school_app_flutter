import 'dart:convert';
import 'package:http/http.dart' as http;

/// اختبار مباشر لجلب التقارير من Supabase
/// بدون dependencies معقدة
Future<void> testDirectFetch() async {
  print('🔄 اختبار مباشر لجلب التقارير...');
  
  // معلومات الاتصال بـ Supabase (يجب تحديثها)
  const supabaseUrl = 'https://your-project.supabase.co';
  const supabaseKey = 'your-anon-key';
  
  try {
    // جلب التقارير مباشرة
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/school_reports?select=*,schools(name)&limit=10'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final reports = json.decode(response.body) as List;
      print('✅ تم جلب ${reports.length} تقرير بنجاح');
      
      for (var report in reports) {
        print('📄 ${report['report_title']} - ${report['academic_year']}');
        print('   الطلاب: ${report['total_students']} | الرصيد: ${report['net_balance']} د.ع');
      }
    } else {
      print('❌ خطأ في الطلب: ${response.statusCode}');
      print('الرسالة: ${response.body}');
    }
    
  } catch (e) {
    print('❌ خطأ في الاتصال: $e');
  }
}

/// اختبار رفع تقرير بسيط
Future<void> testDirectUpload() async {
  print('🔄 اختبار رفع تقرير...');
  
  const supabaseUrl = 'https://your-project.supabase.co';
  const supabaseKey = 'your-anon-key';
  
  final reportData = {
    'organization_id': 1,
    'school_id': 1,
    'report_title': 'تقرير اختبار مباشر',
    'report_type': 'general',
    'academic_year': '2024-2025',
    'total_students': 100,
    'active_students': 95,
    'inactive_students': 5,
    'graduated_students': 0,
    'withdrawn_students': 0,
    'total_annual_fees': 10000000,
    'total_paid': 8000000,
    'total_due': 2000000,
    'total_incomes': 8000000,
    'total_expenses': 6000000,
    'net_balance': 2000000,
    'report_generated_by': 'اختبار مباشر',
    'generated_at': DateTime.now().toIso8601String(),
  };
  
  try {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/school_reports'),
      headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: json.encode(reportData),
    );
    
    if (response.statusCode == 201) {
      final result = json.decode(response.body);
      print('✅ تم رفع التقرير بنجاح: ${result.first['id']}');
    } else {
      print('❌ خطأ في الرفع: ${response.statusCode}');
      print('الرسالة: ${response.body}');
    }
    
  } catch (e) {
    print('❌ خطأ في الرفع: $e');
  }
}

void main() async {
  await testDirectFetch();
  await testDirectUpload();
}
