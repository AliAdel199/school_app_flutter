// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_discount_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAutoDiscountSettingsCollection on Isar {
  IsarCollection<AutoDiscountSettings> get autoDiscountSettings =>
      this.collection();
}

const AutoDiscountSettingsSchema = CollectionSchema(
  name: r'AutoDiscountSettings',
  id: 7782503946224524211,
  properties: {
    r'allowDuplicateDiscounts': PropertySchema(
      id: 0,
      name: r'allowDuplicateDiscounts',
      type: IsarType.bool,
    ),
    r'autoApplyOnPayment': PropertySchema(
      id: 1,
      name: r'autoApplyOnPayment',
      type: IsarType.bool,
    ),
    r'earlyPaymentDays': PropertySchema(
      id: 2,
      name: r'earlyPaymentDays',
      type: IsarType.long,
    ),
    r'earlyPaymentDiscountEnabled': PropertySchema(
      id: 3,
      name: r'earlyPaymentDiscountEnabled',
      type: IsarType.bool,
    ),
    r'earlyPaymentDiscountRate': PropertySchema(
      id: 4,
      name: r'earlyPaymentDiscountRate',
      type: IsarType.double,
    ),
    r'fullPaymentDiscountEnabled': PropertySchema(
      id: 5,
      name: r'fullPaymentDiscountEnabled',
      type: IsarType.bool,
    ),
    r'fullPaymentDiscountRate': PropertySchema(
      id: 6,
      name: r'fullPaymentDiscountRate',
      type: IsarType.double,
    ),
    r'globalEnabled': PropertySchema(
      id: 7,
      name: r'globalEnabled',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 8,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'maxDiscountAmount': PropertySchema(
      id: 9,
      name: r'maxDiscountAmount',
      type: IsarType.double,
    ),
    r'maxDiscountPercentage': PropertySchema(
      id: 10,
      name: r'maxDiscountPercentage',
      type: IsarType.double,
    ),
    r'minDiscountAmount': PropertySchema(
      id: 11,
      name: r'minDiscountAmount',
      type: IsarType.double,
    ),
    r'minDiscountPercentage': PropertySchema(
      id: 12,
      name: r'minDiscountPercentage',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 13,
      name: r'notes',
      type: IsarType.string,
    ),
    r'showNotifications': PropertySchema(
      id: 14,
      name: r'showNotifications',
      type: IsarType.bool,
    ),
    r'siblingDiscountEnabled': PropertySchema(
      id: 15,
      name: r'siblingDiscountEnabled',
      type: IsarType.bool,
    ),
    r'siblingDiscountRate2nd': PropertySchema(
      id: 16,
      name: r'siblingDiscountRate2nd',
      type: IsarType.double,
    ),
    r'siblingDiscountRate3rd': PropertySchema(
      id: 17,
      name: r'siblingDiscountRate3rd',
      type: IsarType.double,
    ),
    r'siblingDiscountRate4th': PropertySchema(
      id: 18,
      name: r'siblingDiscountRate4th',
      type: IsarType.double,
    )
  },
  estimateSize: _autoDiscountSettingsEstimateSize,
  serialize: _autoDiscountSettingsSerialize,
  deserialize: _autoDiscountSettingsDeserialize,
  deserializeProp: _autoDiscountSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _autoDiscountSettingsGetId,
  getLinks: _autoDiscountSettingsGetLinks,
  attach: _autoDiscountSettingsAttach,
  version: '3.1.0+1',
);

int _autoDiscountSettingsEstimateSize(
  AutoDiscountSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _autoDiscountSettingsSerialize(
  AutoDiscountSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicateDiscounts);
  writer.writeBool(offsets[1], object.autoApplyOnPayment);
  writer.writeLong(offsets[2], object.earlyPaymentDays);
  writer.writeBool(offsets[3], object.earlyPaymentDiscountEnabled);
  writer.writeDouble(offsets[4], object.earlyPaymentDiscountRate);
  writer.writeBool(offsets[5], object.fullPaymentDiscountEnabled);
  writer.writeDouble(offsets[6], object.fullPaymentDiscountRate);
  writer.writeBool(offsets[7], object.globalEnabled);
  writer.writeDateTime(offsets[8], object.lastUpdated);
  writer.writeDouble(offsets[9], object.maxDiscountAmount);
  writer.writeDouble(offsets[10], object.maxDiscountPercentage);
  writer.writeDouble(offsets[11], object.minDiscountAmount);
  writer.writeDouble(offsets[12], object.minDiscountPercentage);
  writer.writeString(offsets[13], object.notes);
  writer.writeBool(offsets[14], object.showNotifications);
  writer.writeBool(offsets[15], object.siblingDiscountEnabled);
  writer.writeDouble(offsets[16], object.siblingDiscountRate2nd);
  writer.writeDouble(offsets[17], object.siblingDiscountRate3rd);
  writer.writeDouble(offsets[18], object.siblingDiscountRate4th);
}

AutoDiscountSettings _autoDiscountSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AutoDiscountSettings();
  object.allowDuplicateDiscounts = reader.readBool(offsets[0]);
  object.autoApplyOnPayment = reader.readBool(offsets[1]);
  object.earlyPaymentDays = reader.readLong(offsets[2]);
  object.earlyPaymentDiscountEnabled = reader.readBool(offsets[3]);
  object.earlyPaymentDiscountRate = reader.readDouble(offsets[4]);
  object.fullPaymentDiscountEnabled = reader.readBool(offsets[5]);
  object.fullPaymentDiscountRate = reader.readDouble(offsets[6]);
  object.globalEnabled = reader.readBool(offsets[7]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[8]);
  object.maxDiscountAmount = reader.readDouble(offsets[9]);
  object.maxDiscountPercentage = reader.readDouble(offsets[10]);
  object.minDiscountAmount = reader.readDouble(offsets[11]);
  object.minDiscountPercentage = reader.readDouble(offsets[12]);
  object.notes = reader.readStringOrNull(offsets[13]);
  object.showNotifications = reader.readBool(offsets[14]);
  object.siblingDiscountEnabled = reader.readBool(offsets[15]);
  object.siblingDiscountRate2nd = reader.readDouble(offsets[16]);
  object.siblingDiscountRate3rd = reader.readDouble(offsets[17]);
  object.siblingDiscountRate4th = reader.readDouble(offsets[18]);
  return object;
}

