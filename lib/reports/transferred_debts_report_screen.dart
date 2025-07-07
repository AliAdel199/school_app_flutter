import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'student_transfer_helper.dart';

class TransferredDebtsReportScreen extends StatefulWidget {
  final Isar isar;
  
  const TransferredDebtsReportScreen({Key? key, required this.isar}) : super(key: key);

  @override
  State<TransferredDebtsReportScreen> createState() => _TransferredDebtsReportScreenState();
}

class _TransferredDebtsReportScreenState extends State<TransferredDebtsReportScreen> {
  late StudentTransferHelper transferHelper;
  Map<String, dynamic>? reportData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    transferHelper = StudentTransferHelper(widget.isar);
    generateReport();
  }

  Future<void> generateReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await transferHelper.getTransferredDebtsReport();
      setState(() {
        reportData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في توليد التقرير: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الديون المنقولة'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportData != null
              ? _buildReportContent()
              : const Center(child: Text('لا توجد بيانات للعرض')),
      floatingActionButton: FloatingActionButton(
        onPressed: generateReport,
        child: const Icon(Icons.refresh),
        tooltip: 'إعادة توليد التقرير',
      ),
    );
  }

  Widget _buildReportContent() {
    if (reportData == null) return const SizedBox();

    final detailedReport = reportData!['detailedReport'] as List<Map<String, dynamic>>;
    final debtsByYear = reportData!['debtsByOriginalYear'] as Map<String, double>;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ملخص عام
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص الديون المنقولة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildSummaryRow('إجمالي الديون المنقولة', reportData!['totalTransferredDebts'], Colors.orange),
                  _buildSummaryRow('عدد الطلاب المتأثرين', reportData!['studentsCount'], Colors.blue, isCount: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // تفصيل حسب السنة الأصلية
          if (debtsByYear.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الديون المنقولة حسب السنة الأصلية',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ...debtsByYear.entries.map((entry) =>
                        _buildSummaryRow('من ${entry.key}', entry.value, Colors.purple)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // التفاصيل الكاملة
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text(
                          'تفاصيل الطلاب',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${detailedReport.length} طالب',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Expanded(
                    child: detailedReport.isEmpty
                        ? const Center(child: Text('لا توجد ديون منقولة'))
                        : ListView.builder(
                            itemCount: detailedReport.length,
                            itemBuilder: (context, index) {
                              final student = detailedReport[index];
                              return ListTile(
                                title: Text(student['studentName'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('الصف الحالي: ${student['currentClass']} - ${student['currentYear']}'),
                                    Text(
                                      'الدين من: ${student['originalClass'] ?? ''} - ${student['originalYear'] ?? ''}',
                                      style: const TextStyle(color: Colors.orange),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${student['transferredAmount']?.toStringAsFixed(2)} د.أ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    Text(
                                      'من أصل ${student['totalDue']?.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value, Color color, {bool isCount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            isCount 
                ? value.toString()
                : '${(value as double).toStringAsFixed(2)} د.أ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
