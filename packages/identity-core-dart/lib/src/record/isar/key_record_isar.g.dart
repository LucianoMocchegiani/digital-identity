// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_record_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetKeyRecordIsarCollection on Isar {
  IsarCollection<KeyRecordIsar> get keyRecordIsars => this.collection();
}

const KeyRecordIsarSchema = CollectionSchema(
  name: r'KeyRecordIsar',
  id: 1454916587982640192,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'did': PropertySchema(
      id: 1,
      name: r'did',
      type: IsarType.string,
    ),
    r'isHardwareBacked': PropertySchema(
      id: 2,
      name: r'isHardwareBacked',
      type: IsarType.bool,
    ),
    r'keyId': PropertySchema(
      id: 3,
      name: r'keyId',
      type: IsarType.string,
    ),
    r'keyTypeIndex': PropertySchema(
      id: 4,
      name: r'keyTypeIndex',
      type: IsarType.long,
    ),
    r'privateJwkJson': PropertySchema(
      id: 5,
      name: r'privateJwkJson',
      type: IsarType.string,
    ),
    r'publicJwkJson': PropertySchema(
      id: 6,
      name: r'publicJwkJson',
      type: IsarType.string,
    )
  },
  estimateSize: _keyRecordIsarEstimateSize,
  serialize: _keyRecordIsarSerialize,
  deserialize: _keyRecordIsarDeserialize,
  deserializeProp: _keyRecordIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'keyId': IndexSchema(
      id: 2852921932302977192,
      name: r'keyId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'keyId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _keyRecordIsarGetId,
  getLinks: _keyRecordIsarGetLinks,
  attach: _keyRecordIsarAttach,
  version: '3.1.0+1',
);

int _keyRecordIsarEstimateSize(
  KeyRecordIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.did;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.keyId.length * 3;
  {
    final value = object.privateJwkJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.publicJwkJson.length * 3;
  return bytesCount;
}

void _keyRecordIsarSerialize(
  KeyRecordIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.did);
  writer.writeBool(offsets[2], object.isHardwareBacked);
  writer.writeString(offsets[3], object.keyId);
  writer.writeLong(offsets[4], object.keyTypeIndex);
  writer.writeString(offsets[5], object.privateJwkJson);
  writer.writeString(offsets[6], object.publicJwkJson);
}

KeyRecordIsar _keyRecordIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = KeyRecordIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.did = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.isHardwareBacked = reader.readBool(offsets[2]);
  object.keyId = reader.readString(offsets[3]);
  object.keyTypeIndex = reader.readLong(offsets[4]);
  object.privateJwkJson = reader.readStringOrNull(offsets[5]);
  object.publicJwkJson = reader.readString(offsets[6]);
  return object;
}

P _keyRecordIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _keyRecordIsarGetId(KeyRecordIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _keyRecordIsarGetLinks(KeyRecordIsar object) {
  return [];
}

void _keyRecordIsarAttach(
    IsarCollection<dynamic> col, Id id, KeyRecordIsar object) {
  object.id = id;
}

extension KeyRecordIsarByIndex on IsarCollection<KeyRecordIsar> {
  Future<KeyRecordIsar?> getByKeyId(String keyId) {
    return getByIndex(r'keyId', [keyId]);
  }

  KeyRecordIsar? getByKeyIdSync(String keyId) {
    return getByIndexSync(r'keyId', [keyId]);
  }

  Future<bool> deleteByKeyId(String keyId) {
    return deleteByIndex(r'keyId', [keyId]);
  }

  bool deleteByKeyIdSync(String keyId) {
    return deleteByIndexSync(r'keyId', [keyId]);
  }

  Future<List<KeyRecordIsar?>> getAllByKeyId(List<String> keyIdValues) {
    final values = keyIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'keyId', values);
  }

  List<KeyRecordIsar?> getAllByKeyIdSync(List<String> keyIdValues) {
    final values = keyIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'keyId', values);
  }

  Future<int> deleteAllByKeyId(List<String> keyIdValues) {
    final values = keyIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'keyId', values);
  }

  int deleteAllByKeyIdSync(List<String> keyIdValues) {
    final values = keyIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'keyId', values);
  }

  Future<Id> putByKeyId(KeyRecordIsar object) {
    return putByIndex(r'keyId', object);
  }

  Id putByKeyIdSync(KeyRecordIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'keyId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKeyId(List<KeyRecordIsar> objects) {
    return putAllByIndex(r'keyId', objects);
  }

  List<Id> putAllByKeyIdSync(List<KeyRecordIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'keyId', objects, saveLinks: saveLinks);
  }
}