P _autoDiscountSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _autoDiscountSettingsGetId(AutoDiscountSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _autoDiscountSettingsGetLinks(
    AutoDiscountSettings object) {
  return [];
}

void _autoDiscountSettingsAttach(
    IsarCollection<dynamic> col, Id id, AutoDiscountSettings object) {
  object.id = id;
}

extension AutoDiscountSettingsQueryWhereSort
    on QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QWhere> {
  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AutoDiscountSettingsQueryWhere
    on QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QWhereClause> {
  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterWhereClause>
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterWhereClause>
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
}

extension AutoDiscountSettingsQueryFilter on QueryBuilder<AutoDiscountSettings,
    AutoDiscountSettings, QFilterCondition> {
  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> allowDuplicateDiscountsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicateDiscounts',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> autoApplyOnPaymentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoApplyOnPayment',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earlyPaymentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earlyPaymentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earlyPaymentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earlyPaymentDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDiscountEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earlyPaymentDiscountEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDiscountRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earlyPaymentDiscountRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDiscountRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earlyPaymentDiscountRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDiscountRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earlyPaymentDiscountRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> earlyPaymentDiscountRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earlyPaymentDiscountRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> fullPaymentDiscountEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullPaymentDiscountEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> fullPaymentDiscountRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullPaymentDiscountRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> fullPaymentDiscountRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullPaymentDiscountRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> fullPaymentDiscountRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullPaymentDiscountRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> fullPaymentDiscountRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullPaymentDiscountRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> globalEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'globalEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime value, {
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountAmountEqualTo(
    double value, {
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountAmountGreaterThan(
    double value, {
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountAmountLessThan(
    double value, {
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountAmountBetween(
    double lower,
    double upper, {
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

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> maxDiscountPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxDiscountPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minDiscountAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minDiscountAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minDiscountPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> minDiscountPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minDiscountPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> showNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siblingDiscountEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate2ndEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siblingDiscountRate2nd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate2ndGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'siblingDiscountRate2nd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate2ndLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'siblingDiscountRate2nd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate2ndBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'siblingDiscountRate2nd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate3rdEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siblingDiscountRate3rd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate3rdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'siblingDiscountRate3rd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate3rdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'siblingDiscountRate3rd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate3rdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'siblingDiscountRate3rd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate4thEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'siblingDiscountRate4th',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate4thGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'siblingDiscountRate4th',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate4thLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'siblingDiscountRate4th',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings,
      QAfterFilterCondition> siblingDiscountRate4thBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'siblingDiscountRate4th',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension AutoDiscountSettingsQueryObject on QueryBuilder<AutoDiscountSettings,
    AutoDiscountSettings, QFilterCondition> {}

extension AutoDiscountSettingsQueryLinks on QueryBuilder<AutoDiscountSettings,
    AutoDiscountSettings, QFilterCondition> {}

extension AutoDiscountSettingsQuerySortBy
    on QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QSortBy> {
  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByAllowDuplicateDiscounts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicateDiscounts', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByAllowDuplicateDiscountsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicateDiscounts', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByAutoApplyOnPayment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoApplyOnPayment', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByAutoApplyOnPaymentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoApplyOnPayment', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByEarlyPaymentDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDays', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByEarlyPaymentDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDays', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByEarlyPaymentDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByEarlyPaymentDiscountEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByEarlyPaymentDiscountRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountRate', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByEarlyPaymentDiscountRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountRate', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByFullPaymentDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByFullPaymentDiscountEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByFullPaymentDiscountRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountRate', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByFullPaymentDiscountRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountRate', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByGlobalEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByGlobalEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMaxDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMaxDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMaxDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountPercentage', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMaxDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountPercentage', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMinDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMinDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMinDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountPercentage', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByMinDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountPercentage', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByShowNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortByShowNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountRate2nd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate2nd', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountRate2ndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate2nd', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountRate3rd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate3rd', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountRate3rdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate3rd', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountRate4th() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate4th', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      sortBySiblingDiscountRate4thDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate4th', Sort.desc);
    });
  }
}

extension AutoDiscountSettingsQuerySortThenBy
    on QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QSortThenBy> {
  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByAllowDuplicateDiscounts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicateDiscounts', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByAllowDuplicateDiscountsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicateDiscounts', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByAutoApplyOnPayment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoApplyOnPayment', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByAutoApplyOnPaymentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoApplyOnPayment', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByEarlyPaymentDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDays', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByEarlyPaymentDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDays', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByEarlyPaymentDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByEarlyPaymentDiscountEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByEarlyPaymentDiscountRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountRate', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByEarlyPaymentDiscountRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earlyPaymentDiscountRate', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByFullPaymentDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByFullPaymentDiscountEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByFullPaymentDiscountRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountRate', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByFullPaymentDiscountRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullPaymentDiscountRate', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByGlobalEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByGlobalEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'globalEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMaxDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMaxDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMaxDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountPercentage', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMaxDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDiscountPercentage', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMinDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountAmount', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMinDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountAmount', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMinDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountPercentage', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByMinDiscountPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minDiscountPercentage', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByShowNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenByShowNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountEnabled', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountEnabled', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountRate2nd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate2nd', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountRate2ndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate2nd', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountRate3rd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate3rd', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountRate3rdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate3rd', Sort.desc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountRate4th() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate4th', Sort.asc);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QAfterSortBy>
      thenBySiblingDiscountRate4thDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'siblingDiscountRate4th', Sort.desc);
    });
  }
}

extension AutoDiscountSettingsQueryWhereDistinct
    on QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct> {
  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByAllowDuplicateDiscounts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicateDiscounts');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByAutoApplyOnPayment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoApplyOnPayment');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByEarlyPaymentDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earlyPaymentDays');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByEarlyPaymentDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earlyPaymentDiscountEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByEarlyPaymentDiscountRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earlyPaymentDiscountRate');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByFullPaymentDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullPaymentDiscountEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByFullPaymentDiscountRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullPaymentDiscountRate');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByGlobalEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'globalEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByMaxDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxDiscountAmount');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByMaxDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxDiscountPercentage');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByMinDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minDiscountAmount');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByMinDiscountPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minDiscountPercentage');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctByShowNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showNotifications');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctBySiblingDiscountEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'siblingDiscountEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctBySiblingDiscountRate2nd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'siblingDiscountRate2nd');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctBySiblingDiscountRate3rd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'siblingDiscountRate3rd');
    });
  }

  QueryBuilder<AutoDiscountSettings, AutoDiscountSettings, QDistinct>
      distinctBySiblingDiscountRate4th() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'siblingDiscountRate4th');
    });
  }
}

