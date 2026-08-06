// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deferred_credential_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeferredCredentialIsarCollection on Isar {
  IsarCollection<DeferredCredentialIsar> get deferredCredentialIsars =>
      this.collection();
}

const DeferredCredentialIsarSchema = CollectionSchema(
  name: r'DeferredCredentialIsar',
  id: -7319844479454448701,
  properties: {
    r'accessTokenJson': PropertySchema(
      id: 0,
      name: r'accessTokenJson',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'issuerMetadataJson': PropertySchema(
      id: 2,
      name: r'issuerMetadataJson',
      type: IsarType.string,
    ),
    r'lastCheckedAt': PropertySchema(
      id: 3,
      name: r'lastCheckedAt',
      type: IsarType.dateTime,
    ),
    r'lastErroredAt': PropertySchema(
      id: 4,
      name: r'lastErroredAt',
      type: IsarType.dateTime,
    ),
    r'recordId': PropertySchema(
      id: 5,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'responseJson': PropertySchema(
      id: 6,
      name: r'responseJson',
      type: IsarType.string,
    )
  },
  estimateSize: _deferredCredentialIsarEstimateSize,
  serialize: _deferredCredentialIsarSerialize,
  deserialize: _deferredCredentialIsarDeserialize,
  deserializeProp: _deferredCredentialIsarDeserializeProp,
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
  getId: _deferredCredentialIsarGetId,
  getLinks: _deferredCredentialIsarGetLinks,
  attach: _deferredCredentialIsarAttach,
  version: '3.1.0+1',
);

int _deferredCredentialIsarEstimateSize(
  DeferredCredentialIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accessTokenJson.length * 3;
  bytesCount += 3 + object.issuerMetadataJson.length * 3;
  bytesCount += 3 + object.recordId.length * 3;
  bytesCount += 3 + object.responseJson.length * 3;
  return bytesCount;
}

void _deferredCredentialIsarSerialize(
  DeferredCredentialIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accessTokenJson);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.issuerMetadataJson);
  writer.writeDateTime(offsets[3], object.lastCheckedAt);
  writer.writeDateTime(offsets[4], object.lastErroredAt);
  writer.writeString(offsets[5], object.recordId);
  writer.writeString(offsets[6], object.responseJson);
}

DeferredCredentialIsar _deferredCredentialIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeferredCredentialIsar();
  object.accessTokenJson = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.issuerMetadataJson = reader.readString(offsets[2]);
  object.lastCheckedAt = reader.readDateTime(offsets[3]);
  object.lastErroredAt = reader.readDateTimeOrNull(offsets[4]);
  object.recordId = reader.readString(offsets[5]);
  object.responseJson = reader.readString(offsets[6]);
  return object;
}

