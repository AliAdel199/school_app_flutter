// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_serial.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvoiceCounterCollection on Isar {
  IsarCollection<InvoiceCounter> get invoiceCounters => this.collection();
}

const InvoiceCounterSchema = CollectionSchema(
  name: r'InvoiceCounter',
  id: -9059781928858253207,
  properties: {
    r'lastInvoiceNumber': PropertySchema(
      id: 0,
      name: r'lastInvoiceNumber',
      type: IsarType.long,
    )
  },
  estimateSize: _invoiceCounterEstimateSize,
  serialize: _invoiceCounterSerialize,
  deserialize: _invoiceCounterDeserialize,
  deserializeProp: _invoiceCounterDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _invoiceCounterGetId,
  getLinks: _invoiceCounterGetLinks,
  attach: _invoiceCounterAttach,
  version: '3.1.0+1',
);

int _invoiceCounterEstimateSize(
  InvoiceCounter object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _invoiceCounterSerialize(
  InvoiceCounter object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.lastInvoiceNumber);
}

InvoiceCounter _invoiceCounterDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InvoiceCounter();
  object.id = id;
  object.lastInvoiceNumber = reader.readLong(offsets[0]);
  return object;
}

P _invoiceCounterDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _invoiceCounterGetId(InvoiceCounter object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _invoiceCounterGetLinks(InvoiceCounter object) {
  return [];
}

void _invoiceCounterAttach(
    IsarCollection<dynamic> col, Id id, InvoiceCounter object) {
  object.id = id;
}

extension InvoiceCounterQueryWhereSort
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QWhere> {
  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InvoiceCounterQueryWhere
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QWhereClause> {
  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterWhereClause> idBetween(
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

extension InvoiceCounterQueryFilter
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QFilterCondition> {
  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition>
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

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition>
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

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition> idBetween(
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

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition>
      lastInvoiceNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastInvoiceNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition>
      lastInvoiceNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastInvoiceNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition>
      lastInvoiceNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastInvoiceNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterFilterCondition>
      lastInvoiceNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastInvoiceNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension InvoiceCounterQueryObject
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QFilterCondition> {}

extension InvoiceCounterQueryLinks
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QFilterCondition> {}

extension InvoiceCounterQuerySortBy
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QSortBy> {
  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterSortBy>
      sortByLastInvoiceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInvoiceNumber', Sort.asc);
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterSortBy>
      sortByLastInvoiceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInvoiceNumber', Sort.desc);
    });
  }
}

extension InvoiceCounterQuerySortThenBy
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QSortThenBy> {
  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterSortBy>
      thenByLastInvoiceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInvoiceNumber', Sort.asc);
    });
  }

  QueryBuilder<InvoiceCounter, InvoiceCounter, QAfterSortBy>
      thenByLastInvoiceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInvoiceNumber', Sort.desc);
    });
  }
}

extension InvoiceCounterQueryWhereDistinct
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QDistinct> {
  QueryBuilder<InvoiceCounter, InvoiceCounter, QDistinct>
      distinctByLastInvoiceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastInvoiceNumber');
    });
  }
}

extension InvoiceCounterQueryProperty
    on QueryBuilder<InvoiceCounter, InvoiceCounter, QQueryProperty> {
  QueryBuilder<InvoiceCounter, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InvoiceCounter, int, QQueryOperations>
      lastInvoiceNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastInvoiceNumber');
    });
  }
}
