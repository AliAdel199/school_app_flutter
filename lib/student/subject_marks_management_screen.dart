import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/subject.dart';
import '../localdatabase/subject_mark.dart';
import '../localdatabase/class.dart';
import '../main.dart';

class SubjectMarksManagementScreen extends StatefulWidget {
  const SubjectMarksManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubjectMarksManagementScreen> createState() => _SubjectMarksManagementScreenState();
}

class _SubjectMarksManagementScreenState extends State<SubjectMarksManagementScreen> with TickerProviderStateMixin {
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
    _tabController = TabController(length: 3, vsync: this);
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
      final loadedStudents = await isar.students.where().findAll();
      final loadedSubjects = await isar.subjects.where().findAll();
      final loadedMarks = await isar.subjectMarks.where().findAll();
      final loadedClasses = await isar.schoolClass.where().findAll();

      // تحميل العلاقات
      for (var student in loadedStudents) {
        await student.schoolclass.load();
      }
      
      for (var subject in loadedSubjects) {
        await subject.schoolClass.load();
        await subject.grade.load();
      }
      
      for (var mark in loadedMarks) {
        await mark.student.load();
        await mark.subject.load();
      }

      setState(() {
        students = loadedStudents;
        subjects = loadedSubjects;
        marks = loadedMarks;
        classes = loadedClasses;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    }
  }

  List<Student> get filteredStudents {
    if (selectedClass == null) return students;
    return students.where((student) => 
      student.schoolclass.value?.id == selectedClass!.id).toList();
  }

