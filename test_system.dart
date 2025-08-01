import 'dart:io';
import 'package:flutter/services.dart';
import 'lib/tests/system_validator.dart';

Future<void> main() async {
  stdout.writeln('🔄 Starting comprehensive system validation...');
  stdout.writeln('=' * 50);
  
  try {
    // Run the validation
    final results = await SystemValidator.validateCompleteSystem();
    
    // Generate and display report
    final report = SystemValidator.generateReport(results);
    stdout.writeln(report);
    
    // Write results to file
    final file = File('system_test_results.txt');
    await file.writeAsString(report);
    stdout.writeln('📁 Results saved to: system_test_results.txt');
    
    // Exit with appropriate code
    final failed = results['summary']['failed'] as int;
    if (failed > 0) {
      stdout.writeln('❌ System validation completed with ${failed} failures');
      exit(1);
    } else {
      stdout.writeln('✅ System validation completed successfully');
      exit(0);
    }
    
  } catch (e) {
    stderr.writeln('💥 Critical error during system validation: $e');
    exit(2);
  }
}
