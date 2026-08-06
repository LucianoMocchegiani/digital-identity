// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'w3c_credential_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetW3cCredentialIsarCollection on Isar {
  IsarCollection<W3cCredentialIsar> get w3cCredentialIsars => this.collection();
}

const W3cCredentialIsarSchema = CollectionSchema(
  name: r'W3cCredentialIsar',
  id: -9005735608251419684,
  properties: {
    r'claimFormatIndex': PropertySchema(
      id: 0,
      name: r'claimFormatIndex',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'credentialJson': PropertySchema(
      id: 2,
      name: r'credentialJson',
      type: IsarType.string,
    ),
    r'displayMetadataJson': PropertySchema(
      id: 3,
      name: r'displayMetadataJson',
      type: IsarType.string,
    ),
    r'holderDid': PropertySchema(
      id: 4,
      name: r'holderDid',
      type: IsarType.string,
    ),
    r'issuerDid': PropertySchema(
      id: 5,
      name: r'issuerDid',
      type: IsarType.string,
    ),
    r'recordId': PropertySchema(
      id: 6,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'types': PropertySchema(
      id: 7,
      name: r'types',
      type: IsarType.stringList,
    ),
    r'validFrom': PropertySchema(
      id: 8,
      name: r'validFrom',
      type: IsarType.dateTime,
    ),
    r'validUntil': PropertySchema(
      id: 9,
      name: r'validUntil',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _w3cCredentialIsarEstimateSize,
  serialize: _w3cCredentialIsarSerialize,
  deserialize: _w3cCredentialIsarDeserialize,
  deserializeProp: _w3cCredentialIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'recordId': IndexSchema(
      id: 907839981883940929,
      name: r'recordId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'recordId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _w3cCredentialIsarGetId,
  getLinks: _w3cCredentialIsarGetLinks,
  attach: _w3cCredentialIsarAttach,
  version: '3.1.0+1',
);

int _w3cCredentialIsarEstimateSize(
  W3cCredentialIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.credentialJson.length * 3;
  {
    final value = object.displayMetadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.holderDid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.issuerDid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.recordId.length * 3;
  bytesCount += 3 + object.types.length * 3;
  {
    for (var i = 0; i < object.types.length; i++) {
      final value = object.types[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _w3cCredentialIsarSerialize(
  W3cCredentialIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.claimFormatIndex);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.credentialJson);
  writer.writeString(offsets[3], object.displayMetadataJson);
  writer.writeString(offsets[4], object.holderDid);
  writer.writeString(offsets[5], object.issuerDid);
  writer.writeString(offsets[6], object.recordId);
  writer.writeStringList(offsets[7], object.types);
  writer.writeDateTime(offsets[8], object.validFrom);
  writer.writeDateTime(offsets[9], object.validUntil);
}

W3cCredentialIsar _w3cCredentialIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = W3cCredentialIsar();
  object.claimFormatIndex = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.credentialJson = reader.readString(offsets[2]);
  object.displayMetadataJson = reader.readStringOrNull(offsets[3]);
  object.holderDid = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.issuerDid = reader.readStringOrNull(offsets[5]);
  object.recordId = reader.readString(offsets[6]);
  object.types = reader.readStringList(offsets[7]) ?? [];
  object.validFrom = reader.readDateTimeOrNull(offsets[8]);
  object.validUntil = reader.readDateTimeOrNull(offsets[9]);
  return object;
}

P _w3cCredentialIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _w3cCredentialIsarGetId(W3cCredentialIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _w3cCredentialIsarGetLinks(
    W3cCredentialIsar object) {
  return [];
}

void _w3cCredentialIsarAttach(
    IsarCollection<dynamic> col, Id id, W3cCredentialIsar object) {
  object.id = id;
}

extension W3cCredentialIsarByIndex on IsarCollection<W3cCredentialIsar> {
  Future<W3cCredentialIsar?> getByRecordId(String recordId) {
    return getByIndex(r'recordId', [recordId]);
  }

  W3cCredentialIsar? getByRecordIdSync(String recordId) {
    return getByIndexSync(r'recordId', [recordId]);
  }

  Future<bool> deleteByRecordId(String recordId) {
    return deleteByIndex(r'recordId', [recordId]);
  }

  bool deleteByRecordIdSync(String recordId) {
    return deleteByIndexSync(r'recordId', [recordId]);
  }

  Future<List<W3cCredentialIsar?>> getAllByRecordId(
      List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordId', values);
  }

  List<W3cCredentialIsar?> getAllByRecordIdSync(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'recordId', values);
  }

  Future<int> deleteAllByRecordId(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'recordId', values);
  }

  int deleteAllByRecordIdSync(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'recordId', values);
  }

  Future<Id> putByRecordId(W3cCredentialIsar object) {
    return putByIndex(r'recordId', object);
  }

  Id putByRecordIdSync(W3cCredentialIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordId(List<W3cCredentialIsar> objects) {
    return putAllByIndex(r'recordId', objects);
  }

  List<Id> putAllByRecordIdSync(List<W3cCredentialIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordId', objects, saveLinks: saveLinks);
  }
}

extension W3cCredentialIsarQueryWhereSort
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QWhere> {
  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension W3cCredentialIsarQueryWhere
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QWhereClause> {
  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhereClause>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhereClause>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhereClause>
      recordIdEqualTo(String recordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordId',
        value: [recordId],
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterWhereClause>
      recordIdNotEqualTo(String recordId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [],
              upper: [recordId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [recordId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [recordId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [],
              upper: [recordId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension W3cCredentialIsarQueryFilter
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QFilterCondition> {
  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      claimFormatIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'claimFormatIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      claimFormatIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'claimFormatIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      claimFormatIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'claimFormatIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      claimFormatIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'claimFormatIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credentialJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credentialJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credentialJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'credentialJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'credentialJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'credentialJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'credentialJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialJson',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      credentialJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'credentialJson',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'displayMetadataJson',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'displayMetadataJson',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayMetadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayMetadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      displayMetadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'holderDid',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'holderDid',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'holderDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'holderDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'holderDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'holderDid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'holderDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'holderDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'holderDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'holderDid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'holderDid',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      holderDidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'holderDid',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'issuerDid',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'issuerDid',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuerDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuerDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuerDid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issuerDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issuerDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuerDid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuerDid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerDid',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      issuerDidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuerDid',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'types',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'types',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'types',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'types',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'types',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'types',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'types',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'types',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'types',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'types',
        value: '',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'types',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'types',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'types',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'types',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'types',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      typesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'types',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validFromIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'validFrom',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validFromIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'validFrom',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validFromEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'validFrom',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validFromGreaterThan(
    DateTime? value, {
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validFromLessThan(
    DateTime? value, {
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validFromBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'validUntil',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'validUntil',
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'validUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validUntilGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'validUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validUntilLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'validUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterFilterCondition>
      validUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'validUntil',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension W3cCredentialIsarQueryObject
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QFilterCondition> {}

extension W3cCredentialIsarQueryLinks
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QFilterCondition> {}

extension W3cCredentialIsarQuerySortBy
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QSortBy> {
  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByClaimFormatIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimFormatIndex', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByClaimFormatIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimFormatIndex', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByCredentialJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialJson', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByCredentialJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialJson', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByDisplayMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByDisplayMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByHolderDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'holderDid', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByHolderDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'holderDid', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByIssuerDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerDid', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByIssuerDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerDid', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByValidFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByValidFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByValidUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validUntil', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      sortByValidUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validUntil', Sort.desc);
    });
  }
}

extension W3cCredentialIsarQuerySortThenBy
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QSortThenBy> {
  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByClaimFormatIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimFormatIndex', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByClaimFormatIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimFormatIndex', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByCredentialJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialJson', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByCredentialJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialJson', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByDisplayMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByDisplayMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByHolderDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'holderDid', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByHolderDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'holderDid', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByIssuerDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerDid', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByIssuerDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerDid', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByValidFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByValidFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validFrom', Sort.desc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByValidUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validUntil', Sort.asc);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QAfterSortBy>
      thenByValidUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validUntil', Sort.desc);
    });
  }
}

extension W3cCredentialIsarQueryWhereDistinct
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct> {
  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByClaimFormatIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'claimFormatIndex');
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByCredentialJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credentialJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByDisplayMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayMetadataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByHolderDid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'holderDid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByIssuerDid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuerDid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByRecordId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByTypes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'types');
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByValidFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validFrom');
    });
  }

  QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QDistinct>
      distinctByValidUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validUntil');
    });
  }
}

extension W3cCredentialIsarQueryProperty
    on QueryBuilder<W3cCredentialIsar, W3cCredentialIsar, QQueryProperty> {
  QueryBuilder<W3cCredentialIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<W3cCredentialIsar, int, QQueryOperations>
      claimFormatIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'claimFormatIndex');
    });
  }

  QueryBuilder<W3cCredentialIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<W3cCredentialIsar, String, QQueryOperations>
      credentialJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialJson');
    });
  }

  QueryBuilder<W3cCredentialIsar, String?, QQueryOperations>
      displayMetadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayMetadataJson');
    });
  }

  QueryBuilder<W3cCredentialIsar, String?, QQueryOperations>
      holderDidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'holderDid');
    });
  }

  QueryBuilder<W3cCredentialIsar, String?, QQueryOperations>
      issuerDidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuerDid');
    });
  }

  QueryBuilder<W3cCredentialIsar, String, QQueryOperations> recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<W3cCredentialIsar, List<String>, QQueryOperations>
      typesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'types');
    });
  }

  QueryBuilder<W3cCredentialIsar, DateTime?, QQueryOperations>
      validFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validFrom');
    });
  }

  QueryBuilder<W3cCredentialIsar, DateTime?, QQueryOperations>
      validUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validUntil');
    });
  }
}
