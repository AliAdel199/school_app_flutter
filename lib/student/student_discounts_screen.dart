import 'package:flutter/material.dart';
import '../helpers/discount_helper.dart';
import '../localdatabase/student.dart';
import '../localdatabase/student_discount.dart';
import '../localdatabase/discount_type.dart';
import '../main.dart';

class StudentDiscountsScreen extends StatefulWidget {
  final Student student;
  final String academicYear;

  const StudentDiscountsScreen({
    super.key,
    required this.student,
    required this.academicYear,
  });

  @override
  State<StudentDiscountsScreen> createState() => _StudentDiscountsScreenState();
}

class _StudentDiscountsScreenState extends State<StudentDiscountsScreen> {
  late DiscountHelper discountHelper;
  List<StudentDiscount> studentDiscounts = [];
  List<DiscountType> discountTypes = [];
  double totalDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    discountHelper = DiscountHelper(isar);
    _loadData();
  }

  Future<void> _loadData() async {
    final discounts = await discountHelper.getActiveDiscounts(
      studentId: widget.student.id.toString(),
      academicYear: widget.academicYear,
    );
    
    final types = await discountHelper.getActiveDiscountTypes();
    
    final total = await discountHelper.calculateTotalDiscount(
      studentId: widget.student.id.toString(),
      academicYear: widget.academicYear,
      originalFee: widget.student.annualFee ?? 0.0,
    );

    setState(() {
      studentDiscounts = discounts;
      discountTypes = types;
      totalDiscount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خصومات ${widget.student.fullName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // معلومات الطالب والخصم الإجمالي
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطالب: ${widget.student.fullName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('السنة الدراسية: ${widget.academicYear}'),
                Text('القسط السنوي: ${widget.student.annualFee?.toStringAsFixed(2) ?? '0'} د.ع'),
                const Divider(),
                Text(
                  'إجمالي الخصومات: ${totalDiscount.toStringAsFixed(2)} د.ع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'القسط بعد الخصم: ${((widget.student.annualFee ?? 0) - totalDiscount).toStringAsFixed(2)} د.ع',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // قائمة الخصومات الحالية
          Expanded(
            child: studentDiscounts.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد خصومات مطبقة',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: studentDiscounts.length,
                    itemBuilder: (context, index) {
                      final discount = studentDiscounts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(discount.discountType),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                discount.isPercentage
                                    ? '${discount.discountValue}%'
                                    : '${discount.discountValue.toStringAsFixed(2)} د.ع',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              if (discount.notes?.isNotEmpty == true)
                                Text('الملاحظة: ${discount.notes}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeDiscount(discount),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDiscountDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDiscountDialog() async {
    String? selectedDiscountType;
    final valueController = TextEditingController();
    final notesController = TextEditingController();
    bool isPercentage = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('إضافة خصم'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDiscountType,
                  decoration: const InputDecoration(labelText: 'نوع الخصم'),
                  items: discountTypes.map((type) {
                    return DropdownMenuItem(
                      value: type.name,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDiscountType = value;
                      // تعبئة القيمة الافتراضية
                      final selectedType = discountTypes
                          .firstWhere((type) => type.name == value);
                      valueController.text = selectedType.defaultValue?.toString() ?? '';
                      isPercentage = selectedType.defaultIsPercentage;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'قيمة الخصم'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<bool>(
                      value: isPercentage,
                      items: const [
                        DropdownMenuItem(value: true, child: Text('%')),
                        DropdownMenuItem(value: false, child: Text('د.ع')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          isPercentage = value ?? true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedDiscountType != null && valueController.text.isNotEmpty) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true && selectedDiscountType != null) {
      final success = await discountHelper.addDiscountToStudent(
        studentId: widget.student.id.toString(),
        discountType: selectedDiscountType!,
        discountValue: double.parse(valueController.text),
        isPercentage: isPercentage,
        academicYear: widget.academicYear,
        notes: notesController.text.isEmpty ? null : notesController.text,
        addedBy: 'النظام', // يمكن تخصيصه حسب المستخدم الحالي
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الخصم بنجاح')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إضافة الخصم')),
        );
      }
    }
  }

  Future<void> _removeDiscount(StudentDiscount discount) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف خصم "${discount.discountType}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await discountHelper.deactivateDiscount(discount.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الخصم بنجاح')),
        );
        _loadData();
      }
    }
  }
}