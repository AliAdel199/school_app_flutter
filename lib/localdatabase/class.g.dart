// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSchoolClassCollection on Isar {
  IsarCollection<SchoolClass> get schoolClass => this.collection();
}

const SchoolClassSchema = CollectionSchema(
  name: r'SchoolClass',
  id: -7752351258327029191,
  properties: {
    r'annualFee': PropertySchema(
      id: 0,
      name: r'annualFee',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _schoolClassEstimateSize,
  serialize: _schoolClassSerialize,
  deserialize: _schoolClassDeserialize,
  deserializeProp: _schoolClassDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'grade': LinkSchema(
      id: -573250481711267911,
      name: r'grade',
      target: r'Grade',
      single: true,
    ),
    r'subjects': LinkSchema(
      id: 2562817919184489520,
      name: r'subjects',
      target: r'Subject',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _schoolClassGetId,
  getLinks: _schoolClassGetLinks,
  attach: _schoolClassAttach,
  version: '3.1.0+1',
);

int _schoolClassEstimateSize(
  SchoolClass object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _schoolClassSerialize(
  SchoolClass object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.annualFee);
  writer.writeString(offsets[1], object.name);
}

SchoolClass _schoolClassDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SchoolClass();
  object.annualFee = reader.readDoubleOrNull(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  return object;
}

P _schoolClassDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _schoolClassGetId(SchoolClass object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _schoolClassGetLinks(SchoolClass object) {
  return [object.grade, object.subjects];
}

void _schoolClassAttach(
    IsarCollection<dynamic> col, Id id, SchoolClass object) {
  object.id = id;
  object.grade.attach(col, col.isar.collection<Grade>(), r'grade', id);
  object.subjects.attach(col, col.isar.collection<Subject>(), r'subjects', id);
}

extension SchoolClassQueryWhereSort
    on QueryBuilder<SchoolClass, SchoolClass, QWhere> {
  QueryBuilder<SchoolClass, SchoolClass, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SchoolClassQueryWhere
    on QueryBuilder<SchoolClass, SchoolClass, QWhereClause> {
  QueryBuilder<SchoolClass, SchoolClass, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterWhereClause> idBetween(
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

extension SchoolClassQueryFilter
    on QueryBuilder<SchoolClass, SchoolClass, QFilterCondition> {
  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      annualFeeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'annualFee',
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      annualFeeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'annualFee',
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      annualFeeEqualTo(
    double? value, {
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      annualFeeGreaterThan(
    double? value, {
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      annualFeeLessThan(
    double? value, {
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      annualFeeBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension SchoolClassQueryObject
    on QueryBuilder<SchoolClass, SchoolClass, QFilterCondition> {}

extension SchoolClassQueryLinks
    on QueryBuilder<SchoolClass, SchoolClass, QFilterCondition> {
  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> grade(
      FilterQuery<Grade> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'grade');
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> gradeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'grade', 0, true, 0, true);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition> subjects(
      FilterQuery<Subject> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'subjects');
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      subjectsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subjects', length, true, length, true);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      subjectsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subjects', 0, true, 0, true);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      subjectsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subjects', 0, false, 999999, true);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      subjectsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subjects', 0, true, length, include);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      subjectsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subjects', length, include, 999999, true);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterFilterCondition>
      subjectsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'subjects', lower, includeLower, upper, includeUpper);
    });
  }
}

extension SchoolClassQuerySortBy
    on QueryBuilder<SchoolClass, SchoolClass, QSortBy> {
  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> sortByAnnualFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.asc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> sortByAnnualFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.desc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension SchoolClassQuerySortThenBy
    on QueryBuilder<SchoolClass, SchoolClass, QSortThenBy> {
  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> thenByAnnualFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.asc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> thenByAnnualFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'annualFee', Sort.desc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension SchoolClassQueryWhereDistinct
    on QueryBuilder<SchoolClass, SchoolClass, QDistinct> {
  QueryBuilder<SchoolClass, SchoolClass, QDistinct> distinctByAnnualFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'annualFee');
    });
  }

  QueryBuilder<SchoolClass, SchoolClass, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension SchoolClassQueryProperty
    on QueryBuilder<SchoolClass, SchoolClass, QQueryProperty> {
  QueryBuilder<SchoolClass, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SchoolClass, double?, QQueryOperations> annualFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'annualFee');
    });
  }

  QueryBuilder<SchoolClass, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
