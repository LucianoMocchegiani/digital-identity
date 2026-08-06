// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_record_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConnectionRecordIsarCollection on Isar {
  IsarCollection<ConnectionRecordIsar> get connectionRecordIsars =>
      this.collection();
}

const ConnectionRecordIsarSchema = CollectionSchema(
  name: r'ConnectionRecordIsar',
  id: -5825174353747538186,
  properties: {
    r'connectionId': PropertySchema(
      id: 0,
      name: r'connectionId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'goalCode': PropertySchema(
      id: 2,
      name: r'goalCode',
      type: IsarType.string,
    ),
    r'label': PropertySchema(
      id: 3,
      name: r'label',
      type: IsarType.string,
    ),
    r'myDid': PropertySchema(
      id: 4,
      name: r'myDid',
      type: IsarType.string,
    ),
    r'stateIndex': PropertySchema(
      id: 5,
      name: r'stateIndex',
      type: IsarType.long,
    ),
    r'theirDid': PropertySchema(
      id: 6,
      name: r'theirDid',
      type: IsarType.string,
    ),
    r'theirDidDocJson': PropertySchema(
      id: 7,
      name: r'theirDidDocJson',
      type: IsarType.string,
    )
  },
  estimateSize: _connectionRecordIsarEstimateSize,
  serialize: _connectionRecordIsarSerialize,
  deserialize: _connectionRecordIsarDeserialize,
  deserializeProp: _connectionRecordIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'connectionId': IndexSchema(
      id: 509570965771119525,
      name: r'connectionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'connectionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _connectionRecordIsarGetId,
  getLinks: _connectionRecordIsarGetLinks,
  attach: _connectionRecordIsarAttach,
  version: '3.1.0+1',
);

int _connectionRecordIsarEstimateSize(
  ConnectionRecordIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.connectionId.length * 3;
  {
    final value = object.goalCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.label;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.myDid.length * 3;
  bytesCount += 3 + object.theirDid.length * 3;
  {
    final value = object.theirDidDocJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _connectionRecordIsarSerialize(
  ConnectionRecordIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.connectionId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.goalCode);
  writer.writeString(offsets[3], object.label);
  writer.writeString(offsets[4], object.myDid);
  writer.writeLong(offsets[5], object.stateIndex);
  writer.writeString(offsets[6], object.theirDid);
  writer.writeString(offsets[7], object.theirDidDocJson);
}

ConnectionRecordIsar _connectionRecordIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConnectionRecordIsar();
  object.connectionId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.goalCode = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.label = reader.readStringOrNull(offsets[3]);
  object.myDid = reader.readString(offsets[4]);
  object.stateIndex = reader.readLong(offsets[5]);
  object.theirDid = reader.readString(offsets[6]);
  object.theirDidDocJson = reader.readStringOrNull(offsets[7]);
  return object;
}

P _connectionRecordIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _connectionRecordIsarGetId(ConnectionRecordIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _connectionRecordIsarGetLinks(
    ConnectionRecordIsar object) {
  return [];
}

void _connectionRecordIsarAttach(
    IsarCollection<dynamic> col, Id id, ConnectionRecordIsar object) {
  object.id = id;
}

extension ConnectionRecordIsarByIndex on IsarCollection<ConnectionRecordIsar> {
  Future<ConnectionRecordIsar?> getByConnectionId(String connectionId) {
    return getByIndex(r'connectionId', [connectionId]);
  }

  ConnectionRecordIsar? getByConnectionIdSync(String connectionId) {
    return getByIndexSync(r'connectionId', [connectionId]);
  }

  Future<bool> deleteByConnectionId(String connectionId) {
    return deleteByIndex(r'connectionId', [connectionId]);
  }

  bool deleteByConnectionIdSync(String connectionId) {
    return deleteByIndexSync(r'connectionId', [connectionId]);
  }

  Future<List<ConnectionRecordIsar?>> getAllByConnectionId(
      List<String> connectionIdValues) {
    final values = connectionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'connectionId', values);
  }

  List<ConnectionRecordIsar?> getAllByConnectionIdSync(
      List<String> connectionIdValues) {
    final values = connectionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'connectionId', values);
  }

  Future<int> deleteAllByConnectionId(List<String> connectionIdValues) {
    final values = connectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'connectionId', values);
  }

  int deleteAllByConnectionIdSync(List<String> connectionIdValues) {
    final values = connectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'connectionId', values);
  }

  Future<Id> putByConnectionId(ConnectionRecordIsar object) {
    return putByIndex(r'connectionId', object);
  }

  Id putByConnectionIdSync(ConnectionRecordIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'connectionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByConnectionId(List<ConnectionRecordIsar> objects) {
    return putAllByIndex(r'connectionId', objects);
  }

  List<Id> putAllByConnectionIdSync(List<ConnectionRecordIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'connectionId', objects, saveLinks: saveLinks);
  }
}

