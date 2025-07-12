// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_mark.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubjectMarkCollection on Isar {
  IsarCollection<SubjectMark> get subjectMarks => this.collection();
}

const SubjectMarkSchema = CollectionSchema(
  name: r'SubjectMark',
  id: 3119388900495334364,
  properties: {
    r'academicYear': PropertySchema(
      id: 0,
      name: r'academicYear',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'evaluationType': PropertySchema(
      id: 2,
      name: r'evaluationType',
      type: IsarType.string,
    ),
    r'mark': PropertySchema(
      id: 3,
      name: r'mark',
      type: IsarType.double,
    )
  },
  estimateSize: _subjectMarkEstimateSize,
  serialize: _subjectMarkSerialize,
  deserialize: _subjectMarkDeserialize,
  deserializeProp: _subjectMarkDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'student': LinkSchema(
      id: -5602698803099075235,
      name: r'student',
      target: r'Student',
      single: true,
    ),
    r'subject': LinkSchema(
      id: -9124578481868071053,
      name: r'subject',
      target: r'Subject',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _subjectMarkGetId,
  getLinks: _subjectMarkGetLinks,
  attach: _subjectMarkAttach,
  version: '3.1.0+1',
);

int _subjectMarkEstimateSize(
  SubjectMark object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.academicYear;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.evaluationType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _subjectMarkSerialize(
  SubjectMark object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYear);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.evaluationType);
  writer.writeDouble(offsets[3], object.mark);
}

SubjectMark _subjectMarkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubjectMark();
  object.academicYear = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.evaluationType = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.mark = reader.readDoubleOrNull(offsets[3]);
  return object;
}

P _subjectMarkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subjectMarkGetId(SubjectMark object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subjectMarkGetLinks(SubjectMark object) {
  return [object.student, object.subject];
}

void _subjectMarkAttach(
    IsarCollection<dynamic> col, Id id, SubjectMark object) {
  object.id = id;
  object.student.attach(col, col.isar.collection<Student>(), r'student', id);
  object.subject.attach(col, col.isar.collection<Subject>(), r'subject', id);
}

extension SubjectMarkQueryWhereSort
    on QueryBuilder<SubjectMark, SubjectMark, QWhere> {
  QueryBuilder<SubjectMark, SubjectMark, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubjectMarkQueryWhere
    on QueryBuilder<SubjectMark, SubjectMark, QWhereClause> {
  QueryBuilder<SubjectMark, SubjectMark, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterWhereClause> idBetween(
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

extension SubjectMarkQueryFilter
    on QueryBuilder<SubjectMark, SubjectMark, QFilterCondition> {
  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'academicYear',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'academicYear',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearEqualTo(
    String? value, {
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearGreaterThan(
    String? value, {
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearLessThan(
    String? value, {
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYear',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      academicYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'evaluationType',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'evaluationType',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evaluationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'evaluationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'evaluationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'evaluationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'evaluationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'evaluationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'evaluationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'evaluationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evaluationType',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      evaluationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'evaluationType',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> markIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      markIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> markEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mark',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> markGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mark',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> markLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mark',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> markBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mark',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension SubjectMarkQueryObject
    on QueryBuilder<SubjectMark, SubjectMark, QFilterCondition> {}

extension SubjectMarkQueryLinks
    on QueryBuilder<SubjectMark, SubjectMark, QFilterCondition> {
  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> student(
      FilterQuery<Student> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'student');
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      studentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'student', 0, true, 0, true);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition> subject(
      FilterQuery<Subject> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'subject');
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterFilterCondition>
      subjectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subject', 0, true, 0, true);
    });
  }
}

extension SubjectMarkQuerySortBy
    on QueryBuilder<SubjectMark, SubjectMark, QSortBy> {
  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> sortByAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy>
      sortByAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.desc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> sortByEvaluationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evaluationType', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy>
      sortByEvaluationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evaluationType', Sort.desc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> sortByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> sortByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }
}

extension SubjectMarkQuerySortThenBy
    on QueryBuilder<SubjectMark, SubjectMark, QSortThenBy> {
  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenByAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy>
      thenByAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.desc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenByEvaluationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evaluationType', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy>
      thenByEvaluationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evaluationType', Sort.desc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QAfterSortBy> thenByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }
}

extension SubjectMarkQueryWhereDistinct
    on QueryBuilder<SubjectMark, SubjectMark, QDistinct> {
  QueryBuilder<SubjectMark, SubjectMark, QDistinct> distinctByAcademicYear(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYear', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QDistinct> distinctByEvaluationType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'evaluationType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectMark, SubjectMark, QDistinct> distinctByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mark');
    });
  }
}

extension SubjectMarkQueryProperty
    on QueryBuilder<SubjectMark, SubjectMark, QQueryProperty> {
  QueryBuilder<SubjectMark, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubjectMark, String?, QQueryOperations> academicYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYear');
    });
  }

  QueryBuilder<SubjectMark, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SubjectMark, String?, QQueryOperations>
      evaluationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'evaluationType');
    });
  }

  QueryBuilder<SubjectMark, double?, QQueryOperations> markProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mark');
    });
  }
}
