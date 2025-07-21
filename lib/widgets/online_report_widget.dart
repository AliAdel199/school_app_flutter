import 'package:flutter/material.dart';
import '../services/online_reports_service.dart';

class OnlineReportWidget extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final String reportType;
  final String? reportTitle; // إضافة عنوان للتقرير

  const OnlineReportWidget({
    Key? key,
    required this.reportData,
    required this.reportType,
    this.reportTitle,
  }) : super(key: key);

  @override
  State<OnlineReportWidget> createState() => _OnlineReportWidgetState();
}

class _OnlineReportWidgetState extends State<OnlineReportWidget> {
  bool isOnlineAvailable = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _checkOnlineAvailability();
  }

  Future<void> _checkOnlineAvailability() async {
    final available = await OnlineReportsService.isOnlineReportsAvailable();
    setState(() {
      isOnlineAvailable = available;
    });
  }

  Future<void> _uploadReport() async {
    if (!isOnlineAvailable) return;

    setState(() => isUploading = true);

    bool success = false;
    try {
      switch (widget.reportType) {
        case 'financial':
          success = await OnlineReportsService.uploadFinancialReport(
            reportData: widget.reportData,
          );
          break;
        case 'students':
          success = await OnlineReportsService.uploadStudentReport(
            reportData: widget.reportData,
          );
          break;
        default:
          _showErrorSnackBar('نوع التقرير غير مدعوم');
          return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('تم رفع التقرير النهائي بنجاح ☁️'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        _showErrorSnackBar('فشل في رفع التقرير للسحابة');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ: $e');
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isOnlineAvailable) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange.shade600, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وضع محلي فقط',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'مزامنة التقارير مع السحابة غير متاحة حالياً',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '💡 التقرير متوفر محلياً وجاهز للطباعة والمشاركة',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.cloud, color: Colors.blue.shade600, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مزامنة السحابة متاحة ☁️',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.reportTitle != null
                          ? 'جاهز لرفع: ${widget.reportTitle}'
                          : 'التقرير النهائي جاهز للرفع',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.blue.shade700, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'سيتم رفع التقرير النهائي والملخص فقط (وليس البيانات الخام)',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUploading ? null : _uploadReport,
              icon: isUploading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.cloud_upload, size: 20),
              label: Text(
                isUploading ? 'جاري الرفع للسحابة...' : 'رفع التقرير للسحابة',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
