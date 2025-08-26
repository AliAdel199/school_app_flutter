import '../services/database_service.dart';
import '../services/subscription_service.dart';
import '../helpers/network_helper.dart';

/// خدمة إدارة التقارير
/// تدير رفع وتحميل وإدارة التقارير مع التحقق من الصلاحيات
class ReportsService {
  
  /// التأكد من وجود جدول التقارير
  static Future<void> _ensureReportsTableExists() async {
    try {
      // محاولة إنشاء جدول التقارير إذا لم يكن موجوداً
      await DatabaseService.client.rpc('create_reports_table_if_not_exists');
      print('✅ تم التأكد من وجود جدول التقارير');
    } catch (e) {
      // تجاهل الخطأ إذا كان الجدول موجوداً بالفعل
      print('ℹ️ جدول التقارير موجود بالفعل أو حدث خطأ في الإنشاء: $e');
    }
  }

  /// التحقق من اشتراك التقارير الأونلاين
  static Future<bool> checkOnlineReportsSubscription(int organizationId) async {
    if (!DatabaseService.isEnabled) return false;
    
    try {
      final subscriptionStatus = await SubscriptionService.checkOrganizationSubscriptionStatus(organizationId);
      if (subscriptionStatus == null) return false;
      
      final hasOnlineReports = subscriptionStatus['has_online_reports'] as bool? ?? false;
      print('🔍 حالة اشتراك التقارير الأونلاين: $hasOnlineReports');
      
      return hasOnlineReports;
    } catch (e) {
      print('❌ خطأ في التحقق من اشتراك التقارير: $e');
      return false;
    }
  }

