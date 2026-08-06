// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sd_jwt_vc_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSdJwtVcIsarCollection on Isar {
  IsarCollection<SdJwtVcIsar> get sdJwtVcIsars => this.collection();
}

const SdJwtVcIsarSchema = CollectionSchema(
  name: r'SdJwtVcIsar',
  id: -2709469737581460379,
  properties: {
    r'compactSdJwt': PropertySchema(
      id: 0,
      name: r'compactSdJwt',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'displayMetadataJson': PropertySchema(
      id: 2,
      name: r'displayMetadataJson',
      type: IsarType.string,
    ),
    r'issuerMetadataJson': PropertySchema(
      id: 3,
      name: r'issuerMetadataJson',
      type: IsarType.string,
    ),
    r'prettyClaimsJson': PropertySchema(
      id: 4,
      name: r'prettyClaimsJson',
      type: IsarType.string,
    ),
    r'recordId': PropertySchema(
      id: 5,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'vct': PropertySchema(
      id: 6,
      name: r'vct',
      type: IsarType.string,
    )
  },
  estimateSize: _sdJwtVcIsarEstimateSize,
  serialize: _sdJwtVcIsarSerialize,
  deserialize: _sdJwtVcIsarDeserialize,
  deserializeProp: _sdJwtVcIsarDeserializeProp,
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
  getId: _sdJwtVcIsarGetId,
  getLinks: _sdJwtVcIsarGetLinks,
  attach: _sdJwtVcIsarAttach,
  version: '3.1.0+1',
);

int _sdJwtVcIsarEstimateSize(
  SdJwtVcIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.compactSdJwt.length * 3;
  {
    final value = object.displayMetadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.issuerMetadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.prettyClaimsJson.length * 3;
  bytesCount += 3 + object.recordId.length * 3;
  bytesCount += 3 + object.vct.length * 3;
  return bytesCount;
}

void _sdJwtVcIsarSerialize(
  SdJwtVcIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.compactSdJwt);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.displayMetadataJson);
  writer.writeString(offsets[3], object.issuerMetadataJson);
  writer.writeString(offsets[4], object.prettyClaimsJson);
  writer.writeString(offsets[5], object.recordId);
  writer.writeString(offsets[6], object.vct);
}

SdJwtVcIsar _sdJwtVcIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SdJwtVcIsar();
  object.compactSdJwt = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.displayMetadataJson = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.issuerMetadataJson = reader.readStringOrNull(offsets[3]);
  object.prettyClaimsJson = reader.readString(offsets[4]);
  object.recordId = reader.readString(offsets[5]);
  object.vct = reader.readString(offsets[6]);
  return object;
}

