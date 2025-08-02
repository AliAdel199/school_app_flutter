import 'package:flutter_test/flutter_test.dart';
import 'package:school_app_flutter/tests/system_validator.dart';

void main() {
  group('SystemValidator Tests', () {
    test('System validation completes successfully', () async {
      final results = await SystemValidator.validateCompleteSystem();
      
      expect(results, isNotNull);
      expect(results['timestamp'], isNotNull);
      expect(results['tests'], isNotNull);
      expect(results['summary'], isNotNull);
      
      // Check summary structure
      expect(results['summary']['total'], isA<int>());
      expect(results['summary']['passed'], isA<int>());
      expect(results['summary']['failed'], isA<int>());
      expect(results['summary']['errors'], isA<List>());
      
      print('Total tests: ${results['summary']['total']}');
      print('Passed: ${results['summary']['passed']}');
      print('Failed: ${results['summary']['failed']}');
    });
    
    test('Report generation works', () async {
      final results = await SystemValidator.validateCompleteSystem();
      final report = SystemValidator.generateReport(results);
      
      expect(report, isNotNull);
      expect(report, isA<String>());
      expect(report.contains('SYSTEM VALIDATION REPORT'), isTrue);
      expect(report.contains('SUMMARY:'), isTrue);
      expect(report.contains('DETAILED RESULTS:'), isTrue);
      
      print('Generated report:');
      print(report);
    });
  });
}
