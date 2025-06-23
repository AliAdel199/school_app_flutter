// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_category.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIncomeCategoryCollection on Isar {
  IsarCollection<IncomeCategory> get incomeCategorys => this.collection();
}

const IncomeCategorySchema = CollectionSchema(
  name: r'IncomeCategory',
  id: -4860738052043136945,
  properties: {
    r'identifier': PropertySchema(
      id: 0,
      name: r'identifier',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _incomeCategoryEstimateSize,
  serialize: _incomeCategorySerialize,
  deserialize: _incomeCategoryDeserialize,
  deserializeProp: _incomeCategoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'identifier': IndexSchema(
      id: -1091831983288130400,
      name: r'identifier',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'identifier',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _incomeCategoryGetId,
  getLinks: _incomeCategoryGetLinks,
  attach: _incomeCategoryAttach,
  version: '3.1.0+1',
);

int _incomeCategoryEstimateSize(
  IncomeCategory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.identifier.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _incomeCategorySerialize(
  IncomeCategory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.identifier);
  writer.writeString(offsets[1], object.name);
}

IncomeCategory _incomeCategoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IncomeCategory();
  object.id = id;
  object.identifier = reader.readString(offsets[0]);
  object.name = reader.readString(offsets[1]);
  return object;
}

P _incomeCategoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _incomeCategoryGetId(IncomeCategory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _incomeCategoryGetLinks(IncomeCategory object) {
  return [];
}

void _incomeCategoryAttach(
    IsarCollection<dynamic> col, Id id, IncomeCategory object) {
  object.id = id;
}

extension IncomeCategoryByIndex on IsarCollection<IncomeCategory> {
  Future<IncomeCategory?> getByIdentifier(String identifier) {
    return getByIndex(r'identifier', [identifier]);
  }

  IncomeCategory? getByIdentifierSync(String identifier) {
    return getByIndexSync(r'identifier', [identifier]);
  }

  Future<bool> deleteByIdentifier(String identifier) {
    return deleteByIndex(r'identifier', [identifier]);
  }

  bool deleteByIdentifierSync(String identifier) {
    return deleteByIndexSync(r'identifier', [identifier]);
  }

  Future<List<IncomeCategory?>> getAllByIdentifier(
      List<String> identifierValues) {
    final values = identifierValues.map((e) => [e]).toList();
    return getAllByIndex(r'identifier', values);
  }

  List<IncomeCategory?> getAllByIdentifierSync(List<String> identifierValues) {
    final values = identifierValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'identifier', values);
  }

  Future<int> deleteAllByIdentifier(List<String> identifierValues) {
    final values = identifierValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'identifier', values);
  }

  int deleteAllByIdentifierSync(List<String> identifierValues) {
    final values = identifierValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'identifier', values);
  }

  Future<Id> putByIdentifier(IncomeCategory object) {
    return putByIndex(r'identifier', object);
  }

  Id putByIdentifierSync(IncomeCategory object, {bool saveLinks = true}) {
    return putByIndexSync(r'identifier', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIdentifier(List<IncomeCategory> objects) {
    return putAllByIndex(r'identifier', objects);
  }

  List<Id> putAllByIdentifierSync(List<IncomeCategory> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'identifier', objects, saveLinks: saveLinks);
  }
}

extension IncomeCategoryQueryWhereSort
    on QueryBuilder<IncomeCategory, IncomeCategory, QWhere> {
  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IncomeCategoryQueryWhere
    on QueryBuilder<IncomeCategory, IncomeCategory, QWhereClause> {
  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhereClause> idBetween(
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhereClause>
      identifierEqualTo(String identifier) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'identifier',
        value: [identifier],
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterWhereClause>
      identifierNotEqualTo(String identifier) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identifier',
              lower: [],
              upper: [identifier],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identifier',
              lower: [identifier],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identifier',
              lower: [identifier],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identifier',
              lower: [],
              upper: [identifier],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IncomeCategoryQueryFilter
    on QueryBuilder<IncomeCategory, IncomeCategory, QFilterCondition> {
  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'identifier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'identifier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'identifier',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identifier',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      identifierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'identifier',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
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

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension IncomeCategoryQueryObject
    on QueryBuilder<IncomeCategory, IncomeCategory, QFilterCondition> {}

extension IncomeCategoryQueryLinks
    on QueryBuilder<IncomeCategory, IncomeCategory, QFilterCondition> {}

extension IncomeCategoryQuerySortBy
    on QueryBuilder<IncomeCategory, IncomeCategory, QSortBy> {
  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy>
      sortByIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.asc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy>
      sortByIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.desc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension IncomeCategoryQuerySortThenBy
    on QueryBuilder<IncomeCategory, IncomeCategory, QSortThenBy> {
  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy>
      thenByIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.asc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy>
      thenByIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identifier', Sort.desc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension IncomeCategoryQueryWhereDistinct
    on QueryBuilder<IncomeCategory, IncomeCategory, QDistinct> {
  QueryBuilder<IncomeCategory, IncomeCategory, QDistinct> distinctByIdentifier(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identifier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeCategory, IncomeCategory, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension IncomeCategoryQueryProperty
    on QueryBuilder<IncomeCategory, IncomeCategory, QQueryProperty> {
  QueryBuilder<IncomeCategory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IncomeCategory, String, QQueryOperations> identifierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identifier');
    });
  }

  QueryBuilder<IncomeCategory, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
