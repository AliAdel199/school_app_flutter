import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../localdatabase/student.dart';
import '../localdatabase/subject.dart';
import '../localdatabase/subject_mark.dart';
import '../localdatabase/class.dart';
import '../main.dart';

class MarksManagementScreen extends StatefulWidget {
  const MarksManagementScreen({Key? key}) : super(key: key);

  @override
  State<MarksManagementScreen> createState() => _MarksManagementScreenState();
}

class _MarksManagementScreenState extends State<MarksManagementScreen> {
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

  // دالة للتحقق من صحة البيانات قبل استخدامها
  bool _isValidClass(SchoolClass? schoolClass) {
    if (schoolClass == null) return false;
    return schoolClass.id.isFinite && 
           schoolClass.id > 0 && 
           schoolClass.name.isNotEmpty &&
           classes.any((c) => c.id == schoolClass.id);
  }

  bool _isValidSubject(Subject? subject) {
    if (subject == null) return false;
    return subject.id.isFinite && 
           subject.id > 0 && 
           subject.name.isNotEmpty &&
           subjects.any((s) => s.id == subject.id);
  }

  Future<void> _refreshMarks() async {
    try {
      // تحديث الدرجات فقط بدلاً من إعادة تحميل كل شيء
      marks = await isar.subjectMarks.where().findAll();
      
      // تحميل العلاقات للدرجات الجديدة
      for (var mark in marks) {
        await mark.student.load();
        await mark.subject.load();
      }
      
      setState(() {});
    } catch (e) {
      debugPrint('خطأ في تحديث الدرجات: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      // استخدام نفس الطريقة المستخدمة في الملفات الأخرى
      final allStudents = await isar.students.where().findAll();
      final allSubjects = await isar.subjects.where().findAll();
      final allMarks = await isar.subjectMarks.where().findAll();
      final allClasses = await isar.schoolClass.where().findAll();

      // إزالة التكرار من الصفوف مع فحص دقيق
      final uniqueClasses = <int, SchoolClass>{};
      for (var schoolClass in allClasses) {
        if (schoolClass.id.isFinite && schoolClass.id > 0 && schoolClass.name.isNotEmpty) {
          uniqueClasses[schoolClass.id] = schoolClass;
        }
      }
      classes = uniqueClasses.values.toList();

      // إزالة التكرار من المواد
      final uniqueSubjects = <int, Subject>{};
      for (var subject in allSubjects) {
        if (subject.id.isFinite && subject.id > 0 && subject.name.isNotEmpty) {
          uniqueSubjects[subject.id] = subject;
        }
      }
      subjects = uniqueSubjects.values.toList();

      // إزالة التكرار من الطلاب
      final uniqueStudents = <int, Student>{};
      for (var student in allStudents) {
        if (student.id.isFinite && student.id > 0 && student.fullName.isNotEmpty) {
          uniqueStudents[student.id] = student;
        }
      }
      students = uniqueStudents.values.toList();

      // إزالة التكرار من الدرجات
      final uniqueMarks = <int, SubjectMark>{};
      for (var mark in allMarks) {
        if (mark.id.isFinite && mark.id > 0) {
          uniqueMarks[mark.id] = mark;
        }
      }
      marks = uniqueMarks.values.toList();

      // تحميل العلاقات
      for (var student in students) {
        try {
          await student.schoolclass.load();
        } catch (e) {
          debugPrint('خطأ في تحميل صف الطالب ${student.fullName}: $e');
        }
      }
      
      for (var subject in subjects) {
        try {
          await subject.schoolClass.load();
        } catch (e) {
          debugPrint('خطأ في تحميل صف المادة ${subject.name}: $e');
        }
      }
      
      for (var mark in marks) {
        try {
          await mark.student.load();
          await mark.subject.load();
        } catch (e) {
          debugPrint('خطأ في تحميل علاقات الدرجة: $e');
        }
      }

      // التحقق من صحة الاختيارات الحالية وإعادة تعيينها إذا لزم الأمر
      if (selectedClass != null) {
        final classStillExists = classes.any((c) => c.id == selectedClass!.id);
        if (!classStillExists) {
          selectedClass = null;
          selectedSubject = null;
        } else {
          // إعادة تعيين الصف المختار من القائمة الجديدة لتجنب مشاكل المراجع
          try {
            selectedClass = classes.firstWhere((c) => c.id == selectedClass!.id);
          } catch (e) {
            selectedClass = null;
            selectedSubject = null;
          }
          
          if (selectedSubject != null) {
            // التحقق من أن المادة المختارة لا تزال متاحة للصف المختار
            final subjectStillValid = subjects.any((s) => 
              s.id == selectedSubject!.id && 
              s.schoolClass.value?.id == selectedClass!.id);
            if (!subjectStillValid) {
              selectedSubject = null;
            } else {
              // إعادة تعيين المادة المختارة من القائمة الجديدة
              try {
                selectedSubject = subjects.firstWhere((s) => s.id == selectedSubject!.id);
              } catch (e) {
                selectedSubject = null;
              }
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('خطأ في تحميل البيانات: $e');
      debugPrint('خطأ في _loadData: $e');
    }
  }

  List<Student> get filteredStudents {
    if (selectedClass == null) return students;
    return students.where((student) => 
      student.schoolclass.value?.id == selectedClass!.id).toList();
  }

  List<Subject> get filteredSubjects {
    if (selectedClass == null) return [];
    
    try {
      final filtered = subjects.where((subject) => 
        subject.schoolClass.value?.id == selectedClass!.id).toList();
      
      // إزالة أي تكرارات محتملة
      final uniqueFiltered = <int, Subject>{};
      for (var subject in filtered) {
        uniqueFiltered[subject.id] = subject;
      }
      
      final result = uniqueFiltered.values.toList();
      
      // التأكد من أن selectedSubject لا يزال في القائمة المفلترة
      if (selectedSubject != null && !result.any((s) => s.id == selectedSubject!.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              selectedSubject = null;
            });
          }
        });
      }
      
      return result;
    } catch (e) {
      debugPrint('خطأ في filteredSubjects: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المواد والدرجات'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showSubjectsManagementDialog,
            icon: const Icon(Icons.list),
            tooltip: 'إدارة المواد',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltersCard(),
                Expanded(child: _buildMarksSection()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مادة'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
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
            const Text(
              'فلترة البيانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // التأكد من أن selectedClass موجود في القائمة
                      SchoolClass? validSelectedClass = selectedClass;
                      final currentClasses = classes.where((c) => _isValidClass(c)).toList();
                      
                      if (!_isValidClass(selectedClass) || 
                          !currentClasses.any((c) => c.id == selectedClass!.id)) {
                        validSelectedClass = null;
                        // تحديث selectedClass في الحالة أيضاً
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              selectedClass = null;
                              selectedSubject = null;
                            });
                          }
                        });
                      }

                      return DropdownButtonFormField<SchoolClass>(
                        value: validSelectedClass,
                        decoration: const InputDecoration(
                          labelText: 'الصف',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<SchoolClass>(
                            value: null,
                            child: Text('اختر الصف'),
                          ),
                          ...currentClasses.map((schoolClass) {
                            return DropdownMenuItem(
                              key: ValueKey('class_${schoolClass.id}'),
                              value: schoolClass,
                              child: Text(schoolClass.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                            selectedSubject = null;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),              
                Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          // التأكد من أن selectedSubject موجود في filteredSubjects
                          Subject? validSelectedSubject = selectedSubject;
                          final currentFilteredSubjects = filteredSubjects.where((s) => _isValidSubject(s)).toList();
                          
                          if (!_isValidSubject(selectedSubject) || 
                              !currentFilteredSubjects.any((s) => s.id == selectedSubject!.id)) {
                            validSelectedSubject = null;
                            // تحديث selectedSubject في الحالة أيضاً
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  selectedSubject = null;
                                });
                              }
                            });
                          }
                          
                          return DropdownButtonFormField<Subject>(
                            value: validSelectedSubject,
                            decoration: const InputDecoration(
                              labelText: 'المادة',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<Subject>(
                                value: null,
                                child: Text('اختر المادة'),
                              ),
                              ...currentFilteredSubjects.map((subject) {
                                return DropdownMenuItem(
                                  key: ValueKey('subject_${subject.id}'),
                                  value: subject,
                                  child: Text(subject.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedSubject = value;
                                // إعادة تحديث واجهة المستخدم لإزالة الدرجات السابقة
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (selectedSubject != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showDeleteSubjectDialog(selectedSubject!),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'حذف المادة',
                      ),
                    ],
                  ],
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

  Widget _buildMarksSection() {
    if (filteredStudents.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد طلاب في الصف المحدد',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
      key: ValueKey('${student.id}_${selectedSubject?.id ?? 'no_subject'}_${selectedEvaluationType}_$selectedAcademicYear'),
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
                  key: ValueKey('mark_input_${student.id}_${selectedSubject?.id}_${selectedEvaluationType}_$selectedAcademicYear'),
                  initialValue: existingMark?.mark?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: 'الدرجة',
                    border: const OutlineInputBorder(),
                    hintText: '0-${selectedSubject!.maxMark.toStringAsFixed(0)}',
                    suffixText: 'من ${selectedSubject!.maxMark.toStringAsFixed(0)}',
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

  Future<void> _saveMark(Student student, double? mark) async {
    if (selectedSubject == null || mark == null) return;

    // التحقق من أن الدرجة لا تتجاوز الحد الأقصى
    if (mark > selectedSubject!.maxMark) {
      _showErrorDialog('الدرجة لا يمكن أن تتجاوز ${selectedSubject!.maxMark.toStringAsFixed(0)}');
      return;
    }

    if (mark < 0) {
      _showErrorDialog('الدرجة لا يمكن أن تكون أقل من 0');
      return;
    }

    try {
      await isar.writeTxn(() async {
        // البحث عن درجة موجودة باستخدام where
        final existingMarks = await isar.subjectMarks.where().findAll();
        SubjectMark? existingMark;
        
        for (var m in existingMarks) {
          await m.student.load();
          await m.subject.load();
          
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

      await _refreshMarks(); // تحديث الدرجات فقط
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الدرجة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في حفظ الدرجة: $e');
    }
  }

  void _showMarkDetailsDialog(Student student, SubjectMark? existingMark) {
    final markController = TextEditingController(
      text: existingMark?.mark?.toString() ?? '',
    );
    
    // التأكد من أن نوع التقييم موجود في القائمة
    String evaluationType = selectedEvaluationType;
    if (existingMark?.evaluationType != null && 
        evaluationTypes.contains(existingMark!.evaluationType!)) {
      evaluationType = existingMark.evaluationType!;
    }
    
    String academicYear = existingMark?.academicYear ?? selectedAcademicYear;
    
    // التأكد من أن السنة الدراسية ليست فارغة
    if (academicYear.trim().isEmpty) {
      academicYear = selectedAcademicYear;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                onChanged: (value) {
                  setDialogState(() {
                    evaluationType = value!;
                  });
                },
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
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: () async {
                final mark = double.tryParse(markController.text);
                if (mark != null && selectedSubject != null) {
                  await _saveDetailedMark(student, mark, evaluationType, academicYear);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDetailedMark(Student student, double mark, String evaluationType, String academicYear) async {
    if (selectedSubject == null) return;

    try {
      await isar.writeTxn(() async {
        final existingMarks = await isar.subjectMarks.where().findAll();
        SubjectMark? existingMark;
        
        for (var m in existingMarks) {
          await m.student.load();
          await m.subject.load();
          
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

      await _refreshMarks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الدرجة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في حفظ الدرجة: $e');
    }
  }

  Future<void> _deleteMark(SubjectMark mark) async {
    try {
      await isar.writeTxn(() async {
        await isar.subjectMarks.delete(mark.id);
      });

      await _refreshMarks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الدرجة بنجاح'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في حذف الدرجة: $e');
    }
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final maxMarkController = TextEditingController(text: '100'); // قيمة افتراضية
    SchoolClass? selectedClassForSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة مادة جديدة'),
          content: SingleChildScrollView(
            child: Column(
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
                TextFormField(
                  controller: maxMarkController,
                  decoration: const InputDecoration(
                    labelText: 'الدرجة الكاملة',
                    border: OutlineInputBorder(),
                    hintText: 'مثال: 100, 50, 10',
                    suffixText: 'درجة',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    // التأكد من أن القيمة المحددة موجودة في القائمة
                    SchoolClass? validSelectedClass = selectedClassForSubject;
                    if (selectedClassForSubject != null && 
                        !classes.any((c) => c.id == selectedClassForSubject!.id)) {
                      validSelectedClass = null;
                    }
                    
                    return DropdownButtonFormField<SchoolClass>(
                      value: validSelectedClass,
                      decoration: const InputDecoration(
                        labelText: 'الصف',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<SchoolClass>(
                          value: null,
                          child: Text('اختر الصف'),
                        ),
                        ...classes.map((schoolClass) {
                          return DropdownMenuItem(
                            key: ValueKey('add_subject_class_${schoolClass.id}'),
                            value: schoolClass,
                            child: Text(schoolClass.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedClassForSubject = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && 
                    selectedClassForSubject != null &&
                    maxMarkController.text.isNotEmpty) {
                  final maxMark = double.tryParse(maxMarkController.text) ?? 100.0;
                  await _addSubject(
                    nameController.text,
                    descriptionController.text,
                    maxMark,
                    selectedClassForSubject!,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSubject(String name, String description, double maxMark, SchoolClass schoolClass) async {
    try {
      await isar.writeTxn(() async {
        final subject = Subject()
          ..name = name
          ..description = description.isNotEmpty ? description : null
          ..maxMark = maxMark;
        
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

  void _showSubjectsManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.subject, color: Colors.blue),
            SizedBox(width: 8),
            Text('إدارة المواد'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: subjects.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد مواد مضافة بعد',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            subject.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          subject.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subject.description != null)
                              Text(subject.description!),
                            Text(
                              'الصف: ${subject.schoolClass.value?.name ?? 'غير محدد'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'الدرجة الكاملة: ${subject.maxMark.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showEditSubjectDialog(subject),
                              icon: const Icon(Icons.edit),
                              color: Colors.orange,
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showDeleteSubjectDialog(subject);
                              },
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              tooltip: 'حذف',
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showAddSubjectDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة مادة جديدة'),
          ),
        ],
      ),
    );
  }

  void _showEditSubjectDialog(Subject subject) {
    final nameController = TextEditingController(text: subject.name);
    final descriptionController = TextEditingController(text: subject.description ?? '');
    final maxMarkController = TextEditingController(text: subject.maxMark.toString());
    
    // العثور على الصف المطابق من القائمة الحالية بدلاً من استخدام المرجع المحفوظ
    SchoolClass? selectedClassForSubject;
    if (subject.schoolClass.value != null) {
      try {
        selectedClassForSubject = classes.firstWhere(
          (c) => c.id == subject.schoolClass.value!.id
        );
      } catch (e) {
        selectedClassForSubject = null;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تعديل المادة'),
          content: SingleChildScrollView(
            child: Column(
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
                TextFormField(
                  controller: maxMarkController,
                  decoration: const InputDecoration(
                    labelText: 'الدرجة الكاملة',
                    border: OutlineInputBorder(),
                    hintText: 'مثال: 100, 50, 10',
                    suffixText: 'درجة',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    // التأكد من أن القيمة المحددة موجودة في القائمة
                    SchoolClass? validSelectedClass = selectedClassForSubject;
                    if (selectedClassForSubject != null && 
                        !classes.any((c) => c.id == selectedClassForSubject!.id)) {
                      validSelectedClass = null;
                    }
                    
                    return DropdownButtonFormField<SchoolClass>(
                      value: validSelectedClass,
                      decoration: const InputDecoration(
                        labelText: 'الصف',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<SchoolClass>(
                          value: null,
                          child: Text('اختر الصف'),
                        ),
                        ...classes.map((schoolClass) {
                          return DropdownMenuItem(
                            key: ValueKey('edit_subject_class_${schoolClass.id}'),
                            value: schoolClass,
                            child: Text(schoolClass.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedClassForSubject = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && 
                    selectedClassForSubject != null &&
                    maxMarkController.text.isNotEmpty) {
                  final maxMark = double.tryParse(maxMarkController.text) ?? subject.maxMark;
                  await _editSubject(
                    subject,
                    nameController.text,
                    descriptionController.text,
                    maxMark,
                    selectedClassForSubject!,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('حفظ التعديل'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editSubject(Subject subject, String name, String description, double maxMark, SchoolClass schoolClass) async {
    try {
      await isar.writeTxn(() async {
        subject.name = name;
        subject.description = description.isNotEmpty ? description : null;
        subject.maxMark = maxMark;
        
        await isar.subjects.put(subject);
        
        subject.schoolClass.value = schoolClass;
        await subject.schoolClass.save();
      });

      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تعديل المادة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في تعديل المادة: $e');
    }
  }

  void _showDeleteSubjectDialog(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف المادة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'هل أنت متأكد من حذف المادة "${subject.name}"؟',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم حذف جميع الدرجات المسجلة لهذه المادة أيضاً.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
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
              await _deleteSubject(subject);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubject(Subject subject) async {
    try {
      await isar.writeTxn(() async {
        // أولاً حذف جميع الدرجات المرتبطة بهذه المادة
        final relatedMarks = await isar.subjectMarks.where().findAll();
        final marksToDelete = <SubjectMark>[];
        
        for (var mark in relatedMarks) {
          await mark.subject.load();
          if (mark.subject.value?.id == subject.id) {
            marksToDelete.add(mark);
          }
        }
        
        // حذف الدرجات المرتبطة
        for (var mark in marksToDelete) {
          await isar.subjectMarks.delete(mark.id);
        }
        
        // ثم حذف المادة نفسها
        await isar.subjects.delete(subject.id);
      });

      // إذا كانت المادة المحذوفة هي المادة المختارة حالياً، قم بإلغاء الاختيار
      if (selectedSubject?.id == subject.id) {
        setState(() {
          selectedSubject = null;
        });
      }

      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف المادة "${subject.name}" وجميع درجاتها بنجاح'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في حذف المادة: $e');
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
