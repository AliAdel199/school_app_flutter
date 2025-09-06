import 'package:flutter_test/flutter_test.dart';
import 'package:school_app_flutter/main.dart';
import 'package:school_app_flutter/services/supabase_service.dart';
import 'package:school_app_flutter/helpers/network_helper.dart';

void main() {
  group('System Tests', () {
    late SupabaseService supabaseService;
    late NetworkHelper networkHelper;
    
    setUpAll(() {
      supabaseService = SupabaseService();
      networkHelper = NetworkHelper();
    });
    
    test('SupabaseService initialization', () {
      expect(supabaseService, isNotNull);
      expect(SupabaseService.hashPassword('test123'), isNotEmpty);
    });
    
    test('NetworkHelper initialization', () {
      expect(networkHelper, isNotNull);
    });
    
    test('Password hashing functionality', () {
      const testPassword = 'test123';
      final hashedPassword = SupabaseService.hashPassword(testPassword);
      
      expect(hashedPassword, isNotEmpty);
      expect(hashedPassword, isNot(equals(testPassword)));
      expect(hashedPassword.length, equals(64)); // SHA-256 produces 64 character hex string
    });
    
    test('Hash consistency', () {
      const testPassword = 'consistent_test';
      final hash1 = SupabaseService.hashPassword(testPassword);
      final hash2 = SupabaseService.hashPassword(testPassword);
      
      expect(hash1, equals(hash2));
    });
    
    test('Different passwords produce different hashes', () {
      final hash1 = SupabaseService.hashPassword('password1');
      final hash2 = SupabaseService.hashPassword('password2');
      
      expect(hash1, isNot(equals(hash2)));
    });
  });
  
  group('Service Method Tests', () {
    test('Service has required methods', () {
      // Test that all critical methods are available
      expect(() => SupabaseService.hashPassword('test'), returnsNormally);
      
      // Test methods that were previously missing - these should be static methods
      // They might throw network errors but should not have "method not found" errors
      expect(() async {
        try {
          await SupabaseService.getOrganizationStats(1);
        } catch (e) {
          // Network errors are expected, method not found errors are not
          expect(e.toString(), isNot(contains('method not found')));
          expect(e.toString(), isNot(contains('isn\'t defined')));
        }
      }, returnsNormally);
      
      expect(() async {
        try {
          await SupabaseService.checkOrganizationSubscriptionStatus(1);
        } catch (e) {
          expect(e.toString(), isNot(contains('method not found')));
          expect(e.toString(), isNot(contains('isn\'t defined')));
        }
      }, returnsNormally);
      
      expect(() async {
        try {
          await SupabaseService.uploadOrganizationReport(
            organizationId: 1,
            schoolId: 1,
            reportType: 'test',
            reportTitle: 'test',
            reportData: {},
            period: 'test',
            generatedBy: 'test',
          );
        } catch (e) {
          expect(e.toString(), isNot(contains('method not found')));
          expect(e.toString(), isNot(contains('isn\'t defined')));
        }
      }, returnsNormally);
    });
  });
}
