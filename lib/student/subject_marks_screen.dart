import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/subject.dart';
import '../localdatabase/subject_mark.dart';
import '../localdatabase/class.dart';
import '../localdatabase/student_crud.dart';
import '../main.dart';

class SubjectMarksScreen extends StatefulWidget {
  const SubjectMarksScreen({Key? key}) : super(key: key);

  @override
  State<SubjectMarksScreen> createState() => _SubjectMarksScreenState();
}

class _SubjectMarksScreenState extends State<SubjectMarksScreen> {
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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      // استخدام الوظائف من student_crud
      students = await getAllStudents(isar);
      classes = await getAllClasses(isar);
      
      // جلب المواد والدرجات بطريقة بديلة
      final subjectsQuery = isar.subjects.where();
      subjects = await subjectsQuery.findAll();
      
      final marksQuery = isar.subjectMarks.where();
      marks = await marksQuery.findAll();

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

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorMessage('خطأ في تحميل البيانات: $e');
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltersCard(),
                Expanded(child: _buildMarksSection()),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _showAddSubjectDialog,
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            heroTag: "add_subject",
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showStatsDialog,
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            heroTag: "show_stats",
            child: const Icon(Icons.analytics),
          ),
        ],
      ),
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
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'فلترة البيانات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'عدد الطلاب: ${filteredStudents.length}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
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
                      prefixIcon: Icon(Icons.class_),
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
                        selectedSubject = null;
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
                      prefixIcon: Icon(Icons.subject),
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
                      prefixIcon: Icon(Icons.assignment),
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
                      prefixIcon: Icon(Icons.calendar_today),
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

  Widget _buildMarksSection() {
    if (filteredStudents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد طلاب في الصف المحدد',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentMarksCard(student);
      },
    );
  }

  Widget _buildStudentMarksCard(Student student) {
    // البحث عن درجة الطالب في المادة المحددة
    SubjectMark? existingMark;
    if (selectedSubject != null) {
      try {
        existingMark = marks.firstWhere((mark) =>
          mark.student.value?.id == student.id &&
          mark.subject.value?.id == selectedSubject!.id &&
          mark.evaluationType == selectedEvaluationType &&
          mark.academicYear == selectedAcademicYear
        );
      } catch (e) {
        existingMark = null;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                student.fullName.substring(0, 1),
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                    final mark = double.tryParse(value);
                    if (mark != null && mark >= 0 && mark <= 100) {
                      _saveMark(student, mark);
                    } else {
                      _showErrorMessage('يرجى إدخال درجة صحيحة بين 0 و 100');
                    }
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

  Future<void> _saveMark(Student student, double mark) async {
    if (selectedSubject == null) return;

    try {
      await isar.writeTxn(() async {
        // البحث عن درجة موجودة
        SubjectMark? existingMark;
        for (var m in marks) {
          if (m.student.value?.id == student.id &&
              m.subject.value?.id == selectedSubject!.id &&
              m.evaluationType == selectedEvaluationType &&
              m.academicYear == selectedAcademicYear) {
            existingMark = m;
            break;
          }
        }

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
      _showSuccessMessage('تم حفظ الدرجة بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في حفظ الدرجة: $e');
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
        title: Row(
          children: [
            const Icon(Icons.grade),
            const SizedBox(width: 8),
            Expanded(child: Text('درجات ${student.fullName}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: markController,
              decoration: const InputDecoration(
                labelText: 'الدرجة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.score),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: evaluationType,
              decoration: const InputDecoration(
                labelText: 'نوع التقييم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
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
                prefixIcon: Icon(Icons.calendar_today),
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
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: const Text('هل أنت متأكد من حذف هذه الدرجة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('لا'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('نعم'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _deleteMark(existingMark);
                  Navigator.pop(context);
                }
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () async {
              final mark = double.tryParse(markController.text);
              if (mark != null && mark >= 0 && mark <= 100 && selectedSubject != null) {
                await _saveDetailedMark(student, mark, evaluationType, academicYear);
                Navigator.pop(context);
              } else {
                _showErrorMessage('يرجى إدخال درجة صحيحة بين 0 و 100');
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
        SubjectMark? existingMark;
        for (var m in marks) {
          if (m.student.value?.id == student.id &&
              m.subject.value?.id == selectedSubject!.id &&
              m.evaluationType == evaluationType &&
              m.academicYear == academicYear) {
            existingMark = m;
            break;
          }
        }

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
      _showSuccessMessage('تم حفظ الدرجة بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في حفظ الدرجة: $e');
    }
  }

  Future<void> _deleteMark(SubjectMark mark) async {
    try {
      await isar.writeTxn(() async {
        await isar.subjectMarks.delete(mark.id);
      });

      await _loadData();
      _showSuccessMessage('تم حذف الدرجة بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في حذف الدرجة: $e');
    }
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    SchoolClass? selectedClassForSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('إضافة مادة جديدة'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المادة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المادة (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                value: selectedClassForSubject,
                decoration: const InputDecoration(
                  labelText: 'الصف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                items: classes.map((schoolClass) {
                  return DropdownMenuItem(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
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
                } else {
                  _showErrorMessage('يرجى ملء جميع الحقول المطلوبة');
                }
              },
              child: const Text('إضافة'),
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
      _showSuccessMessage('تمت إضافة المادة بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في إضافة المادة: $e');
    }
  }

  void _showStatsDialog() {
    if (selectedClass == null || selectedSubject == null) {
      _showErrorMessage('يرجى اختيار صف ومادة لعرض الإحصائيات');
      return;
    }

    final subjectMarks = marks.where((mark) =>
      mark.subject.value?.id == selectedSubject!.id &&
      mark.evaluationType == selectedEvaluationType &&
      mark.academicYear == selectedAcademicYear
    ).toList();

    if (subjectMarks.isEmpty) {
      _showErrorMessage('لا توجد درجات مسجلة لهذه المادة');
      return;
    }

    final validMarks = subjectMarks.where((mark) => mark.mark != null).map((mark) => mark.mark!).toList();
    
    if (validMarks.isEmpty) {
      _showErrorMessage('لا توجد درجات صحيحة');
      return;
    }

    final average = validMarks.reduce((a, b) => a + b) / validMarks.length;
    final highest = validMarks.reduce((a, b) => a > b ? a : b);
    final lowest = validMarks.reduce((a, b) => a < b ? a : b);
    final passCount = validMarks.where((mark) => mark >= 50).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.analytics),
            const SizedBox(width: 8),
            Expanded(child: Text('إحصائيات ${selectedSubject!.name}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('عدد الطلاب المقيمين', validMarks.length.toString()),
            _buildStatRow('المتوسط', average.toStringAsFixed(2)),
            _buildStatRow('أعلى درجة', highest.toString()),
            _buildStatRow('أقل درجة', lowest.toString()),
            _buildStatRow('عدد الناجحين', passCount.toString()),
            _buildStatRow('نسبة النجاح', '${(passCount / validMarks.length * 100).toStringAsFixed(1)}%'),
          ],
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
