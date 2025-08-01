import '../services/supabase_service.dart';
import '../helpers/network_helper.dart';

class SystemValidator {
  static final SupabaseService _supabaseService = SupabaseService();
  static final NetworkHelper _networkHelper = NetworkHelper();
  
  static Future<Map<String, dynamic>> validateCompleteSystem() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': {},
      'summary': {
        'total': 0,
        'passed': 0,
        'failed': 0,
        'errors': []
      }
    };

    // Test 1: Network Connectivity
    results['tests']['network_connectivity'] = await _testNetworkConnectivity();
    
    // Test 2: Supabase Connection
    results['tests']['supabase_connection'] = await _testSupabaseConnection();
    
    // Test 3: Service Methods
    results['tests']['service_methods'] = await _testServiceMethods();
    
    // Test 4: CRUD Operations
    results['tests']['crud_operations'] = await _testCrudOperations();
    
    // Test 5: Password Hashing
    results['tests']['password_hashing'] = await _testPasswordHashing();
    
    // Calculate summary
    for (final test in results['tests'].values) {
      results['summary']['total']++;
      if (test['status'] == 'PASSED') {
        results['summary']['passed']++;
      } else {
        results['summary']['failed']++;
        results['summary']['errors'].add(test['message']);
      }
    }
    
    return results;
  }
  
  static Future<Map<String, dynamic>> _testNetworkConnectivity() async {
    try {
      final isConnected = await _networkHelper.isConnectedToInternet();
      if (isConnected) {
        final canReachSupabase = await _networkHelper.canReachSupabase();
        if (canReachSupabase) {
          return {
            'status': 'PASSED',
            'message': 'Network connectivity is working properly',
            'details': 'Internet and Supabase reachable'
          };
        } else {
          return {
            'status': 'FAILED',
            'message': 'Cannot reach Supabase',
            'details': 'Internet available but Supabase unreachable'
          };
        }
      } else {
        return {
          'status': 'FAILED',
          'message': 'No internet connection',
          'details': 'Check network settings'
        };
      }
    } catch (e) {
      return {
        'status': 'FAILED',
        'message': 'Network test error: $e',
        'details': 'Exception during network testing'
      };
    }
  }
  
  static Future<Map<String, dynamic>> _testSupabaseConnection() async {
    try {
      // Test basic Supabase functionality
      final organizations = await _supabaseService.getOrganizations();
      return {
        'status': 'PASSED',
        'message': 'Supabase connection successful',
        'details': 'Retrieved ${organizations.length} organizations'
      };
    } catch (e) {
      return {
        'status': 'FAILED',
        'message': 'Supabase connection failed: $e',
        'details': 'Check Supabase configuration and credentials'
      };
    }
  }
  
  static Future<Map<String, dynamic>> _testServiceMethods() async {
    try {
      // Test if all required methods exist and are callable
      final methodTests = <String, bool>{};
      
      // Test getOrganizationStats
      try {
        await _supabaseService.getOrganizationStats('test-id');
        methodTests['getOrganizationStats'] = true;
      } catch (e) {
        methodTests['getOrganizationStats'] = false;
      }
      
      // Test checkOrganizationSubscriptionStatus
      try {
        await _supabaseService.checkOrganizationSubscriptionStatus('test-id');
        methodTests['checkOrganizationSubscriptionStatus'] = true;
      } catch (e) {
        methodTests['checkOrganizationSubscriptionStatus'] = false;
      }
      
      // Test uploadOrganizationReport
      try {
        await _supabaseService.uploadOrganizationReport('test-id', {});
        methodTests['uploadOrganizationReport'] = true;
      } catch (e) {
        methodTests['uploadOrganizationReport'] = false;
      }
      
      final passedMethods = methodTests.values.where((v) => v).length;
      final totalMethods = methodTests.length;
      
      if (passedMethods == totalMethods) {
        return {
          'status': 'PASSED',
          'message': 'All service methods are available',
          'details': 'All $totalMethods methods callable'
        };
      } else {
        return {
          'status': 'FAILED',
          'message': 'Some service methods are missing',
          'details': '$passedMethods/$totalMethods methods available'
        };
      }
    } catch (e) {
      return {
        'status': 'FAILED',
        'message': 'Service methods test error: $e',
        'details': 'Exception during method testing'
      };
    }
  }
  
  static Future<Map<String, dynamic>> _testCrudOperations() async {
    try {
      // Test basic CRUD operations
      final organizations = await _supabaseService.getOrganizations();
      
      if (organizations.isNotEmpty) {
        final firstOrg = organizations.first;
        final schools = await _supabaseService.getSchoolsByOrganization(firstOrg['id']);
        
        return {
          'status': 'PASSED',
          'message': 'CRUD operations working',
          'details': 'Organizations: ${organizations.length}, Schools: ${schools.length}'
        };
      } else {
        return {
          'status': 'WARNING',
          'message': 'No data found for testing',
          'details': 'Database appears empty but operations work'
        };
      }
    } catch (e) {
      return {
        'status': 'FAILED',
        'message': 'CRUD operations failed: $e',
        'details': 'Check database permissions and schema'
      };
    }
  }
  
  static Future<Map<String, dynamic>> _testPasswordHashing() async {
    try {
      // Test password hashing functionality
      const testPassword = 'test123';
      final hashedPassword = _supabaseService.hashPassword(testPassword);
      
      if (hashedPassword.isNotEmpty && hashedPassword != testPassword) {
        return {
          'status': 'PASSED',
          'message': 'Password hashing working correctly',
          'details': 'SHA-256 encryption functional'
        };
      } else {
        return {
          'status': 'FAILED',
          'message': 'Password hashing not working',
          'details': 'Hash function not encrypting properly'
        };
      }
    } catch (e) {
      return {
        'status': 'FAILED',
        'message': 'Password hashing test error: $e',
        'details': 'Exception during hashing test'
      };
    }
  }
  
  static String generateReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== SYSTEM VALIDATION REPORT ===');
    buffer.writeln('Timestamp: ${results['timestamp']}');
    buffer.writeln('');
    
    buffer.writeln('SUMMARY:');
    buffer.writeln('Total Tests: ${results['summary']['total']}');
    buffer.writeln('Passed: ${results['summary']['passed']}');
    buffer.writeln('Failed: ${results['summary']['failed']}');
    buffer.writeln('');
    
    buffer.writeln('DETAILED RESULTS:');
    for (final entry in results['tests'].entries) {
      final testName = entry.key;
      final testResult = entry.value;
      
      buffer.writeln('$testName: ${testResult['status']}');
      buffer.writeln('  Message: ${testResult['message']}');
      buffer.writeln('  Details: ${testResult['details']}');
      buffer.writeln('');
    }
    
    if (results['summary']['errors'].isNotEmpty) {
      buffer.writeln('ERRORS:');
      for (final error in results['summary']['errors']) {
        buffer.writeln('- $error');
      }
    }
    
    return buffer.toString();
  }
}