extension ConnectionRecordIsarQueryWhereSort
    on QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QWhere> {
  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ConnectionRecordIsarQueryWhere
    on QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QWhereClause> {
  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhereClause>
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhereClause>
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhereClause>
      connectionIdEqualTo(String connectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'connectionId',
        value: [connectionId],
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterWhereClause>
      connectionIdNotEqualTo(String connectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionId',
              lower: [],
              upper: [connectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionId',
              lower: [connectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionId',
              lower: [connectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'connectionId',
              lower: [],
              upper: [connectionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ConnectionRecordIsarQueryFilter on QueryBuilder<ConnectionRecordIsar,
    ConnectionRecordIsar, QFilterCondition> {
  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'connectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'connectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'connectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'connectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'connectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'connectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      connectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'connectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      connectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'connectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'connectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> connectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'connectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalCode',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalCode',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'goalCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'goalCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      goalCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goalCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      goalCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goalCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> goalCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goalCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
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

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'label',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'label',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'myDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'myDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'myDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'myDid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'myDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'myDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      myDidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'myDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      myDidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'myDid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'myDid',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> myDidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'myDid',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> stateIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> stateIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> stateIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> stateIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theirDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'theirDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'theirDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'theirDid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'theirDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'theirDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      theirDidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'theirDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      theirDidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'theirDid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theirDid',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'theirDid',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'theirDidDocJson',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'theirDidDocJson',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theirDidDocJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'theirDidDocJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'theirDidDocJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'theirDidDocJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'theirDidDocJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'theirDidDocJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      theirDidDocJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'theirDidDocJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
          QAfterFilterCondition>
      theirDidDocJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'theirDidDocJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theirDidDocJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar,
      QAfterFilterCondition> theirDidDocJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'theirDidDocJson',
        value: '',
      ));
    });
  }
}

extension ConnectionRecordIsarQueryObject on QueryBuilder<ConnectionRecordIsar,
    ConnectionRecordIsar, QFilterCondition> {}

extension ConnectionRecordIsarQueryLinks on QueryBuilder<ConnectionRecordIsar,
    ConnectionRecordIsar, QFilterCondition> {}

extension ConnectionRecordIsarQuerySortBy
    on QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QSortBy> {
  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByConnectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionId', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByConnectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionId', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByGoalCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCode', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByGoalCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCode', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByMyDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myDid', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByMyDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myDid', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByStateIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateIndex', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByStateIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateIndex', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByTheirDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDid', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByTheirDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDid', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByTheirDidDocJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDidDocJson', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      sortByTheirDidDocJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDidDocJson', Sort.desc);
    });
  }
}

extension ConnectionRecordIsarQuerySortThenBy
    on QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QSortThenBy> {
  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByConnectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionId', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByConnectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'connectionId', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByGoalCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCode', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByGoalCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalCode', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByMyDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myDid', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByMyDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'myDid', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByStateIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateIndex', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByStateIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateIndex', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByTheirDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDid', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByTheirDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDid', Sort.desc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByTheirDidDocJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDidDocJson', Sort.asc);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QAfterSortBy>
      thenByTheirDidDocJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theirDidDocJson', Sort.desc);
    });
  }
}

extension ConnectionRecordIsarQueryWhereDistinct
    on QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct> {
  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByConnectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'connectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByGoalCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByMyDid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'myDid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByStateIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateIndex');
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByTheirDid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theirDid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConnectionRecordIsar, ConnectionRecordIsar, QDistinct>
      distinctByTheirDidDocJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theirDidDocJson',
          caseSensitive: caseSensitive);
    });
  }
}

extension ConnectionRecordIsarQueryProperty on QueryBuilder<
    ConnectionRecordIsar, ConnectionRecordIsar, QQueryProperty> {
  QueryBuilder<ConnectionRecordIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ConnectionRecordIsar, String, QQueryOperations>
      connectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'connectionId');
    });
  }

  QueryBuilder<ConnectionRecordIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ConnectionRecordIsar, String?, QQueryOperations>
      goalCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalCode');
    });
  }

  QueryBuilder<ConnectionRecordIsar, String?, QQueryOperations>
      labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<ConnectionRecordIsar, String, QQueryOperations> myDidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'myDid');
    });
  }

  QueryBuilder<ConnectionRecordIsar, int, QQueryOperations>
      stateIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateIndex');
    });
  }

  QueryBuilder<ConnectionRecordIsar, String, QQueryOperations>
      theirDidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theirDid');
    });
  }

  QueryBuilder<ConnectionRecordIsar, String?, QQueryOperations>
      theirDidDocJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theirDidDocJson');
    });
  }
}