extension AutoDiscountSettingsQueryProperty on QueryBuilder<
    AutoDiscountSettings, AutoDiscountSettings, QQueryProperty> {
  QueryBuilder<AutoDiscountSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AutoDiscountSettings, bool, QQueryOperations>
      allowDuplicateDiscountsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicateDiscounts');
    });
  }

  QueryBuilder<AutoDiscountSettings, bool, QQueryOperations>
      autoApplyOnPaymentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoApplyOnPayment');
    });
  }

  QueryBuilder<AutoDiscountSettings, int, QQueryOperations>
      earlyPaymentDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earlyPaymentDays');
    });
  }

  QueryBuilder<AutoDiscountSettings, bool, QQueryOperations>
      earlyPaymentDiscountEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earlyPaymentDiscountEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      earlyPaymentDiscountRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earlyPaymentDiscountRate');
    });
  }

  QueryBuilder<AutoDiscountSettings, bool, QQueryOperations>
      fullPaymentDiscountEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullPaymentDiscountEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      fullPaymentDiscountRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullPaymentDiscountRate');
    });
  }

  QueryBuilder<AutoDiscountSettings, bool, QQueryOperations>
      globalEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'globalEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      maxDiscountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxDiscountAmount');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      maxDiscountPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxDiscountPercentage');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      minDiscountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minDiscountAmount');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      minDiscountPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minDiscountPercentage');
    });
  }

  QueryBuilder<AutoDiscountSettings, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<AutoDiscountSettings, bool, QQueryOperations>
      showNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showNotifications');
    });
  }

  QueryBuilder<AutoDiscountSettings, bool, QQueryOperations>
      siblingDiscountEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'siblingDiscountEnabled');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      siblingDiscountRate2ndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'siblingDiscountRate2nd');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      siblingDiscountRate3rdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'siblingDiscountRate3rd');
    });
  }

  QueryBuilder<AutoDiscountSettings, double, QQueryOperations>
      siblingDiscountRate4thProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'siblingDiscountRate4th');
    });
  }
}