P _sdJwtVcIsarDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sdJwtVcIsarGetId(SdJwtVcIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sdJwtVcIsarGetLinks(SdJwtVcIsar object) {
  return [];
}

void _sdJwtVcIsarAttach(
    IsarCollection<dynamic> col, Id id, SdJwtVcIsar object) {
  object.id = id;
}

extension SdJwtVcIsarByIndex on IsarCollection<SdJwtVcIsar> {
  Future<SdJwtVcIsar?> getByRecordId(String recordId) {
    return getByIndex(r'recordId', [recordId]);
  }

  SdJwtVcIsar? getByRecordIdSync(String recordId) {
    return getByIndexSync(r'recordId', [recordId]);
  }

  Future<bool> deleteByRecordId(String recordId) {
    return deleteByIndex(r'recordId', [recordId]);
  }

  bool deleteByRecordIdSync(String recordId) {
    return deleteByIndexSync(r'recordId', [recordId]);
  }

  Future<List<SdJwtVcIsar?>> getAllByRecordId(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordId', values);
  }

  List<SdJwtVcIsar?> getAllByRecordIdSync(List<String> recordIdValues) {
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

  Future<Id> putByRecordId(SdJwtVcIsar object) {
    return putByIndex(r'recordId', object);
  }

  Id putByRecordIdSync(SdJwtVcIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordId(List<SdJwtVcIsar> objects) {
    return putAllByIndex(r'recordId', objects);
  }

  List<Id> putAllByRecordIdSync(List<SdJwtVcIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordId', objects, saveLinks: saveLinks);
  }
}

extension SdJwtVcIsarQueryWhereSort
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QWhere> {
  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SdJwtVcIsarQueryWhere
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QWhereClause> {
  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhereClause> recordIdEqualTo(
      String recordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordId',
        value: [recordId],
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterWhereClause> recordIdNotEqualTo(
      String recordId) {
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

extension SdJwtVcIsarQueryFilter
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QFilterCondition> {
  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'compactSdJwt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'compactSdJwt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'compactSdJwt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'compactSdJwt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'compactSdJwt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'compactSdJwt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'compactSdJwt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'compactSdJwt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'compactSdJwt',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      compactSdJwtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'compactSdJwt',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      displayMetadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'displayMetadataJson',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      displayMetadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'displayMetadataJson',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      displayMetadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      displayMetadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayMetadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      displayMetadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      displayMetadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'issuerMetadataJson',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'issuerMetadataJson',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonEqualTo(
    String? value, {
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonGreaterThan(
    String? value, {
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonLessThan(
    String? value, {
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonStartsWith(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonEndsWith(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuerMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuerMetadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      issuerMetadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuerMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prettyClaimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prettyClaimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prettyClaimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prettyClaimsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prettyClaimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prettyClaimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prettyClaimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prettyClaimsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prettyClaimsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      prettyClaimsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prettyClaimsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> recordIdEqualTo(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> recordIdBetween(
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
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

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      recordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> recordIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vct',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vct',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vct',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vct',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vct',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vct',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vct',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition> vctIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vct',
        value: '',
      ));
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterFilterCondition>
      vctIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vct',
        value: '',
      ));
    });
  }
}

extension SdJwtVcIsarQueryObject
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QFilterCondition> {}

extension SdJwtVcIsarQueryLinks
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QFilterCondition> {}

extension SdJwtVcIsarQuerySortBy
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QSortBy> {
  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> sortByCompactSdJwt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compactSdJwt', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      sortByCompactSdJwtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compactSdJwt', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      sortByDisplayMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      sortByDisplayMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      sortByIssuerMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      sortByIssuerMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      sortByPrettyClaimsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prettyClaimsJson', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      sortByPrettyClaimsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prettyClaimsJson', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> sortByVct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vct', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> sortByVctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vct', Sort.desc);
    });
  }
}

extension SdJwtVcIsarQuerySortThenBy
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QSortThenBy> {
  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByCompactSdJwt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compactSdJwt', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      thenByCompactSdJwtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compactSdJwt', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      thenByDisplayMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      thenByDisplayMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      thenByIssuerMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      thenByIssuerMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      thenByPrettyClaimsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prettyClaimsJson', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy>
      thenByPrettyClaimsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prettyClaimsJson', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByVct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vct', Sort.asc);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QAfterSortBy> thenByVctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vct', Sort.desc);
    });
  }
}

extension SdJwtVcIsarQueryWhereDistinct
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct> {
  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct> distinctByCompactSdJwt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'compactSdJwt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct>
      distinctByDisplayMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayMetadataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct>
      distinctByIssuerMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuerMetadataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct> distinctByPrettyClaimsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prettyClaimsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct> distinctByRecordId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QDistinct> distinctByVct(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vct', caseSensitive: caseSensitive);
    });
  }
}

extension SdJwtVcIsarQueryProperty
    on QueryBuilder<SdJwtVcIsar, SdJwtVcIsar, QQueryProperty> {
  QueryBuilder<SdJwtVcIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SdJwtVcIsar, String, QQueryOperations> compactSdJwtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'compactSdJwt');
    });
  }

  QueryBuilder<SdJwtVcIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SdJwtVcIsar, String?, QQueryOperations>
      displayMetadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayMetadataJson');
    });
  }

  QueryBuilder<SdJwtVcIsar, String?, QQueryOperations>
      issuerMetadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuerMetadataJson');
    });
  }

  QueryBuilder<SdJwtVcIsar, String, QQueryOperations>
      prettyClaimsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prettyClaimsJson');
    });
  }

  QueryBuilder<SdJwtVcIsar, String, QQueryOperations> recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<SdJwtVcIsar, String, QQueryOperations> vctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vct');
    });
  }
}
