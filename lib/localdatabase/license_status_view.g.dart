// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_status_view.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLicenseStatusViewCollection on Isar {
  IsarCollection<LicenseStatusView> get licenseStatusViews => this.collection();
}

const LicenseStatusViewSchema = CollectionSchema(
  name: r'LicenseStatusView',
  id: 6357148281080848623,
  properties: {
    r'activationDate': PropertySchema(
      id: 0,
      name: r'activationDate',
      type: IsarType.dateTime,
    ),
    r'expiryDate': PropertySchema(
      id: 1,
      name: r'expiryDate',
      type: IsarType.dateTime,
    ),
    r'isActivated': PropertySchema(
      id: 2,
      name: r'isActivated',
      type: IsarType.bool,
    ),
    r'isTrialActive': PropertySchema(
      id: 3,
      name: r'isTrialActive',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'licenseKey': PropertySchema(
      id: 5,
      name: r'licenseKey',
      type: IsarType.string,
    ),
    r'remainingDays': PropertySchema(
      id: 6,
      name: r'remainingDays',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _licenseStatusViewEstimateSize,
  serialize: _licenseStatusViewSerialize,
  deserialize: _licenseStatusViewDeserialize,
  deserializeProp: _licenseStatusViewDeserializeProp,
  idName: r'id',
  indexes: {
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _licenseStatusViewGetId,
  getLinks: _licenseStatusViewGetLinks,
  attach: _licenseStatusViewAttach,
  version: '3.1.0+1',
);

int _licenseStatusViewEstimateSize(
  LicenseStatusView object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.licenseKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _licenseStatusViewSerialize(
  LicenseStatusView object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.activationDate);
  writer.writeDateTime(offsets[1], object.expiryDate);
  writer.writeBool(offsets[2], object.isActivated);
  writer.writeBool(offsets[3], object.isTrialActive);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeString(offsets[5], object.licenseKey);
  writer.writeLong(offsets[6], object.remainingDays);
  writer.writeString(offsets[7], object.status);
}

LicenseStatusView _licenseStatusViewDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LicenseStatusView(
    activationDate: reader.readDateTimeOrNull(offsets[0]),
    expiryDate: reader.readDateTimeOrNull(offsets[1]),
    isActivated: reader.readBoolOrNull(offsets[2]),
    isTrialActive: reader.readBoolOrNull(offsets[3]),
    lastUpdated: reader.readDateTimeOrNull(offsets[4]),
    licenseKey: reader.readStringOrNull(offsets[5]),
    remainingDays: reader.readLongOrNull(offsets[6]),
    status: reader.readStringOrNull(offsets[7]),
  );
  object.id = id;
  return object;
}

P _licenseStatusViewDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _licenseStatusViewGetId(LicenseStatusView object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _licenseStatusViewGetLinks(
    LicenseStatusView object) {
  return [];
}

void _licenseStatusViewAttach(
    IsarCollection<dynamic> col, Id id, LicenseStatusView object) {
  object.id = id;
}

extension LicenseStatusViewQueryWhereSort
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QWhere> {
  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LicenseStatusViewQueryWhere
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QWhereClause> {
  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
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

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [null],
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      statusEqualTo(String? status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterWhereClause>
      statusNotEqualTo(String? status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LicenseStatusViewQueryFilter
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QFilterCondition> {
  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      activationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activationDate',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      activationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activationDate',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      activationDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      activationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      activationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      activationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      expiryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expiryDate',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      expiryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expiryDate',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      expiryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      expiryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      expiryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      expiryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
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

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
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

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
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

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      isActivatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isActivated',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      isActivatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isActivated',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      isActivatedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActivated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      isTrialActiveIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isTrialActive',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      isTrialActiveIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isTrialActive',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      isTrialActiveEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTrialActive',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'licenseKey',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'licenseKey',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'licenseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'licenseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'licenseKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'licenseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'licenseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'licenseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'licenseKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      licenseKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'licenseKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      remainingDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remainingDays',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      remainingDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remainingDays',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      remainingDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remainingDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      remainingDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remainingDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      remainingDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remainingDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      remainingDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remainingDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension LicenseStatusViewQueryObject
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QFilterCondition> {}

extension LicenseStatusViewQueryLinks
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QFilterCondition> {}

extension LicenseStatusViewQuerySortBy
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QSortBy> {
  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByActivationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDate', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByActivationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDate', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByIsActivated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByIsActivatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByIsTrialActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialActive', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByIsTrialActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialActive', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByLicenseKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKey', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByLicenseKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKey', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByRemainingDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingDays', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByRemainingDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingDays', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LicenseStatusViewQuerySortThenBy
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QSortThenBy> {
  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByActivationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDate', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByActivationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDate', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByIsActivated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByIsActivatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActivated', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByIsTrialActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialActive', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByIsTrialActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialActive', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByLicenseKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKey', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByLicenseKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseKey', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByRemainingDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingDays', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByRemainingDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingDays', Sort.desc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LicenseStatusViewQueryWhereDistinct
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct> {
  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByActivationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activationDate');
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiryDate');
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByIsActivated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActivated');
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByIsTrialActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTrialActive');
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByLicenseKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licenseKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByRemainingDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remainingDays');
    });
  }

  QueryBuilder<LicenseStatusView, LicenseStatusView, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension LicenseStatusViewQueryProperty
    on QueryBuilder<LicenseStatusView, LicenseStatusView, QQueryProperty> {
  QueryBuilder<LicenseStatusView, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LicenseStatusView, DateTime?, QQueryOperations>
      activationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activationDate');
    });
  }

  QueryBuilder<LicenseStatusView, DateTime?, QQueryOperations>
      expiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiryDate');
    });
  }

  QueryBuilder<LicenseStatusView, bool?, QQueryOperations>
      isActivatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActivated');
    });
  }

  QueryBuilder<LicenseStatusView, bool?, QQueryOperations>
      isTrialActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTrialActive');
    });
  }

  QueryBuilder<LicenseStatusView, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<LicenseStatusView, String?, QQueryOperations>
      licenseKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licenseKey');
    });
  }

  QueryBuilder<LicenseStatusView, int?, QQueryOperations>
      remainingDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remainingDays');
    });
  }

  QueryBuilder<LicenseStatusView, String?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
