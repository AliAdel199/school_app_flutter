import 'package:isar/isar.dart';
import 'package:school_app_flutter/services/supabase_service.dart';
import 'package:school_app_flutter/localdatabase/school.dart';
import '../main.dart';

class OnlineReportsService {
  static Future<bool> isOnlineReportsAvailable() async {
    try {
      final schools = await isar.schools.where().findAll();
      if (schools.isEmpty) return false;
      
      final school = schools.first;
      if (school.supabaseId == null) return false;
      
      return await SupabaseService.checkSubscriptionStatus(school.supabaseId!);
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> uploadFinancialReport({
    required Map<String, dynamic> reportData,
  }) async {
    try {
      final schools = await isar.schools.where().findAll();
      if (schools.isEmpty || schools.first.supabaseId == null) return false;
      
      return await SupabaseService.uploadReport(
        schoolId: schools.first.supabaseId!,
        reportType: 'financial',
        reportData: reportData,
      );
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> uploadStudentReport({
    required Map<String, dynamic> reportData,
  }) async {
    try {
      final schools = await isar.schools.where().findAll();
      if (schools.isEmpty || schools.first.supabaseId == null) return false;
      
      return await SupabaseService.uploadReport(
        schoolId: schools.first.supabaseId!,
        reportType: 'students',
        reportData: reportData,
      );
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> uploadEmployeeReport({
    required Map<String, dynamic> reportData,
  }) async {
    try {
      final schools = await isar.schools.where().findAll();
      if (schools.isEmpty || schools.first.supabaseId == null) return false;
      
      return await SupabaseService.uploadReport(
        schoolId: schools.first.supabaseId!,
        reportType: 'employees',
        reportData: reportData,
      );
    } catch (e) {
      return false;
    }
  }
}
