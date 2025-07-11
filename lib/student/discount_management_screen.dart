import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/discount_type.dart';
import '../helpers/discount_helper.dart';
import '../main.dart'; // تأكد من استيراد main.dart للوصول للمتغير العام
import 'student_discounts_screen.dart';

class DiscountManagementScreen extends StatefulWidget {
  const DiscountManagementScreen({super.key});

  @override
  State<DiscountManagementScreen> createState() => _DiscountManagementScreenState();
}

class _DiscountManagementScreenState extends State<DiscountManagementScreen> {
  late DiscountHelper discountHelper;
  List<Student> students = [];
  List<DiscountType> discountTypes = [];
  String searchQuery = '';
  bool isLoading = true;
  
  // استخدام المتغير العام مباشرة
  String get currentAcademicYear => academicYear; // المتغير العام من main.dart

  @override
  void initState() {
    super.initState();
    discountHelper = DiscountHelper(isar);
    print('📅 السنة الدراسية المستخدمة: $currentAcademicYear');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      // إنشاء أنواع الخصومات الافتراضية إذا لم تكن موجودة
      await discountHelper.createDefaultDiscountTypes();
      
      // إنشاء سجلات أقساط مفقودة للسنة الحالية
      await discountHelper.createMissingFeeStatuses(currentAcademicYear);
      
      // جلب جميع الطلاب
      final allStudents = await isar.students.where().findAll();
      
      // تحميل بيانات الصف لكل طالب
      for (var student in allStudents) {
        await student.schoolclass.load();
      }
      
      // جلب أنواع الخصومات
      final types = await discountHelper.getActiveDiscountTypes();
      
      setState(() {
        students = allStudents;
        discountTypes = types;
        isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      setState(() => isLoading = false);
    }
  }

  List<Student> get filteredStudents {
    if (searchQuery.isEmpty) return students;
    return students.where((student) =>
      student.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ?? false
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إدارة خصومات الطلاب'),
            if (academicYear.isNotEmpty)
              Text(
                'السنة الدراسية: $academicYear',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          // زر لتغيير السنة الدراسية
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showChangeAcademicYearDialog,
            tooltip: 'تغيير السنة الدراسية',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showDiscountTypesDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _showAddDiscountTypeDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط البحث
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'البحث عن طالب...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),

                // إحصائيات سريعة
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الطلاب',
                          students.length.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'أنواع الخصومات',
                          discountTypes.length.toString(),
                          Icons.percent,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // قائمة الطلاب
                Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty 
                                    ? 'لا توجد طلاب'
                                    : 'لا توجد نتائج للبحث',
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (searchQuery.isEmpty) ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/add-student'),
                                  child: const Text('إضافة طالب جديد'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            return _buildStudentCard(student);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // أضف هذه الدالة لإضافة خصم لطالب محدد
  Future<void> _showAddStudentDiscountDialog(Student student) async {
    String? selectedDiscountType;
    final valueController = TextEditingController();
    final notesController = TextEditingController();
    bool isPercentage = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('إضافة خصم للطالب "${student.fullName}"'),
            content: SingleChildScrollView(
              child: Column(
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
                        if (value != null) {
                          final selectedType = discountTypes
                              .firstWhere((type) => type.name == value);
                          valueController.text = selectedType.defaultValue?.toString() ?? '';
                          isPercentage = selectedType.defaultIsPercentage;
                        }
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
        studentId: student.id.toString(),
        discountType: selectedDiscountType!,
        discountValue: double.parse(valueController.text),
        isPercentage: isPercentage,
        academicYear: currentAcademicYear, // استخدام السنة الحالية
        notes: notesController.text.isEmpty ? null : notesController.text,
        addedBy: 'النظام',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الخصم بنجاح وتحديث حالة القسط')),
        );
        setState(() {}); // لتحديث الواجهة
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إضافة الخصم')),
        );
      }
    }
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Text(
            student.fullName.substring(0, 1).toUpperCase() ?? 'ط',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student.fullName ?? 'غير محدد',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الصف: ${student.schoolclass.value?.name ?? 'غير محدد'}'),
            Text('القسط: ${student.annualFee?.toStringAsFixed(2) ?? '0'} د.ع'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر إضافة خصم سريع
            IconButton(
              icon: Icon(Icons.add, color: Colors.green.shade700),
              onPressed: () => _showAddStudentDiscountDialog(student),
              tooltip: 'إضافة خصم',
            ),
            // زر إدارة الخصومات
            IconButton(
              icon: Icon(Icons.percent, color: Colors.orange.shade700),
              onPressed: () => _navigateToStudentDiscounts(student),
              tooltip: 'إدارة الخصومات',
            ),
            // عرض إجمالي الخصم
            FutureBuilder<double>(
              future: discountHelper.calculateTotalDiscount(
                studentId: student.id.toString(),
                academicYear: currentAcademicYear, // استخدام السنة الحالية
                originalFee: student.annualFee ?? 0.0,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${snapshot.data!.toStringAsFixed(0)} د.ع',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        onTap: () => _navigateToStudentDiscounts(student),
      ),
    );
  }

  void _navigateToStudentDiscounts(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDiscountsScreen(
          student: student,
          academicYear: currentAcademicYear, // استخدام السنة الحالية
        ),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _showDiscountTypesDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أنواع الخصومات'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: discountTypes.length,
            itemBuilder: (context, index) {
              final type = discountTypes[index];
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(type.color ?? '#2196F3'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.percent, color: Colors.white),
                  ),
                  title: Text(type.name),
                  subtitle: Text(type.description ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (type.defaultValue != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type.defaultIsPercentage
                                ? '${type.defaultValue}%'
                                : '${type.defaultValue} د.ع',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDiscountTypeDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final valueController = TextEditingController();
    bool isPercentage = true;
    Color selectedColor = Colors.blue;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('إضافة نوع خصم جديد'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم نوع الخصم'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'القيمة الافتراضية'),
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
                Row(
                  children: [
                    const Text('اللون: '),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        // يمكنك إضافة color picker هنا
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Icon(Icons.palette, color: Colors.white),
                      ),
                    ),
                  ],
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
                  if (nameController.text.isNotEmpty) {
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

    if (result == true) {
      final success = await discountHelper.addDiscountType(
        name: nameController.text,
        description: descriptionController.text.isEmpty ? null : descriptionController.text,
        defaultValue: valueController.text.isEmpty ? null : double.tryParse(valueController.text),
        defaultIsPercentage: isPercentage,
        color: '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة نوع الخصم بنجاح')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إضافة نوع الخصم - الاسم موجود مسبقاً')),
        );
      }
    }
  }

  /// حوار تغيير السنة الدراسية
  Future<void> _showChangeAcademicYearDialog() async {
    final controller = TextEditingController(text: academicYear);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير السنة الدراسية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'السنة الدراسية',
                hintText: '2024-2025',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تنسيق السنة: YYYY-YYYY\nمثال: 2024-2025',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('تغيير'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != academicYear) {
      setState(() {
        academicYear = result;
        isLoading = true;
      });
      
      print('🔄 تم تغيير السنة الدراسية إلى: $academicYear');
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تغيير السنة الدراسية إلى: $academicYear')),
      );
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}