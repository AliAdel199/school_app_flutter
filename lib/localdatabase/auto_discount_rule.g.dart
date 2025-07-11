// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_discount_rule.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAutoDiscountRuleCollection on Isar {
  IsarCollection<AutoDiscountRule> get autoDiscountRules => this.collection();
}

const AutoDiscountRuleSchema = CollectionSchema(
  name: r'AutoDiscountRule',
  id: 4187902066578033962,
  properties: {
    r'applicableClasses': PropertySchema(
      id: 0,
      name: r'applicableClasses',
      type: IsarType.stringList,
    ),
    r'applicableGrades': PropertySchema(
      id: 1,
      name: r'applicableGrades',
      type: IsarType.stringList,
    ),
    r'applyToExistingStudents': PropertySchema(
      id: 2,
      name: r'applyToExistingStudents',
      type: IsarType.bool,
    ),
    r'conditions': PropertySchema(
      id: 3,
      name: r'conditions',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 5,
      name: r'description',
      type: IsarType.string,
    ),
    r'fixedAmount': PropertySchema(
      id: 6,
      name: r'fixedAmount',
      type: IsarType.double,
    ),
    r'isActive': PropertySchema(
      id: 7,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'maxDiscountAmount': PropertySchema(
      id: 8,
      name: r'maxDiscountAmount',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'percentage': PropertySchema(
      id: 10,
      name: r'percentage',
      type: IsarType.double,
    ),
    r'priority': PropertySchema(
      id: 11,
      name: r'priority',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 12,
      name: r'type',
      type: IsarType.byte,
      enumMap: _AutoDiscountRuletypeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'validFrom': PropertySchema(
      id: 14,
      name: r'validFrom',
      type: IsarType.dateTime,
    ),
    r'validTo': PropertySchema(
      id: 15,
      name: r'validTo',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _autoDiscountRuleEstimateSize,
  serialize: _autoDiscountRuleSerialize,
  deserialize: _autoDiscountRuleDeserialize,
  deserializeProp: _autoDiscountRuleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _autoDiscountRuleGetId,
  getLinks: _autoDiscountRuleGetLinks,
  attach: _autoDiscountRuleAttach,
  version: '3.1.0+1',
);

int _autoDiscountRuleEstimateSize(
  AutoDiscountRule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.applicableClasses.length * 3;
  {
    for (var i = 0; i < object.applicableClasses.length; i++) {
      final value = object.applicableClasses[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.applicableGrades.length * 3;
  {
    for (var i = 0; i < object.applicableGrades.length; i++) {
      final value = object.applicableGrades[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.conditions.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _autoDiscountRuleSerialize(
  AutoDiscountRule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.applicableClasses);
  writer.writeStringList(offsets[1], object.applicableGrades);
  writer.writeBool(offsets[2], object.applyToExistingStudents);
  writer.writeString(offsets[3], object.conditions);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.description);
  writer.writeDouble(offsets[6], object.fixedAmount);
  writer.writeBool(offsets[7], object.isActive);
  writer.writeDouble(offsets[8], object.maxDiscountAmount);
  writer.writeString(offsets[9], object.name);
  writer.writeDouble(offsets[10], object.percentage);
  writer.writeLong(offsets[11], object.priority);
  writer.writeByte(offsets[12], object.type.index);
  writer.writeDateTime(offsets[13], object.updatedAt);
  writer.writeDateTime(offsets[14], object.validFrom);
  writer.writeDateTime(offsets[15], object.validTo);
}

AutoDiscountRule _autoDiscountRuleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AutoDiscountRule();
  object.applicableClasses = reader.readStringList(offsets[0]) ?? [];
  object.applicableGrades = reader.readStringList(offsets[1]) ?? [];
  object.applyToExistingStudents = reader.readBool(offsets[2]);
  object.conditions = reader.readString(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.description = reader.readStringOrNull(offsets[5]);
  object.fixedAmount = reader.readDouble(offsets[6]);
  object.id = id;
  object.isActive = reader.readBool(offsets[7]);
  object.maxDiscountAmount = reader.readDoubleOrNull(offsets[8]);
  object.name = reader.readString(offsets[9]);
  object.percentage = reader.readDouble(offsets[10]);
  object.priority = reader.readLong(offsets[11]);
  object.type =
      _AutoDiscountRuletypeValueEnumMap[reader.readByteOrNull(offsets[12])] ??
          AutoDiscountType.sibling;
  object.updatedAt = reader.readDateTime(offsets[13]);
  object.validFrom = reader.readDateTime(offsets[14]);
  object.validTo = reader.readDateTime(offsets[15]);
  return object;
}

P _autoDiscountRuleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (_AutoDiscountRuletypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AutoDiscountType.sibling) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AutoDiscountRuletypeEnumValueMap = {
  'sibling': 0,
  'earlyPayment': 1,
  'fullPayment': 2,
  'academicPerformance': 3,
  'financialNeed': 4,
  'loyalty': 5,
  'bulkPayment': 6,
  'custom': 7,
};
const _AutoDiscountRuletypeValueEnumMap = {
  0: AutoDiscountType.sibling,
  1: AutoDiscountType.earlyPayment,
  2: AutoDiscountType.fullPayment,
  3: AutoDiscountType.academicPerformance,
  4: AutoDiscountType.financialNeed,
  5: AutoDiscountType.loyalty,
  6: AutoDiscountType.bulkPayment,
  7: AutoDiscountType.custom,
};

Id _autoDiscountRuleGetId(AutoDiscountRule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _autoDiscountRuleGetLinks(AutoDiscountRule object) {
  return [];
}

void _autoDiscountRuleAttach(
    IsarCollection<dynamic> col, Id id, AutoDiscountRule object) {
  object.id = id;
}

extension AutoDiscountRuleQueryWhereSort
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QWhere> {
  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AutoDiscountRuleQueryWhere
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QWhereClause> {
  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterWhereClause>
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterWhereClause> idBetween(
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

extension AutoDiscountRuleQueryFilter
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QFilterCondition> {
  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applicableClasses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'applicableClasses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'applicableClasses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'applicableClasses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'applicableClasses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'applicableClasses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'applicableClasses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'applicableClasses',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applicableClasses',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'applicableClasses',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableClasses',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableClasses',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableClasses',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableClasses',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableClasses',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableClassesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableClasses',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applicableGrades',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'applicableGrades',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'applicableGrades',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'applicableGrades',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'applicableGrades',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'applicableGrades',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'applicableGrades',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'applicableGrades',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applicableGrades',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'applicableGrades',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableGrades',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableGrades',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableGrades',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableGrades',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableGrades',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applicableGradesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'applicableGrades',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      applyToExistingStudentsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applyToExistingStudents',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conditions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conditions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conditions',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      conditionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conditions',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      fixedAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fixedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      fixedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fixedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      fixedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fixedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      fixedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fixedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      maxDiscountAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxDiscountAmount',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      maxDiscountAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxDiscountAmount',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      maxDiscountAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      maxDiscountAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      maxDiscountAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      maxDiscountAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxDiscountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      percentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'percentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      percentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'percentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      percentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'percentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      percentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'percentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      typeEqualTo(AutoDiscountType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      typeGreaterThan(
    AutoDiscountType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      typeLessThan(
    AutoDiscountType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      typeBetween(
    AutoDiscountType lower,
    AutoDiscountType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validFromEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'validFrom',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validFromGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'validFrom',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validFromLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'validFrom',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validFromBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'validFrom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validToEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'validTo',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validToGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'validTo',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validToLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'validTo',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterFilterCondition>
      validToBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'validTo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AutoDiscountRuleQueryObject
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QFilterCondition> {}

extension AutoDiscountRuleQueryLinks
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QFilterCondition> {}

extension AutoDiscountRuleQuerySortBy
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QSortBy> {
  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByApplyToExistingStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyToExistingStudents', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByApplyToExistingStudentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyToExistingStudents', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByConditions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditions', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByConditionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditions', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByFixedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByFixedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByMaxDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByMaxDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByValidFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByValidFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByValidTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validTo', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      sortByValidToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validTo', Sort.desc);
    });
  }
}

extension AutoDiscountRuleQuerySortThenBy
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QSortThenBy> {
  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByApplyToExistingStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyToExistingStudents', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByApplyToExistingStudentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyToExistingStudents', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByConditions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditions', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByConditionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditions', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByFixedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByFixedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByMaxDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByMaxDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByValidFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByValidFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByValidTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validTo', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QAfterSortBy>
      thenByValidToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validTo', Sort.desc);
    });
  }
}

extension AutoDiscountRuleQueryWhereDistinct
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct> {
  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByApplicableClasses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'applicableClasses');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByApplicableGrades() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'applicableGrades');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByApplyToExistingStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'applyToExistingStudents');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByConditions({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conditions', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByFixedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedAmount');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByMaxDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxDiscountAmount');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'percentage');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByValidFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validFrom');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountRule, QDistinct>
      distinctByValidTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validTo');
    });
  }
}

extension AutoDiscountRuleQueryProperty
    on QueryBuilder<AutoDiscountRule, AutoDiscountRule, QQueryProperty> {
  QueryBuilder<AutoDiscountRule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AutoDiscountRule, List<String>, QQueryOperations>
      applicableClassesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applicableClasses');
    });
  }

  QueryBuilder<AutoDiscountRule, List<String>, QQueryOperations>
      applicableGradesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applicableGrades');
    });
  }

  QueryBuilder<AutoDiscountRule, bool, QQueryOperations>
      applyToExistingStudentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applyToExistingStudents');
    });
  }

  QueryBuilder<AutoDiscountRule, String, QQueryOperations>
      conditionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conditions');
    });
  }

  QueryBuilder<AutoDiscountRule, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AutoDiscountRule, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<AutoDiscountRule, double, QQueryOperations>
      fixedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedAmount');
    });
  }

  QueryBuilder<AutoDiscountRule, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<AutoDiscountRule, double?, QQueryOperations>
      maxDiscountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxDiscountAmount');
    });
  }

  QueryBuilder<AutoDiscountRule, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AutoDiscountRule, double, QQueryOperations>
      percentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'percentage');
    });
  }

  QueryBuilder<AutoDiscountRule, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<AutoDiscountRule, AutoDiscountType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<AutoDiscountRule, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<AutoDiscountRule, DateTime, QQueryOperations>
      validFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validFrom');
    });
  }

  QueryBuilder<AutoDiscountRule, DateTime, QQueryOperations> validToProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validTo');
    });
  }
}
