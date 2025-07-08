// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_fee_status.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudentFeeStatusCollection on Isar {
  IsarCollection<StudentFeeStatus> get studentFeeStatus => this.collection();
}

const StudentFeeStatusSchema = CollectionSchema(
  name: r'StudentFeeStatus',
  id: 5393248281005459395,
  properties: {
    r'academicYear': PropertySchema(
      id: 0,
      name: r'academicYear',
      type: IsarType.string,
    ),
    r'annualFee': PropertySchema(
      id: 1,
      name: r'annualFee',
      type: IsarType.double,
    ),
    r'className': PropertySchema(
      id: 2,
      name: r'className',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'discountAmount': PropertySchema(
      id: 4,
      name: r'discountAmount',
      type: IsarType.double,
    ),
    r'discountDetails': PropertySchema(
      id: 5,
      name: r'discountDetails',
      type: IsarType.string,
    ),
    r'dueAmount': PropertySchema(
      id: 6,
      name: r'dueAmount',
      type: IsarType.double,
    ),
    r'lastPaymentDate': PropertySchema(
      id: 7,
      name: r'lastPaymentDate',
      type: IsarType.dateTime,
    ),
    r'nextDueDate': PropertySchema(
      id: 8,
      name: r'nextDueDate',
      type: IsarType.dateTime,
    ),
    r'originalDebtAcademicYear': PropertySchema(
      id: 9,
      name: r'originalDebtAcademicYear',
      type: IsarType.string,
    ),
    r'originalDebtClassName': PropertySchema(
      id: 10,
      name: r'originalDebtClassName',
      type: IsarType.string,
    ),
    r'paidAmount': PropertySchema(
      id: 11,
      name: r'paidAmount',
      type: IsarType.double,
    ),
    r'studentId': PropertySchema(
      id: 12,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'transferredDebtAmount': PropertySchema(
      id: 13,
      name: r'transferredDebtAmount',
      type: IsarType.double,
    )
  },
  estimateSize: _studentFeeStatusEstimateSize,
  serialize: _studentFeeStatusSerialize,
  deserialize: _studentFeeStatusDeserialize,
  deserializeProp: _studentFeeStatusDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'student': LinkSchema(
      id: 7416850582509935049,
      name: r'student',
      target: r'Student',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _studentFeeStatusGetId,
  getLinks: _studentFeeStatusGetLinks,
  attach: _studentFeeStatusAttach,
  version: '3.1.0+1',
);

int _studentFeeStatusEstimateSize(
  StudentFeeStatus object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYear.length * 3;
  bytesCount += 3 + object.className.length * 3;
  {
    final value = object.discountDetails;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.originalDebtAcademicYear;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.originalDebtClassName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.studentId.length * 3;
  return bytesCount;
}

void _studentFeeStatusSerialize(
  StudentFeeStatus object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYear);
  writer.writeDouble(offsets[1], object.annualFee);
  writer.writeString(offsets[2], object.className);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDouble(offsets[4], object.discountAmount);
  writer.writeString(offsets[5], object.discountDetails);
  writer.writeDouble(offsets[6], object.dueAmount);
  writer.writeDateTime(offsets[7], object.lastPaymentDate);
  writer.writeDateTime(offsets[8], object.nextDueDate);
  writer.writeString(offsets[9], object.originalDebtAcademicYear);
  writer.writeString(offsets[10], object.originalDebtClassName);
  writer.writeDouble(offsets[11], object.paidAmount);
  writer.writeString(offsets[12], object.studentId);
  writer.writeDouble(offsets[13], object.transferredDebtAmount);
}

StudentFeeStatus _studentFeeStatusDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudentFeeStatus();
  object.academicYear = reader.readString(offsets[0]);
  object.annualFee = reader.readDouble(offsets[1]);
  object.className = reader.readString(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.discountAmount = reader.readDouble(offsets[4]);
  object.discountDetails = reader.readStringOrNull(offsets[5]);
  object.dueAmount = reader.readDoubleOrNull(offsets[6]);
  object.id = id;
  object.lastPaymentDate = reader.readDateTimeOrNull(offsets[7]);
  object.nextDueDate = reader.readDateTimeOrNull(offsets[8]);
  object.originalDebtAcademicYear = reader.readStringOrNull(offsets[9]);
  object.originalDebtClassName = reader.readStringOrNull(offsets[10]);
  object.paidAmount = reader.readDouble(offsets[11]);
  object.studentId = reader.readString(offsets[12]);
  object.transferredDebtAmount = reader.readDouble(offsets[13]);
  return object;
}

P _studentFeeStatusDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studentFeeStatusGetId(StudentFeeStatus object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studentFeeStatusGetLinks(StudentFeeStatus object) {
  return [object.student];
}

void _studentFeeStatusAttach(
    IsarCollection<dynamic> col, Id id, StudentFeeStatus object) {
  object.id = id;
  object.student.attach(col, col.isar.collection<Student>(), r'student', id);
}

extension StudentFeeStatusQueryWhereSort
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QWhere> {
  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StudentFeeStatusQueryWhere
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QWhereClause> {
  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudentFeeStatusQueryFilter
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QFilterCondition> {
  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'academicYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYear',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      academicYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      annualFeeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'annualFee',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      annualFeeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'annualFee',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      annualFeeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'annualFee',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      annualFeeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'annualFee',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'className',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'className',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discountDetails',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discountDetails',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discountDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discountDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discountDetails',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'discountDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'discountDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'discountDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'discountDetails',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discountDetails',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      discountDetailsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'discountDetails',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      dueAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueAmount',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      dueAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueAmount',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      dueAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      dueAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      dueAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      dueAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      lastPaymentDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPaymentDate',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      lastPaymentDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPaymentDate',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      lastPaymentDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPaymentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      lastPaymentDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPaymentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      lastPaymentDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPaymentDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      lastPaymentDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPaymentDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      nextDueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextDueDate',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      nextDueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextDueDate',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      nextDueDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      nextDueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      nextDueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      nextDueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextDueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalDebtAcademicYear',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalDebtAcademicYear',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalDebtAcademicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalDebtAcademicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalDebtAcademicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalDebtAcademicYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalDebtAcademicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalDebtAcademicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalDebtAcademicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalDebtAcademicYear',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalDebtAcademicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtAcademicYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalDebtAcademicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalDebtClassName',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalDebtClassName',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalDebtClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalDebtClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalDebtClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalDebtClassName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalDebtClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalDebtClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalDebtClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalDebtClassName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalDebtClassName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      originalDebtClassNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalDebtClassName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      paidAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      paidAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      paidAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      paidAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      transferredDebtAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transferredDebtAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      transferredDebtAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transferredDebtAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      transferredDebtAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transferredDebtAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      transferredDebtAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transferredDebtAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension StudentFeeStatusQueryObject
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QFilterCondition> {}

extension StudentFeeStatusQueryLinks
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QFilterCondition> {
  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      student(FilterQuery<Student> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'student');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterFilterCondition>
      studentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'student', 0, true, 0, true);
    });
  }
}

extension StudentFeeStatusQuerySortBy
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QSortBy> {
  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByAnnualFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByAnnualFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByDiscountDetails() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountDetails', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByDiscountDetailsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountDetails', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByDueAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByDueAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAmount', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByLastPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByLastPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByOriginalDebtAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtAcademicYear', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByOriginalDebtAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtAcademicYear', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByOriginalDebtClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtClassName', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByOriginalDebtClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtClassName', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByTransferredDebtAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredDebtAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      sortByTransferredDebtAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredDebtAmount', Sort.desc);
    });
  }
}