extension KeyRecordIsarQueryWhereSort
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QWhere> {
  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension KeyRecordIsarQueryWhere
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QWhereClause> {
  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhereClause> keyIdEqualTo(
      String keyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'keyId',
        value: [keyId],
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterWhereClause> keyIdNotEqualTo(
      String keyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyId',
              lower: [],
              upper: [keyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyId',
              lower: [keyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyId',
              lower: [keyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyId',
              lower: [],
              upper: [keyId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension KeyRecordIsarQueryFilter
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QFilterCondition> {
  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      didIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      didIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'did',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> didEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      didGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> didLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> didBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'did',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      didStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> didEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> didContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> didMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'did',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      didIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      didIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      isHardwareBackedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHardwareBacked',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyId',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keyId',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyTypeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyTypeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyTypeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      keyTypeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyTypeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'privateJwkJson',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'privateJwkJson',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'privateJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'privateJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'privateJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'privateJwkJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'privateJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'privateJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'privateJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'privateJwkJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'privateJwkJson',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      privateJwkJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'privateJwkJson',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publicJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publicJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publicJwkJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'publicJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'publicJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'publicJwkJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'publicJwkJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicJwkJson',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterFilterCondition>
      publicJwkJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publicJwkJson',
        value: '',
      ));
    });
  }
}

extension KeyRecordIsarQueryObject
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QFilterCondition> {}

extension KeyRecordIsarQueryLinks
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QFilterCondition> {}

extension KeyRecordIsarQuerySortBy
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QSortBy> {
  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> sortByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> sortByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByIsHardwareBacked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHardwareBacked', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByIsHardwareBackedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHardwareBacked', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> sortByKeyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyId', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> sortByKeyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyId', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByKeyTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByKeyTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByPrivateJwkJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateJwkJson', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByPrivateJwkJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateJwkJson', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByPublicJwkJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicJwkJson', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      sortByPublicJwkJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicJwkJson', Sort.desc);
    });
  }
}

extension KeyRecordIsarQuerySortThenBy
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QSortThenBy> {
  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> thenByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> thenByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByIsHardwareBacked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHardwareBacked', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByIsHardwareBackedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHardwareBacked', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> thenByKeyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyId', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy> thenByKeyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyId', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByKeyTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByKeyTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByPrivateJwkJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateJwkJson', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByPrivateJwkJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privateJwkJson', Sort.desc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByPublicJwkJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicJwkJson', Sort.asc);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QAfterSortBy>
      thenByPublicJwkJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicJwkJson', Sort.desc);
    });
  }
}

extension KeyRecordIsarQueryWhereDistinct
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct> {
  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct> distinctByDid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'did', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct>
      distinctByIsHardwareBacked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHardwareBacked');
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct> distinctByKeyId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct>
      distinctByKeyTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyTypeIndex');
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct>
      distinctByPrivateJwkJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'privateJwkJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KeyRecordIsar, KeyRecordIsar, QDistinct> distinctByPublicJwkJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicJwkJson',
          caseSensitive: caseSensitive);
    });
  }
}

extension KeyRecordIsarQueryProperty
    on QueryBuilder<KeyRecordIsar, KeyRecordIsar, QQueryProperty> {
  QueryBuilder<KeyRecordIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<KeyRecordIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<KeyRecordIsar, String?, QQueryOperations> didProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'did');
    });
  }

  QueryBuilder<KeyRecordIsar, bool, QQueryOperations>
      isHardwareBackedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHardwareBacked');
    });
  }

  QueryBuilder<KeyRecordIsar, String, QQueryOperations> keyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyId');
    });
  }

  QueryBuilder<KeyRecordIsar, int, QQueryOperations> keyTypeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyTypeIndex');
    });
  }

  QueryBuilder<KeyRecordIsar, String?, QQueryOperations>
      privateJwkJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'privateJwkJson');
    });
  }

  QueryBuilder<KeyRecordIsar, String, QQueryOperations>
      publicJwkJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicJwkJson');
    });
  }
}
