import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/subject.dart';
import '../localdatabase/subject_mark.dart';
import '../localdatabase/class.dart';
import '../localdatabase/student_crud.dart';
import '../main.dart';

class MarksManagementScreen extends StatefulWidget {
  const MarksManagementScreen({Key? key}) : super(key: key);

  @override
  State<MarksManagementScreen> createState() => _MarksManagementScreenState();
}

class _MarksManagementScreenState extends State<MarksManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<Student> students = [];
  List<Subject> subjects = [];
  List<SubjectMark> marks = [];
  List<SchoolClass> classes = [];
  
  SchoolClass? selectedClass;
  Subject? selectedSubject;
  String selectedEvaluationType = 'نصف سنة';
  String selectedAcademicYear = DateTime.now().year.toString();
  
  final List<String> evaluationTypes = ['نصف سنة', 'نهائي', 'شفوي', 'عملي', 'مشاركة'];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      // استخدام الوظائف من student_crud
      students = await getAllStudents(isar);
      classes = await getAllClasses(isar);
      subjects = await getAllSubjects(isar);
      
      // جلب جميع الدرجات
      marks = await _getAllMarks();

      // تحميل العلاقات
      for (var student in students) {
        await student.schoolclass.load();
      }
      
      for (var subject in subjects) {
        await subject.schoolClass.load();
      }
      
      for (var mark in marks) {
        await mark.student.load();
        await mark.subject.load();
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<List<SubjectMark>> _getAllMarks() async {
    try {
      final marksQuery = isar.subjectMarks.where();
      return await marksQuery.findAll();
    } catch (e) {
      print('Error loading marks: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الدرجات والمواد'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.grade), text: 'الدرجات'),
            Tab(icon: Icon(Icons.book), text: 'المواد'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMarksTab(),
                _buildSubjectsTab(),
              ],
            ),
    );
  }

  Widget _buildMarksTab() {
    return Column(
      children: [
        _buildFiltersSection(),
        Expanded(child: _buildMarksGrid()),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SchoolClass>(
                  decoration: const InputDecoration(
                    labelText: 'الصف',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: selectedClass,
                  items: classes.map((class_) => DropdownMenuItem(
                    value: class_,
                    child: Text(class_.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value;
                      selectedSubject = null; // إعادة تعيين المادة
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<Subject>(
                  decoration: const InputDecoration(
                    labelText: 'المادة',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: selectedSubject,
                  items: _getFilteredSubjects().map((subject) => DropdownMenuItem(
                    value: subject,
                    child: Text(subject.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'نوع التقييم',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: selectedEvaluationType,
                  items: evaluationTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEvaluationType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'العام الدراسي',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  initialValue: selectedAcademicYear,
                  onChanged: (value) {
                    selectedAcademicYear = value;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Subject> _getFilteredSubjects() {
    if (selectedClass == null) return subjects;
    return subjects.where((subject) => 
      subject.schoolClass.value?.id == selectedClass!.id
    ).toList();
  }

  Widget _buildMarksGrid() {
    final filteredStudents = _getFilteredStudents();
    
    if (filteredStudents.isEmpty) {
      return const Center(
        child: Text('لا توجد طلاب في الصف المحدد'),
      );
    }

    if (selectedSubject == null) {
      return const Center(
        child: Text('يرجى اختيار المادة'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'درجات مادة ${selectedSubject!.name} - ${selectedClass!.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.teal[50]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('اسم الطالب', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('الدرجة', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...filteredStudents.map((student) => _buildStudentRow(student)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Student> _getFilteredStudents() {
    if (selectedClass == null) return [];
    return students.where((student) => 
      student.schoolclass.value?.id == selectedClass!.id
    ).toList();
  }

  TableRow _buildStudentRow(Student student) {
    final existingMark = _getStudentMark(student);
    final markController = TextEditingController(
      text: existingMark?.mark?.toString() ?? ''
    );

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(student.fullName),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextFormField(
            controller: markController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              hintText: '0-100',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: () => _saveStudentMark(student, markController.text),
                tooltip: 'حفظ',
              ),
              if (existingMark != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMark(existingMark),
                  tooltip: 'حذف',
                ),
            ],
          ),
        ),
      ],
    );
  }

  SubjectMark? _getStudentMark(Student student) {
    if (selectedSubject == null) return null;
    
    try {
      return marks.firstWhere(
        (mark) => 
          mark.student.value?.id == student.id &&
          mark.subject.value?.id == selectedSubject!.id &&
          mark.evaluationType == selectedEvaluationType &&
          mark.academicYear == selectedAcademicYear,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveStudentMark(Student student, String markText) async {
    if (selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المادة أولاً')),
      );
      return;
    }

    try {
      final markValue = double.tryParse(markText);
      if (markValue == null && markText.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال درجة صحيحة')),
        );
        return;
      }

      await isar.writeTxn(() async {
        // البحث عن درجة موجودة
        final existingMarks = marks.where((mark) =>
            mark.student.value?.id == student.id &&
            mark.subject.value?.id == selectedSubject!.id &&
            mark.evaluationType == selectedEvaluationType &&
            mark.academicYear == selectedAcademicYear).toList();

        if (existingMarks.isNotEmpty) {
          // تحديث الدرجة الموجودة
          final existingMark = existingMarks.first;
          existingMark.mark = markValue;
          await isar.subjectMarks.put(existingMark);
        } else if (markValue != null) {
          // إنشاء درجة جديدة
          final newMark = SubjectMark()
            ..mark = markValue
            ..evaluationType = selectedEvaluationType
            ..academicYear = selectedAcademicYear
            ..createdAt = DateTime.now();
          
          await isar.subjectMarks.put(newMark);
          newMark.student.value = student;
          newMark.subject.value = selectedSubject;
          await newMark.student.save();
          await newMark.subject.save();
        }
      });

      await _loadData(); // إعادة تحميل البيانات
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الدرجة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ الدرجة: $e')),
        );
      }
    }
  }

  Future<void> _deleteMark(SubjectMark mark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الدرجة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await isar.writeTxn(() async {
          await isar.subjectMarks.delete(mark.id);
        });

        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الدرجة بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في حذف الدرجة: $e')),
          );
        }
      }
    }
  }

  Widget _buildSubjectsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SchoolClass>(
                  decoration: const InputDecoration(
                    labelText: 'فلترة حسب الصف',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedClass,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('جميع الصفوف')),
                    ...classes.map((class_) => DropdownMenuItem(
                      value: class_,
                      child: Text(class_.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddSubjectDialog,
                icon: const Icon(Icons.add),
                label: const Text('إضافة مادة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSubjectsList()),
      ],
    );
  }

  Widget _buildSubjectsList() {
    final filteredSubjects = selectedClass == null 
        ? subjects 
        : subjects.where((s) => s.schoolClass.value?.id == selectedClass!.id).toList();

    if (filteredSubjects.isEmpty) {
      return const Center(
        child: Text('لا توجد مواد'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = filteredSubjects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                subject.name.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(subject.name),
            subtitle: Text('الصف: ${subject.schoolClass.value?.name ?? 'غير محدد'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditSubjectDialog(subject),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSubject(subject),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    SchoolClass? selectedClassForSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة مادة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المادة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                decoration: const InputDecoration(
                  labelText: 'الصف',
                  border: OutlineInputBorder(),
                ),
                value: selectedClassForSubject,
                items: classes.map((class_) => DropdownMenuItem(
                  value: class_,
                  child: Text(class_.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClassForSubject = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedClassForSubject != null) {
                  await _addSubject(nameController.text, selectedClassForSubject!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSubjectDialog(Subject subject) {
    final nameController = TextEditingController(text: subject.name);
    SchoolClass? selectedClassForSubject = subject.schoolClass.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل المادة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المادة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                decoration: const InputDecoration(
                  labelText: 'الصف',
                  border: OutlineInputBorder(),
                ),
                value: selectedClassForSubject,
                items: classes.map((class_) => DropdownMenuItem(
                  value: class_,
                  child: Text(class_.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClassForSubject = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedClassForSubject != null) {
                  await _updateSubject(subject, nameController.text, selectedClassForSubject!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSubject(String name, SchoolClass schoolClass) async {
    try {
      await isar.writeTxn(() async {
        final subject = Subject()
          ..name = name
          ..createdAt = DateTime.now();
        
        await isar.subjects.put(subject);
        subject.schoolClass.value = schoolClass;
        await subject.schoolClass.save();
      });

      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المادة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إضافة المادة: $e')),
        );
      }
    }
  }

  Future<void> _updateSubject(Subject subject, String name, SchoolClass schoolClass) async {
    try {
      await isar.writeTxn(() async {
        subject.name = name;
        subject.schoolClass.value = schoolClass;
        await isar.subjects.put(subject);
        await subject.schoolClass.save();
      });

      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث المادة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحديث المادة: $e')),
        );
      }
    }
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المادة؟ سيتم حذف جميع الدرجات المرتبطة بها.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await isar.writeTxn(() async {
          // حذف جميع الدرجات المرتبطة بالمادة
          final relatedMarks = marks.where((mark) => 
              mark.subject.value?.id == subject.id).toList();
              
          for (final mark in relatedMarks) {
            await isar.subjectMarks.delete(mark.id);
          }
          
          // حذف المادة
          await isar.subjects.delete(subject.id);
        });

        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المادة بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في حذف المادة: $e')),
          );
        }
      }
    }
  }
}