  List<Subject> get filteredSubjects {
    if (selectedClass == null) return subjects;
    return subjects.where((subject) => 
      subject.schoolClass.value?.id == selectedClass!.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المواد والدرجات'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.grade), text: 'الدرجات'),
            Tab(icon: Icon(Icons.subject), text: 'المواد'),
            Tab(icon: Icon(Icons.analytics), text: 'التقارير'),
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
                _buildReportsTab(),
              ],
            ),
    );
  }

  Widget _buildMarksTab() {
    return Column(
      children: [
        _buildFiltersCard(),
        Expanded(
          child: filteredStudents.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد طلاب في الصف المحدد',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _buildStudentMarksCard(student);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFiltersCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فلترة البيانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<SchoolClass>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'الصف',
                      border: OutlineInputBorder(),
                    ),
                    items: classes.map((schoolClass) {
                      return DropdownMenuItem(
                        value: schoolClass,
                        child: Text(schoolClass.name),
                      );
                    }).toList(),
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
                    value: selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'المادة',
                      border: OutlineInputBorder(),
                    ),
                    items: filteredSubjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name),
                      );
                    }).toList(),
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
                    value: selectedEvaluationType,
                    decoration: const InputDecoration(
                      labelText: 'نوع التقييم',
                      border: OutlineInputBorder(),
                    ),
                    items: evaluationTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
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
                    initialValue: selectedAcademicYear,
                    decoration: const InputDecoration(
                      labelText: 'السنة الدراسية',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      selectedAcademicYear = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentMarksCard(Student student) {
    // البحث عن درجة الطالب في المادة المحددة
    SubjectMark? existingMark;
    if (selectedSubject != null) {
      existingMark = marks.where((mark) =>
        mark.student.value?.id == student.id &&
        mark.subject.value?.id == selectedSubject!.id &&
        mark.evaluationType == selectedEvaluationType &&
        mark.academicYear == selectedAcademicYear
      ).firstOrNull;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الصف: ${student.schoolclass.value?.name ?? 'غير محدد'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (selectedSubject != null) ...[
              Expanded(
                child: TextFormField(
                  initialValue: existingMark?.mark?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: 'الدرجة',
                    border: const OutlineInputBorder(),
                    hintText: '0-100',
                    suffixIcon: existingMark != null
                        ? Icon(Icons.check_circle, color: Colors.green[600])
                        : const Icon(Icons.edit),
                  ),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (value) {
                    _saveMark(student, double.tryParse(value));
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showMarkDetailsDialog(student, existingMark),
                icon: const Icon(Icons.more_vert),
                tooltip: 'تفاصيل أكثر',
              ),
            ] else
              const Expanded(
                child: Text(
                  'اختر مادة لإدخال الدرجات',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'المواد الدراسية',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSubjectDialog,
                icon: const Icon(Icons.add),
                label: const Text('إضافة مادة'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectCard(subject);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(subject.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subject.description != null && subject.description!.isNotEmpty)
              Text(subject.description!),
            Text('الصف: ${subject.schoolClass.value?.name ?? 'غير محدد'}'),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditSubjectDialog(subject);
                break;
              case 'delete':
                _deleteSubject(subject);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إحصائيات عامة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('عدد الطلاب', students.length.toString()),
                  _buildStatRow('عدد المواد', subjects.length.toString()),
                  _buildStatRow('عدد الدرجات المسجلة', marks.length.toString()),
                  _buildStatRow('عدد الصفوف', classes.length.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selectedClass != null && selectedSubject != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إحصائيات ${selectedSubject!.name} - ${selectedClass!.name}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildSubjectStats(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectStats() {
    final subjectMarks = marks.where((mark) =>
      mark.subject.value?.id == selectedSubject!.id &&
      mark.evaluationType == selectedEvaluationType &&
      mark.academicYear == selectedAcademicYear
    ).toList();

    if (subjectMarks.isEmpty) {
      return const Text('لا توجد درجات مسجلة لهذه المادة');
    }

    final validMarks = subjectMarks.where((mark) => mark.mark != null).map((mark) => mark.mark!).toList();
    
    if (validMarks.isEmpty) {
      return const Text('لا توجد درجات صحيحة');
    }

    final average = validMarks.reduce((a, b) => a + b) / validMarks.length;
    final highest = validMarks.reduce((a, b) => a > b ? a : b);
    final lowest = validMarks.reduce((a, b) => a < b ? a : b);
    final passCount = validMarks.where((mark) => mark >= 50).length;

    return Column(
      children: [
        _buildStatRow('عدد الطلاب المقيمين', validMarks.length.toString()),
        _buildStatRow('المتوسط', average.toStringAsFixed(2)),
        _buildStatRow('أعلى درجة', highest.toString()),
        _buildStatRow('أقل درجة', lowest.toString()),
        _buildStatRow('عدد الناجحين', passCount.toString()),
        _buildStatRow('نسبة النجاح', '${(passCount / validMarks.length * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  Future<void> _saveMark(Student student, double? mark) async {
    if (selectedSubject == null || mark == null) return;

    try {
      await isar.writeTxn(() async {
        // البحث عن درجة موجودة
        final existingMark = await isar.subjectMarks
            .filter()
            .student((q) => q.idEqualTo(student.id))
            .and()
            .subject((q) => q.idEqualTo(selectedSubject!.id))
            .and()
            .evaluationTypeEqualTo(selectedEvaluationType)
            .and()
            .academicYearEqualTo(selectedAcademicYear)
            .findFirst();

        if (existingMark != null) {
          // تحديث الدرجة الموجودة
          existingMark.mark = mark;
          await isar.subjectMarks.put(existingMark);
        } else {
          // إنشاء درجة جديدة
          final newMark = SubjectMark()
            ..mark = mark
            ..evaluationType = selectedEvaluationType
            ..academicYear = selectedAcademicYear;
          
          await isar.subjectMarks.put(newMark);
          
          // ربط الطالب والمادة
          newMark.student.value = student;
          newMark.subject.value = selectedSubject;
          await newMark.student.save();
          await newMark.subject.save();
        }
      });

      await _loadData(); // إعادة تحميل البيانات
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الدرجة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('خطأ في حفظ الدرجة: $e');
    }
  }

  void _showMarkDetailsDialog(Student student, SubjectMark? existingMark) {
    final markController = TextEditingController(
      text: existingMark?.mark?.toString() ?? '',
    );
    String evaluationType = existingMark?.evaluationType ?? selectedEvaluationType;
    String academicYear = existingMark?.academicYear ?? selectedAcademicYear;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('درجات ${student.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: markController,
              decoration: const InputDecoration(
                labelText: 'الدرجة',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: evaluationType,
              decoration: const InputDecoration(
                labelText: 'نوع التقييم',
                border: OutlineInputBorder(),
              ),
              items: evaluationTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => evaluationType = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: academicYear,
              decoration: const InputDecoration(
                labelText: 'السنة الدراسية',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => academicYear = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          if (existingMark != null)
            TextButton(
              onPressed: () async {
                await _deleteMark(existingMark);
                Navigator.pop(context);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () async {
              final mark = double.tryParse(markController.text);
              if (mark != null && selectedSubject != null) {
                await _saveDetailedMark(student, mark, evaluationType, academicYear);
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDetailedMark(Student student, double mark, String evaluationType, String academicYear) async {
    if (selectedSubject == null) return;

    try {
      await isar.writeTxn(() async {
        final existingMark = await isar.subjectMarks
            .filter()
            .student((q) => q.idEqualTo(student.id))
            .and()
            .subject((q) => q.idEqualTo(selectedSubject!.id))
            .and()
            .evaluationTypeEqualTo(evaluationType)
            .and()
            .academicYearEqualTo(academicYear)
            .findFirst();

        if (existingMark != null) {
          existingMark.mark = mark;
          existingMark.evaluationType = evaluationType;
          existingMark.academicYear = academicYear;
          await isar.subjectMarks.put(existingMark);
        } else {
          final newMark = SubjectMark()
            ..mark = mark
            ..evaluationType = evaluationType
            ..academicYear = academicYear;
          
          await isar.subjectMarks.put(newMark);
          
          newMark.student.value = student;
          newMark.subject.value = selectedSubject;
          await newMark.student.save();
          await newMark.subject.save();
        }
      });

      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الدرجة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('خطأ في حفظ الدرجة: $e');
    }
  }

  Future<void> _deleteMark(SubjectMark mark) async {
    try {
      await isar.writeTxn(() async {
        await isar.subjectMarks.delete(mark.id);
      });

      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الدرجة بنجاح'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      _showErrorDialog('خطأ في حذف الدرجة: $e');
    }
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    SchoolClass? selectedClassForSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة مادة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المادة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المادة (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                value: selectedClassForSubject,
                decoration: const InputDecoration(
                  labelText: 'الصف',
                  border: OutlineInputBorder(),
                ),
                items: classes.map((schoolClass) {
                  return DropdownMenuItem(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedClassForSubject != null) {
                  await _addSubject(
                    nameController.text,
                    descriptionController.text,
                    selectedClassForSubject!,
                  );
                  Navigator.pop(context);
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
    final descriptionController = TextEditingController(text: subject.description ?? '');
    SchoolClass? selectedClassForSubject = subject.schoolClass.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل المادة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المادة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المادة (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                value: selectedClassForSubject,
                decoration: const InputDecoration(
                  labelText: 'الصف',
                  border: OutlineInputBorder(),
                ),
                items: classes.map((schoolClass) {
                  return DropdownMenuItem(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedClassForSubject != null) {
                  await _updateSubject(
                    subject,
                    nameController.text,
                    descriptionController.text,
                    selectedClassForSubject!,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSubject(String name, String description, SchoolClass schoolClass) async {
    try {
      await isar.writeTxn(() async {
        final subject = Subject()
          ..name = name
          ..description = description.isNotEmpty ? description : null;
        
        await isar.subjects.put(subject);
        
        subject.schoolClass.value = schoolClass;
        await subject.schoolClass.save();
      });

      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة المادة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('خطأ في إضافة المادة: $e');
    }
  }

  Future<void> _updateSubject(Subject subject, String name, String description, SchoolClass schoolClass) async {
    try {
      await isar.writeTxn(() async {
        subject.name = name;
        subject.description = description.isNotEmpty ? description : null;
        await isar.subjects.put(subject);
        
        subject.schoolClass.value = schoolClass;
        await subject.schoolClass.save();
      });

      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث المادة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('خطأ في تحديث المادة: $e');
    }
  }

  Future<void> _deleteSubject(Subject subject) async {
    final hasMarks = marks.any((mark) => mark.subject.value?.id == subject.id);
    
    if (hasMarks) {
      _showErrorDialog('لا يمكن حذف المادة لأنها تحتوي على درجات مسجلة');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المادة "${subject.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await isar.writeTxn(() async {
          await isar.subjects.delete(subject.id);
        });

        await _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المادة بنجاح'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        _showErrorDialog('خطأ في حذف المادة: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
