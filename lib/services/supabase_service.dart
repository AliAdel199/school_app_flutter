import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://lhzujcquhgxhsmmjwgdq.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoenVqY3F1aGd4aHNtbWp3Z2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MjQ4NjQsImV4cCI6MjA2MTQwMDg2NH0.u7qPHRu_TdmNjPQJhMeXMZVI37xJs8IoX5Dcrg7fxV8';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      print('Supabase initialization error: $e');
    }
  }
  
  // إضافة المدرسة إلى Supabase
  static Future<Map<String, dynamic>?> addSchoolToSupabase({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? logoUrl,
  }) async {
    try {
      final response = await client.from('schools').insert({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'logo_url': logoUrl,
        'subscription_plan': 'basic',
        'subscription_status': 'trial',
        'created_at': DateTime.now().toIso8601String(),
        'trial_expires_at': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      }).select().single();
      
      return response;
    } catch (e) {
      print('Error adding school to Supabase: $e');
      return null;
    }
  }
  
  // التحقق من حالة الاشتراك
  static Future<bool> checkSubscriptionStatus(int schoolId) async {
    try {
      final response = await client
          .from('schools')
          .select('subscription_status, trial_expires_at')
          .eq('id', schoolId)
          .single();
      
      if (response['subscription_status'] == 'trial') {
        final trialExpiry = DateTime.parse(response['trial_expires_at']);
        return DateTime.now().isBefore(trialExpiry);
      }
      
      return response['subscription_status'] == 'active';
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }
  
  // رفع التقارير للسحابة
  static Future<bool> uploadReport({
    required int schoolId,
    required String reportType,
    required Map<String, dynamic> reportData,
  }) async {
    try {
      await client.from('reports').insert({
        'school_id': schoolId,
        'report_type': reportType,
        'report_data': reportData,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Error uploading report: $e');
      return false;
    }
  }
}
