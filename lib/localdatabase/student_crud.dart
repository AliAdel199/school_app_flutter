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
    // Add the student
    await isar.students.put(student);
    student.schoolclass.save();

  });

  await isar.writeTxn(() async {
     // Generate initial fee status for the student
    final feeStatus = StudentFeeStatus()
      ..student.value = student
      ..annualFee=student.annualFee!
      ..dueAmount = student.annualFee // Assuming annualFee is the total fee
      ..studentId = student.id.toString()
      ..lastPaymentDate
      ..academicYear = student.registrationYear ?? DateTime.now().year.toString()
      ..createdAt = DateTime.now()
      ..paidAmount = 0.0 // Initial paid amount
      ..lastPaymentDate = null // No payments made yet  
      ..nextDueDate = DateTime.now().add(Duration(days: 30)) // Set next due date to 30 days from now
;       // or any default status you want

    await isar.studentFeeStatus.put(feeStatus);
    student.feeStatus.value = feeStatus; // Link the fee status to the student
    await feeStatus.student.save();
    await student.feeStatus.save();
    
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
Future<void> addStudentPayment(Isar isar, StudentPayment payment,Student student,String studentId,String academicYear,DateTime nextDueDate) async {
  await isar.writeTxn(() async {
    await isar.studentPayments.put(payment);
 final feeStatus = await isar.studentFeeStatus
                            .filter()
                            .studentIdEqualTo(studentId)
                            .academicYearEqualTo(academicYear)
                            .findFirst();
                            print(feeStatus!.annualFee);

                        if (feeStatus != null) {
                          final payments = await isar.studentPayments
                              .filter()
                              .studentIdEqualTo(studentId)
                              .academicYearEqualTo(academicYear)
                              .findAll();

                          double totalPaid = 0;
                          DateTime? lastDate;

                          for (final p in payments) {
                            totalPaid += p.amount;
                            if (lastDate == null || p.paidAt.isAfter(lastDate)) {
                              lastDate = p.paidAt;
                            }
                          }

                          final due = (feeStatus.annualFee) - totalPaid;

                          
                            feeStatus.paidAmount = totalPaid;
                            feeStatus.dueAmount = due;
                            feeStatus.lastPaymentDate = lastDate;
                            feeStatus.nextDueDate = nextDueDate;


    await isar.studentFeeStatus.put(feeStatus);



  

}
}
);

}

Future<List<StudentPayment>> getAllStudentPayments(Isar isar) async {
  return await isar.studentPayments.where().findAll();
}

Future<void> deleteStudentPayment(Isar isar, int id,String studentId,String academicYear) async {
  await isar.writeTxn(() async {
    
  });
    await isar.writeTxn(() async {
    await isar.studentPayments.delete(id);
 final feeStatus = await isar.studentFeeStatus
                            .filter()
                            .studentIdEqualTo(studentId)
                            .academicYearEqualTo(academicYear)
                            .findFirst();
                            print(feeStatus!.annualFee);

                        if (feeStatus != null) {
                          final payments = await isar.studentPayments
                              .filter()
                              .studentIdEqualTo(studentId)
                              .academicYearEqualTo(academicYear)
                              .findAll();

                          double totalPaid = 0;
                          DateTime? lastDate;

                          for (final p in payments) {
                            totalPaid += p.amount;
                            if (lastDate == null || p.paidAt.isAfter(lastDate)) {
                              lastDate = p.paidAt;
                            }
                          }

                          final due = (feeStatus.annualFee) - totalPaid;

                          
                            feeStatus.paidAmount = totalPaid;
                            feeStatus.dueAmount = due;
                            feeStatus.lastPaymentDate = lastDate;


    await isar.studentFeeStatus.put(feeStatus);



  

}
}
);

  
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

    schoolClass.grade.save(); // Save the grades associated with the class
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

  // Example: Fetch a school by its id (assuming grade.schoolId exists)
 
    final school = await isar.schools.where().findFirst();
    // You can use the fetched school object as needed here
  
  
  await isar.writeTxn(() async {
    grade.school.value=school!;
    await isar.grades.put(grade);
    school.grades.add(grade);
    grade.school.save();
    school.grades.save();


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
    grade.classes.save();
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
