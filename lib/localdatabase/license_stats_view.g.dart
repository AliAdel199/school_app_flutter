// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_stats_view.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLicenseStatsViewCollection on Isar {
  IsarCollection<LicenseStatsView> get licenseStatsViews => this.collection();
}

const LicenseStatsViewSchema = CollectionSchema(
  name: r'LicenseStatsView',
  id: -4500810122090594888,
  properties: {
    r'lastCalculated': PropertySchema(
      id: 0,
      name: r'lastCalculated',
      type: IsarType.dateTime,
    ),
    r'licenseType': PropertySchema(
      id: 1,
      name: r'licenseType',
      type: IsarType.string,
    ),
    r'totalClasses': PropertySchema(
      id: 2,
      name: r'totalClasses',
      type: IsarType.long,
    ),
    r'totalPayments': PropertySchema(
      id: 3,
      name: r'totalPayments',
      type: IsarType.long,
    ),
    r'totalStudents': PropertySchema(
      id: 4,
      name: r'totalStudents',
      type: IsarType.long,
    ),
    r'totalUsers': PropertySchema(
      id: 5,
      name: r'totalUsers',
      type: IsarType.long,
    )
  },
  estimateSize: _licenseStatsViewEstimateSize,
  serialize: _licenseStatsViewSerialize,
  deserialize: _licenseStatsViewDeserialize,
  deserializeProp: _licenseStatsViewDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _licenseStatsViewGetId,
  getLinks: _licenseStatsViewGetLinks,
  attach: _licenseStatsViewAttach,
  version: '3.1.0+1',
);

int _licenseStatsViewEstimateSize(
  LicenseStatsView object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.licenseType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _licenseStatsViewSerialize(
  LicenseStatsView object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastCalculated);
  writer.writeString(offsets[1], object.licenseType);
  writer.writeLong(offsets[2], object.totalClasses);
  writer.writeLong(offsets[3], object.totalPayments);
  writer.writeLong(offsets[4], object.totalStudents);
  writer.writeLong(offsets[5], object.totalUsers);
}

LicenseStatsView _licenseStatsViewDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LicenseStatsView(
    lastCalculated: reader.readDateTimeOrNull(offsets[0]),
    licenseType: reader.readStringOrNull(offsets[1]),
    totalClasses: reader.readLongOrNull(offsets[2]),
    totalPayments: reader.readLongOrNull(offsets[3]),
    totalStudents: reader.readLongOrNull(offsets[4]),
    totalUsers: reader.readLongOrNull(offsets[5]),
  );
  object.id = id;
  return object;
}

P _licenseStatsViewDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _licenseStatsViewGetId(LicenseStatsView object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _licenseStatsViewGetLinks(LicenseStatsView object) {
  return [];
}

void _licenseStatsViewAttach(
    IsarCollection<dynamic> col, Id id, LicenseStatsView object) {
  object.id = id;
}

extension LicenseStatsViewQueryWhereSort
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QWhere> {
  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LicenseStatsViewQueryWhere
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QWhereClause> {
  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterWhereClause>
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

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterWhereClause> idBetween(
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

extension LicenseStatsViewQueryFilter
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QFilterCondition> {
  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
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

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
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

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
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

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      lastCalculatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCalculated',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      lastCalculatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCalculated',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      lastCalculatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCalculated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      lastCalculatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCalculated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      lastCalculatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCalculated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      lastCalculatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCalculated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'licenseType',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'licenseType',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'licenseType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'licenseType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'licenseType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'licenseType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'licenseType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'licenseType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'licenseType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseType',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      licenseTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'licenseType',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalClassesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalClasses',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalClassesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalClasses',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalClassesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalClasses',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalClassesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalClasses',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalClassesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalClasses',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalClassesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalClasses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalPaymentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalPayments',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalPaymentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalPayments',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalPaymentsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPayments',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalPaymentsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPayments',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalPaymentsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPayments',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalPaymentsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPayments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalStudentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalStudents',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalStudentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalStudents',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalStudentsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalStudents',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalStudentsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalStudents',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalStudentsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalStudents',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalStudentsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalStudents',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalUsersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalUsers',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalUsersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalUsers',
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalUsersEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalUsers',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalUsersGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalUsers',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalUsersLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalUsers',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterFilterCondition>
      totalUsersBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalUsers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LicenseStatsViewQueryObject
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QFilterCondition> {}

extension LicenseStatsViewQueryLinks
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QFilterCondition> {}

extension LicenseStatsViewQuerySortBy
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QSortBy> {
  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByLastCalculated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalculated', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByLastCalculatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalculated', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByLicenseType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseType', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByLicenseTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseType', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalClasses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClasses', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalClassesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClasses', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalPayments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPayments', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalPaymentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPayments', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalStudentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalUsers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsers', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      sortByTotalUsersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsers', Sort.desc);
    });
  }
}

extension LicenseStatsViewQuerySortThenBy
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QSortThenBy> {
  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByLastCalculated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalculated', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByLastCalculatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalculated', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByLicenseType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseType', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByLicenseTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseType', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalClasses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClasses', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalClassesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalClasses', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalPayments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPayments', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalPaymentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPayments', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalStudentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalUsers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsers', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QAfterSortBy>
      thenByTotalUsersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalUsers', Sort.desc);
    });
  }
}

extension LicenseStatsViewQueryWhereDistinct
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QDistinct> {
  QueryBuilder<LicenseStatsView, LicenseStatsView, QDistinct>
      distinctByLastCalculated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCalculated');
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QDistinct>
      distinctByLicenseType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licenseType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QDistinct>
      distinctByTotalClasses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalClasses');
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QDistinct>
      distinctByTotalPayments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPayments');
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QDistinct>
      distinctByTotalStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStudents');
    });
  }

  QueryBuilder<LicenseStatsView, LicenseStatsView, QDistinct>
      distinctByTotalUsers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalUsers');
    });
  }
}

extension LicenseStatsViewQueryProperty
    on QueryBuilder<LicenseStatsView, LicenseStatsView, QQueryProperty> {
  QueryBuilder<LicenseStatsView, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LicenseStatsView, DateTime?, QQueryOperations>
      lastCalculatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCalculated');
    });
  }

  QueryBuilder<LicenseStatsView, String?, QQueryOperations>
      licenseTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licenseType');
    });
  }

  QueryBuilder<LicenseStatsView, int?, QQueryOperations>
      totalClassesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalClasses');
    });
  }

  QueryBuilder<LicenseStatsView, int?, QQueryOperations>
      totalPaymentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPayments');
    });
  }

  QueryBuilder<LicenseStatsView, int?, QQueryOperations>
      totalStudentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStudents');
    });
  }

  QueryBuilder<LicenseStatsView, int?, QQueryOperations> totalUsersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalUsers');
    });
  }
}