extension StudentFeeStatusQuerySortThenBy
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QSortThenBy> {
  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByAnnualFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByAnnualFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByDiscountDetails() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountDetails', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByDiscountDetailsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountDetails', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByDueAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByDueAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAmount', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByLastPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByLastPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByOriginalDebtAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtAcademicYear', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByOriginalDebtAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtAcademicYear', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByOriginalDebtClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtClassName', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByOriginalDebtClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalDebtClassName', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByTransferredDebtAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredDebtAmount', Sort.asc);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QAfterSortBy>
      thenByTransferredDebtAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferredDebtAmount', Sort.desc);
    });
  }
}

extension StudentFeeStatusQueryWhereDistinct
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct> {
  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByAcademicYear({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYear', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByAnnualFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'annualFee');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountAmount');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByDiscountDetails({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountDetails',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByDueAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueAmount');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByLastPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPaymentDate');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextDueDate');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByOriginalDebtAcademicYear({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalDebtAcademicYear',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByOriginalDebtClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalDebtClassName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAmount');
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentFeeStatus, StudentFeeStatus, QDistinct>
      distinctByTransferredDebtAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transferredDebtAmount');
    });
  }
}

extension StudentFeeStatusQueryProperty
    on QueryBuilder<StudentFeeStatus, StudentFeeStatus, QQueryProperty> {
  QueryBuilder<StudentFeeStatus, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudentFeeStatus, String, QQueryOperations>
      academicYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYear');
    });
  }

  QueryBuilder<StudentFeeStatus, double, QQueryOperations> annualFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'annualFee');
    });
  }

  QueryBuilder<StudentFeeStatus, String, QQueryOperations> classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<StudentFeeStatus, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StudentFeeStatus, double, QQueryOperations>
      discountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountAmount');
    });
  }

  QueryBuilder<StudentFeeStatus, String?, QQueryOperations>
      discountDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountDetails');
    });
  }

  QueryBuilder<StudentFeeStatus, double?, QQueryOperations>
      dueAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueAmount');
    });
  }

  QueryBuilder<StudentFeeStatus, DateTime?, QQueryOperations>
      lastPaymentDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPaymentDate');
    });
  }

  QueryBuilder<StudentFeeStatus, DateTime?, QQueryOperations>
      nextDueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextDueDate');
    });
  }

  QueryBuilder<StudentFeeStatus, String?, QQueryOperations>
      originalDebtAcademicYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalDebtAcademicYear');
    });
  }

  QueryBuilder<StudentFeeStatus, String?, QQueryOperations>
      originalDebtClassNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalDebtClassName');
    });
  }

  QueryBuilder<StudentFeeStatus, double, QQueryOperations>
      paidAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAmount');
    });
  }

  QueryBuilder<StudentFeeStatus, String, QQueryOperations> studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<StudentFeeStatus, double, QQueryOperations>
      transferredDebtAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferredDebtAmount');
    });
  }
}