P _deferredCredentialIsarDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deferredCredentialIsarGetId(DeferredCredentialIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deferredCredentialIsarGetLinks(
    DeferredCredentialIsar object) {
  return [];
}

void _deferredCredentialIsarAttach(
    IsarCollection<dynamic> col, Id id, DeferredCredentialIsar object) {
  object.id = id;
}

extension DeferredCredentialIsarByIndex
    on IsarCollection<DeferredCredentialIsar> {
  Future<DeferredCredentialIsar?> getByRecordId(String recordId) {
    return getByIndex(r'recordId', [recordId]);
  }

  DeferredCredentialIsar? getByRecordIdSync(String recordId) {
    return getByIndexSync(r'recordId', [recordId]);
  }

  Future<bool> deleteByRecordId(String recordId) {
    return deleteByIndex(r'recordId', [recordId]);
  }

  bool deleteByRecordIdSync(String recordId) {
    return deleteByIndexSync(r'recordId', [recordId]);
  }

  Future<List<DeferredCredentialIsar?>> getAllByRecordId(
      List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordId', values);
  }

  List<DeferredCredentialIsar?> getAllByRecordIdSync(
      List<String> recordIdValues) {
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

  Future<Id> putByRecordId(DeferredCredentialIsar object) {
    return putByIndex(r'recordId', object);
  }

  Id putByRecordIdSync(DeferredCredentialIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordId(List<DeferredCredentialIsar> objects) {
    return putAllByIndex(r'recordId', objects);
  }

  List<Id> putAllByRecordIdSync(List<DeferredCredentialIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordId', objects, saveLinks: saveLinks);
  }
}

extension DeferredCredentialIsarQueryWhereSort
    on QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QWhere> {
  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DeferredCredentialIsarQueryWhere on QueryBuilder<
    DeferredCredentialIsar, DeferredCredentialIsar, QWhereClause> {
  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterWhereClause> recordIdEqualTo(String recordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordId',
        value: [recordId],
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterWhereClause> recordIdNotEqualTo(String recordId) {
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

extension DeferredCredentialIsarQueryFilter on QueryBuilder<
    DeferredCredentialIsar, DeferredCredentialIsar, QFilterCondition> {
  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accessTokenJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accessTokenJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accessTokenJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accessTokenJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accessTokenJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accessTokenJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      accessTokenJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accessTokenJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      accessTokenJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accessTokenJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accessTokenJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> accessTokenJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accessTokenJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuerMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuerMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuerMetadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issuerMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issuerMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      issuerMetadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuerMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      issuerMetadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuerMetadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> issuerMetadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuerMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastCheckedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastCheckedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastCheckedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastCheckedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCheckedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastErroredAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastErroredAt',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastErroredAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastErroredAt',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastErroredAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastErroredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastErroredAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastErroredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastErroredAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastErroredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> lastErroredAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastErroredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdEqualTo(
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdGreaterThan(
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdLessThan(
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdBetween(
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdStartsWith(
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdEndsWith(
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

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      recordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      recordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'responseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'responseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'responseJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'responseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'responseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      responseJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'responseJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
          QAfterFilterCondition>
      responseJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'responseJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar,
      QAfterFilterCondition> responseJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'responseJson',
        value: '',
      ));
    });
  }
}

extension DeferredCredentialIsarQueryObject on QueryBuilder<
    DeferredCredentialIsar, DeferredCredentialIsar, QFilterCondition> {}

extension DeferredCredentialIsarQueryLinks on QueryBuilder<
    DeferredCredentialIsar, DeferredCredentialIsar, QFilterCondition> {}

extension DeferredCredentialIsarQuerySortBy
    on QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QSortBy> {
  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByAccessTokenJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accessTokenJson', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByAccessTokenJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accessTokenJson', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByIssuerMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByIssuerMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByLastCheckedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByLastErroredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErroredAt', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByLastErroredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErroredAt', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByResponseJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseJson', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      sortByResponseJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseJson', Sort.desc);
    });
  }
}

extension DeferredCredentialIsarQuerySortThenBy on QueryBuilder<
    DeferredCredentialIsar, DeferredCredentialIsar, QSortThenBy> {
  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByAccessTokenJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accessTokenJson', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByAccessTokenJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accessTokenJson', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByIssuerMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByIssuerMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByLastCheckedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByLastErroredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErroredAt', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByLastErroredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErroredAt', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByResponseJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseJson', Sort.asc);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QAfterSortBy>
      thenByResponseJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseJson', Sort.desc);
    });
  }
}

extension DeferredCredentialIsarQueryWhereDistinct
    on QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct> {
  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct>
      distinctByAccessTokenJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accessTokenJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct>
      distinctByIssuerMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuerMetadataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct>
      distinctByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCheckedAt');
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct>
      distinctByLastErroredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastErroredAt');
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct>
      distinctByRecordId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeferredCredentialIsar, DeferredCredentialIsar, QDistinct>
      distinctByResponseJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responseJson', caseSensitive: caseSensitive);
    });
  }
}

extension DeferredCredentialIsarQueryProperty on QueryBuilder<
    DeferredCredentialIsar, DeferredCredentialIsar, QQueryProperty> {
  QueryBuilder<DeferredCredentialIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DeferredCredentialIsar, String, QQueryOperations>
      accessTokenJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accessTokenJson');
    });
  }

  QueryBuilder<DeferredCredentialIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DeferredCredentialIsar, String, QQueryOperations>
      issuerMetadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuerMetadataJson');
    });
  }

  QueryBuilder<DeferredCredentialIsar, DateTime, QQueryOperations>
      lastCheckedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCheckedAt');
    });
  }

  QueryBuilder<DeferredCredentialIsar, DateTime?, QQueryOperations>
      lastErroredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastErroredAt');
    });
  }

  QueryBuilder<DeferredCredentialIsar, String, QQueryOperations>
      recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<DeferredCredentialIsar, String, QQueryOperations>
      responseJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responseJson');
    });
  }
}
