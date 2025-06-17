import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/subject.dart';

import 'class.dart';
import 'grade.dart';
import 'school.dart';
import 'student.dart';
import 'student_fee_status.dart';
import 'student_payment.dart';


//
// 🧑‍🎓 Student
//
Future<void> addStudent(Isar isar, Student student) async {
  await isar.writeTxn(() async {
    await isar.students.put(student);
  });
}

Future<List<Student>> getAllStudents(Isar isar) async {
  return await isar.students.where().findAll();
}

Future<Student?> getStudentById(Isar isar, int id) async {
  return await isar.students.get(id);
}

Future<void> updateStudent(Isar isar, Student student) async {
  await isar.writeTxn(() async {
    await isar.students.put(student);
  });
}

Future<void> deleteStudent(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.students.delete(id);
  });
}

//
// 💳 StudentPayment
//
Future<void> addStudentPayment(Isar isar, StudentPayment payment) async {
  await isar.writeTxn(() async {
    await isar.studentPayments.put(payment);
  });
}

Future<List<StudentPayment>> getAllStudentPayments(Isar isar) async {
  return await isar.studentPayments.where().findAll();
}

Future<void> deleteStudentPayment(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.studentPayments.delete(id);
  });
}

//
// 💵 StudentFeeStatus
//
Future<void> addFeeStatus(Isar isar, StudentFeeStatus status) async {
  await isar.writeTxn(() async {
    await isar.studentFeeStatus.put(status);
  });
}

Future<List<StudentFeeStatus>> getAllFeeStatuses(Isar isar) async {
  return await isar.studentFeeStatus.where().findAll();
}

Future<void> deleteFeeStatus(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.studentFeeStatus.delete(id);
  });
}

//
// 🏫 SchoolClass
//
Future<void> addClass(Isar isar, SchoolClass schoolClass) async {
  await isar.writeTxn(() async {
    await isar.schoolClass.put(schoolClass);
  });
}

Future<List<SchoolClass>> getAllClasses(Isar isar) async {
  return await isar.schoolClass.where().findAll();
}

Future<SchoolClass?> getClassById(Isar isar, int id) async {
  return await isar.schoolClass.get(id);
}

Future<void> updateClass(Isar isar, SchoolClass schoolClass) async {
  await isar.writeTxn(() async {
    await isar.schoolClass.put(schoolClass);
  });
}

Future<void> deleteClass(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.schoolClass.delete(id);
  });
}

//
// 🎓 Grade
//
Future<void> addGrade(Isar isar, Grade grade) async {
  await isar.writeTxn(() async {
    await isar.grades.put(grade);
  });
}

Future<List<Grade>> getAllGrades(Isar isar) async {
  return await isar.grades.where().findAll();
}

Future<Grade?> getGradeById(Isar isar, int id) async {
  return await isar.grades.get(id);
}

Future<void> updateGrade(Isar isar, Grade grade) async {
  await isar.writeTxn(() async {
    await isar.grades.put(grade);
  });
}

Future<void> deleteGrade(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.grades.delete(id);
  });
}

//
// 🏫 School
//
Future<void> addSchool(Isar isar, School school) async {
  await isar.writeTxn(() async {
    await isar.schools.put(school);
  });
}

Future<List<School>> getAllSchools(Isar isar) async {
  return await isar.schools.where().findAll();
}

Future<School?> getSchoolById(Isar isar, int id) async {
  return await isar.schools.get(id);
}

Future<void> updateSchool(Isar isar, School school) async {
  await isar.writeTxn(() async {
    await isar.schools.put(school);
  });
}

Future<void> deleteSchool(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.schools.delete(id);
  });
}

//
// 📘 Subject
//
Future<void> addSubject(Isar isar, Subject subject) async {
  await isar.writeTxn(() async {
    await isar.subjects.put(subject);
  });
}

Future<List<Subject>> getAllSubjects(Isar isar) async {
  return await isar.subjects.where().findAll();
}

Future<Subject?> getSubjectById(Isar isar, int id) async {
  return await isar.subjects.get(id);
}

Future<void> updateSubject(Isar isar, Subject subject) async {
  await isar.writeTxn(() async {
    await isar.subjects.put(subject);
  });
}

Future<void> deleteSubject(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.subjects.delete(id);
  });
}