  /// رفع تقرير المؤسسة
  static Future<Map<String, dynamic>> uploadOrganizationReport({
    required int organizationId,
    int? schoolId,
    required String reportType,
    required String reportTitle,
    required Map<String, dynamic> reportData,
    required String period,
    required String generatedBy,
    String? description,
  }) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
        'message': 'يعمل النظام في وضع محلي فقط',
      };
    }
    
    try {
      print('🔄 بدء رفع التقرير: $reportTitle');
      
      // التحقق من صلاحيات التقارير الأونلاين
      final hasOnlineReports = await checkOnlineReportsSubscription(organizationId);
      
      if (!hasOnlineReports) {
        return {
          'success': false,
          'error': 'ميزة غير متاحة',
          'message': 'ميزة التقارير الأونلاين غير متاحة في باقتك الحالية',
          'requires_upgrade': true,
        };
      }
      
      // التأكد من وجود جدول التقارير
      await _ensureReportsTableExists();
      
      // حساب حجم التقرير
      final reportDataJson = reportData.toString();
      final fileSize = reportDataJson.length;
      
      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('reports')
              .insert({
                'organization_id': organizationId,
                'school_id': schoolId,
                'report_type': reportType,
                'report_title': reportTitle,
                'report_data': reportData,
                'period': period,
                'generated_by': generatedBy,
                'description': description,
                'file_size': fileSize,
                'status': 'uploaded',
                'generated_at': DateTime.now().toIso8601String(),
                'uploaded_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
        },
        operationName: 'رفع التقرير',
      );
      
      if (result != null) {
        print('✅ تم رفع التقرير بنجاح - ID: ${result['id']}');
        return {
          'success': true,
          'report_id': result['id'],
          'upload_time': result['uploaded_at'],
          'file_size': fileSize,
          'message': 'تم رفع التقرير بنجاح',
        };
      }
      
      return {
        'success': false,
        'error': 'فشل في رفع التقرير',
        'message': 'حدث خطأ غير متوقع أثناء رفع التقرير',
      };
      
    } catch (e) {
      print('❌ خطأ في رفع التقرير: $e');
      return {
        'success': false,
        'error': 'خطأ في الرفع',
        'message': 'فشل في رفع التقرير: $e',
      };
    }
  }

  /// رفع تقرير (دالة مختصرة)
  static Future<bool> uploadReport(Map<String, dynamic> reportData) async {
    if (!DatabaseService.isEnabled) return false;
    
    try {
      final organizationIdString = await NetworkHelper.getOrganizationId();
      if (organizationIdString == null) {
        print('❌ لم يتم العثور على معرف المؤسسة');
        return false;
      }

      final organizationId = int.parse(organizationIdString);

      // إعداد بيانات التقرير الافتراضية
      final reportToUpload = {
        'organization_id': organizationId,
        'school_id': reportData['school_id'],
        'report_type': reportData['report_type'] ?? 'general',
        'report_title': reportData['report_title'] ?? 'تقرير عام',
        'report_data': reportData,
        'period': reportData['period'] ?? 'غير محدد',
        'generated_by': reportData['generated_by'] ?? 'النظام',
        'description': reportData['description'],
      };

      final result = await uploadOrganizationReport(
        organizationId: organizationId,
        schoolId: reportToUpload['school_id'],
        reportType: reportToUpload['report_type'],
        reportTitle: reportToUpload['report_title'],
        reportData: reportToUpload,
        period: reportToUpload['period'],
        generatedBy: reportToUpload['generated_by'],
        description: reportToUpload['description'],
      );

      return result['success'] == true;

    } catch (e) {
      print('❌ خطأ في رفع التقرير: $e');
      return false;
    }
  }

  /// جلب التقارير المرفوعة للمؤسسة
  static Future<Map<String, dynamic>> getUploadedReports({
    int? organizationId,
    int? limit = 50,
    String? reportType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
        'reports': [],
        'total': 0,
      };
    }

    try {
      // الحصول على معرف المؤسسة إذا لم يتم تمريره
      int finalOrganizationId = organizationId ?? 0;
      if (finalOrganizationId == 0) {
        final organizationIdString = await NetworkHelper.getOrganizationId();
        if (organizationIdString == null) {
          return {
            'success': false,
            'error': 'لم يتم العثور على معرف المؤسسة',
            'reports': [],
            'total': 0,
          };
        }
        finalOrganizationId = int.parse(organizationIdString);
      }

      final response = await DatabaseService.executeWithRetry(
        () async {
          var queryBuilder = DatabaseService.client
              .from('reports')
              .select('*')
              .eq('organization_id', finalOrganizationId)
              .order('uploaded_at', ascending: false);
          
          if (limit != null) {
            queryBuilder = queryBuilder.limit(limit);
          }
          
          return await queryBuilder;
        },
        operationName: 'جلب التقارير',
      );

      // تطبيق الفلاتر على البيانات بعد الجلب
      var filteredData = response ?? [];
      
      if (reportType != null) {
        filteredData = filteredData.where((report) => 
            report['report_type'] == reportType).toList();
      }

      if (fromDate != null) {
        filteredData = filteredData.where((report) {
          final uploadedAt = DateTime.parse(report['uploaded_at']);
          return uploadedAt.isAfter(fromDate) || uploadedAt.isAtSameMomentAs(fromDate);
        }).toList();
      }

      if (toDate != null) {
        filteredData = filteredData.where((report) {
          final uploadedAt = DateTime.parse(report['uploaded_at']);
          return uploadedAt.isBefore(toDate) || uploadedAt.isAtSameMomentAs(toDate);
        }).toList();
      }

      print('✅ تم جلب ${filteredData.length} تقرير');

      return {
        'success': true,
        'reports': filteredData,
        'total': filteredData.length,
        'organization_id': finalOrganizationId,
      };

    } catch (e) {
      print('❌ خطأ في جلب التقارير: $e');
      return {
        'success': false,
        'error': 'خطأ في جلب التقارير: $e',
        'reports': [],
        'total': 0,
      };
    }
  }

  /// حذف تقرير مرفوع
  static Future<bool> deleteUploadedReport(String reportId, {int? organizationId}) async {
    if (!DatabaseService.isEnabled) return false;
    
    try {
      // التحقق من الصلاحية (التأكد أن التقرير ينتمي للمؤسسة)
      int finalOrganizationId = organizationId ?? 0;
      if (finalOrganizationId == 0) {
        final organizationIdString = await NetworkHelper.getOrganizationId();
        if (organizationIdString == null) return false;
        finalOrganizationId = int.parse(organizationIdString);
      }

      final result = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('reports')
              .delete()
              .eq('id', reportId)
              .eq('organization_id', finalOrganizationId)
              .select();
        },
        operationName: 'حذف التقرير',
      );

      final success = result != null && result.isNotEmpty;
      if (success) {
        print('✅ تم حذف التقرير بنجاح');
      } else {
        print('⚠️ لم يتم العثور على التقرير أو لا توجد صلاحية للحذف');
      }
      
      return success;
    } catch (e) {
      print('❌ خطأ في حذف التقرير: $e');
      return false;
    }
  }

  /// الحصول على إحصائيات التقارير
  static Future<Map<String, dynamic>> getReportsStatistics({int? organizationId}) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
        'total_reports': 0,
        'total_size_mb': 0.0,
        'reports_by_type': {},
        'recent_uploads': 0,
      };
    }

    try {
      // الحصول على معرف المؤسسة
      int finalOrganizationId = organizationId ?? 0;
      if (finalOrganizationId == 0) {
        final organizationIdString = await NetworkHelper.getOrganizationId();
        if (organizationIdString == null) {
          return {
            'success': false,
            'error': 'لم يتم العثور على معرف المؤسسة',
            'total_reports': 0,
            'total_size_mb': 0.0,
            'reports_by_type': {},
            'recent_uploads': 0,
          };
        }
        finalOrganizationId = int.parse(organizationIdString);
      }

      final response = await DatabaseService.executeWithRetry(
        () async {
          return await DatabaseService.client
              .from('reports')
              .select('report_type, file_size, uploaded_at')
              .eq('organization_id', finalOrganizationId);
        },
        operationName: 'جلب إحصائيات التقارير',
      );

      final reports = response ?? [];
      final totalReports = reports.length;
      final totalSize = reports.fold<int>(0, (sum, report) => 
          sum + ((report['file_size'] as int?) ?? 0));
      
      final reportsByType = <String, int>{};
      int recentUploads = 0;
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      for (final report in reports) {
        // إحصاء حسب النوع
        final type = report['report_type'] as String? ?? 'غير محدد';
        reportsByType[type] = (reportsByType[type] ?? 0) + 1;
        
        // عد الرفوعات الحديثة (آخر أسبوع)
        final uploadedAt = DateTime.parse(report['uploaded_at']);
        if (uploadedAt.isAfter(oneWeekAgo)) {
          recentUploads++;
        }
      }

      print('✅ تم حساب إحصائيات التقارير');

      return {
        'success': true,
        'total_reports': totalReports,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'total_size_bytes': totalSize,
        'reports_by_type': reportsByType,
        'recent_uploads': recentUploads,
        'organization_id': finalOrganizationId,
      };

    } catch (e) {
      print('❌ خطأ في جلب إحصائيات التقارير: $e');
      return {
        'success': false,
        'error': 'خطأ في حساب الإحصائيات: $e',
        'total_reports': 0,
        'total_size_mb': 0.0,
        'reports_by_type': {},
        'recent_uploads': 0,
      };
    }
  }

  /// تنظيف التقارير القديمة (حذف التقارير الأقدم من تاريخ معين)
  static Future<Map<String, dynamic>> cleanupOldReports({
    int? organizationId,
    required DateTime olderThan,
    String? reportType,
  }) async {
    if (!DatabaseService.isEnabled) {
      return {
        'success': false,
        'error': 'قاعدة البيانات غير مفعلة',
        'deleted_count': 0,
      };
    }

    try {
      // الحصول على معرف المؤسسة
      int finalOrganizationId = organizationId ?? 0;
      if (finalOrganizationId == 0) {
        final organizationIdString = await NetworkHelper.getOrganizationId();
        if (organizationIdString == null) {
          return {
            'success': false,
            'error': 'لم يتم العثور على معرف المؤسسة',
            'deleted_count': 0,
          };
        }
        finalOrganizationId = int.parse(organizationIdString);
      }

      var deleteQuery = DatabaseService.client
          .from('reports')
          .delete()
          .eq('organization_id', finalOrganizationId)
          .lt('uploaded_at', olderThan.toIso8601String());
      
      if (reportType != null) {
        deleteQuery = deleteQuery.eq('report_type', reportType);
      }

      final result = await DatabaseService.executeWithRetry(
        () async {
          return await deleteQuery.select();
        },
        operationName: 'تنظيف التقارير القديمة',
      );

      final deletedCount = result?.length ?? 0;
      
      print('✅ تم حذف $deletedCount تقرير قديم');

      return {
        'success': true,
        'deleted_count': deletedCount,
        'cleanup_date': olderThan.toIso8601String(),
        'message': 'تم تنظيف التقارير القديمة بنجاح',
      };

    } catch (e) {
      print('❌ خطأ في تنظيف التقارير القديمة: $e');
      return {
        'success': false,
        'error': 'خطأ في تنظيف التقارير: $e',
        'deleted_count': 0,
      };
    }
  }
}
