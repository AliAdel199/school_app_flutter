import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../helpers/debt_tracking_helper.dart';

class YearlyFinancialReportScreen extends StatefulWidget {
  final Isar isar;
  
  const YearlyFinancialReportScreen({super.key, required this.isar});

  @override
  State<YearlyFinancialReportScreen> createState() => _YearlyFinancialReportScreenState();
}

class _YearlyFinancialReportScreenState extends State<YearlyFinancialReportScreen> {
  late DebtTrackingHelper debtHelper;
  String selectedYear = DateTime.now().year.toString();
  Map<String, double>? reportData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    debtHelper = DebtTrackingHelper(widget.isar);
    generateReport();
  }

  Future<void> generateReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await debtHelper.getYearlyFinancialReport(selectedYear);
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
        title: const Text('التقرير المالي السنوي'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // اختيار السنة الدراسية
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'السنة الدراسية: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedYear,
                        items: _generateYearsList().map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          );
                        }).toList(),
                        onChanged: (newYear) {
                          setState(() {
                            selectedYear = newYear!;
                          });
                          generateReport();
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // عرض التقرير
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportData != null
                      ? _buildReportContent()
                      : const Center(child: Text('لا توجد بيانات للعرض')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    if (reportData == null) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        children: [
          // ملخص الأقساط
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص الأقساط المدرسية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildReportRow('إجمالي الأقساط المطلوبة', reportData!['total_expected_fees']!, Colors.blue),
                  _buildReportRow('المحصل من السنة الحالية', reportData!['collected_this_year']!, Colors.green),
                  _buildReportRow('المحصل من ديون سنوات سابقة', reportData!['transferred_debt_collected']!, Colors.orange),
                  _buildReportRow('المتبقي للسنة الحالية', reportData!['remaining_debt']!, Colors.red),
                  const Divider(),
                  _buildReportRow(
                    'نسبة التحصيل',
                    reportData!['collection_rate']!,
                    Colors.purple,
                    isPercentage: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // تفاصيل إضافية
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل مالية إضافية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  FutureBuilder<double>(
                    future: debtHelper.getTransferredDebtCollectedFromYear(selectedYear),
                    builder: (context, snapshot) {
                      return _buildReportRow(
                        'إجمالي الديون المحولة من هذه السنة',
                        snapshot.data ?? 0,
                        Colors.amber,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, double value, Color color, {bool isPercentage = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            isPercentage 
                ? '${value.toStringAsFixed(1)}%'
                : '${value.toStringAsFixed(2)} د.أ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateYearsList() {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => (currentYear - index).toString());
  }
}
