// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mdoc_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMdocIsarCollection on Isar {
  IsarCollection<MdocIsar> get mdocIsars => this.collection();
}

const MdocIsarSchema = CollectionSchema(
  name: r'MdocIsar',
  id: -2809569794257669244,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'displayMetadataJson': PropertySchema(
      id: 1,
      name: r'displayMetadataJson',
      type: IsarType.string,
    ),
    r'docType': PropertySchema(
      id: 2,
      name: r'docType',
      type: IsarType.string,
    ),
    r'issuerSignedBase64': PropertySchema(
      id: 3,
      name: r'issuerSignedBase64',
      type: IsarType.string,
    ),
    r'namespacesJson': PropertySchema(
      id: 4,
      name: r'namespacesJson',
      type: IsarType.string,
    ),
    r'recordId': PropertySchema(
      id: 5,
      name: r'recordId',
      type: IsarType.string,
    )
  },
  estimateSize: _mdocIsarEstimateSize,
  serialize: _mdocIsarSerialize,
  deserialize: _mdocIsarDeserialize,
  deserializeProp: _mdocIsarDeserializeProp,
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
  getId: _mdocIsarGetId,
  getLinks: _mdocIsarGetLinks,
  attach: _mdocIsarAttach,
  version: '3.1.0+1',
);

int _mdocIsarEstimateSize(
  MdocIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.displayMetadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.docType.length * 3;
  bytesCount += 3 + object.issuerSignedBase64.length * 3;
  bytesCount += 3 + object.namespacesJson.length * 3;
  bytesCount += 3 + object.recordId.length * 3;
  return bytesCount;
}

void _mdocIsarSerialize(
  MdocIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.displayMetadataJson);
  writer.writeString(offsets[2], object.docType);
  writer.writeString(offsets[3], object.issuerSignedBase64);
  writer.writeString(offsets[4], object.namespacesJson);
  writer.writeString(offsets[5], object.recordId);
}

MdocIsar _mdocIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MdocIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.displayMetadataJson = reader.readStringOrNull(offsets[1]);
  object.docType = reader.readString(offsets[2]);
  object.id = id;
  object.issuerSignedBase64 = reader.readString(offsets[3]);
  object.namespacesJson = reader.readString(offsets[4]);
  object.recordId = reader.readString(offsets[5]);
  return object;
}

P _mdocIsarDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mdocIsarGetId(MdocIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mdocIsarGetLinks(MdocIsar object) {
  return [];
}

void _mdocIsarAttach(IsarCollection<dynamic> col, Id id, MdocIsar object) {
  object.id = id;
}

extension MdocIsarByIndex on IsarCollection<MdocIsar> {
  Future<MdocIsar?> getByRecordId(String recordId) {
    return getByIndex(r'recordId', [recordId]);
  }

  MdocIsar? getByRecordIdSync(String recordId) {
    return getByIndexSync(r'recordId', [recordId]);
  }

  Future<bool> deleteByRecordId(String recordId) {
    return deleteByIndex(r'recordId', [recordId]);
  }

  bool deleteByRecordIdSync(String recordId) {
    return deleteByIndexSync(r'recordId', [recordId]);
  }

  Future<List<MdocIsar?>> getAllByRecordId(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordId', values);
  }

  List<MdocIsar?> getAllByRecordIdSync(List<String> recordIdValues) {
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

  Future<Id> putByRecordId(MdocIsar object) {
    return putByIndex(r'recordId', object);
  }

  Id putByRecordIdSync(MdocIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordId(List<MdocIsar> objects) {
    return putAllByIndex(r'recordId', objects);
  }

  List<Id> putAllByRecordIdSync(List<MdocIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordId', objects, saveLinks: saveLinks);
  }
}

extension MdocIsarQueryWhereSort on QueryBuilder<MdocIsar, MdocIsar, QWhere> {
  QueryBuilder<MdocIsar, MdocIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MdocIsarQueryWhere on QueryBuilder<MdocIsar, MdocIsar, QWhereClause> {
  QueryBuilder<MdocIsar, MdocIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterWhereClause> recordIdEqualTo(
      String recordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordId',
        value: [recordId],
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterWhereClause> recordIdNotEqualTo(
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

extension MdocIsarQueryFilter
    on QueryBuilder<MdocIsar, MdocIsar, QFilterCondition> {
  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      displayMetadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'displayMetadataJson',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      displayMetadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'displayMetadataJson',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      displayMetadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayMetadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      displayMetadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayMetadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      displayMetadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      displayMetadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayMetadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'docType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'docType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'docType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'docType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'docType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'docType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'docType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'docType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'docType',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> docTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'docType',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerSignedBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuerSignedBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuerSignedBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuerSignedBase64',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issuerSignedBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issuerSignedBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuerSignedBase64',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuerSignedBase64',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerSignedBase64',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      issuerSignedBase64IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuerSignedBase64',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> namespacesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namespacesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      namespacesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'namespacesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      namespacesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'namespacesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> namespacesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'namespacesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      namespacesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'namespacesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      namespacesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'namespacesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      namespacesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namespacesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> namespacesJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namespacesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      namespacesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namespacesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition>
      namespacesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namespacesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdEqualTo(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdGreaterThan(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdLessThan(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdBetween(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdStartsWith(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdEndsWith(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdMatches(
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

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterFilterCondition> recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }
}

extension MdocIsarQueryObject
    on QueryBuilder<MdocIsar, MdocIsar, QFilterCondition> {}

extension MdocIsarQueryLinks
    on QueryBuilder<MdocIsar, MdocIsar, QFilterCondition> {}

extension MdocIsarQuerySortBy on QueryBuilder<MdocIsar, MdocIsar, QSortBy> {
  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByDisplayMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy>
      sortByDisplayMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByDocType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByDocTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByIssuerSignedBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignedBase64', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy>
      sortByIssuerSignedBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignedBase64', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByNamespacesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namespacesJson', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByNamespacesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namespacesJson', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }
}

extension MdocIsarQuerySortThenBy
    on QueryBuilder<MdocIsar, MdocIsar, QSortThenBy> {
  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByDisplayMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy>
      thenByDisplayMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMetadataJson', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByDocType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByDocTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByIssuerSignedBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignedBase64', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy>
      thenByIssuerSignedBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignedBase64', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByNamespacesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namespacesJson', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByNamespacesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namespacesJson', Sort.desc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QAfterSortBy> thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }
}

extension MdocIsarQueryWhereDistinct
    on QueryBuilder<MdocIsar, MdocIsar, QDistinct> {
  QueryBuilder<MdocIsar, MdocIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QDistinct> distinctByDisplayMetadataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayMetadataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QDistinct> distinctByDocType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'docType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QDistinct> distinctByIssuerSignedBase64(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuerSignedBase64',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QDistinct> distinctByNamespacesJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namespacesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MdocIsar, MdocIsar, QDistinct> distinctByRecordId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }
}

extension MdocIsarQueryProperty
    on QueryBuilder<MdocIsar, MdocIsar, QQueryProperty> {
  QueryBuilder<MdocIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MdocIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MdocIsar, String?, QQueryOperations>
      displayMetadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayMetadataJson');
    });
  }

  QueryBuilder<MdocIsar, String, QQueryOperations> docTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'docType');
    });
  }

  QueryBuilder<MdocIsar, String, QQueryOperations>
      issuerSignedBase64Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuerSignedBase64');
    });
  }

  QueryBuilder<MdocIsar, String, QQueryOperations> namespacesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namespacesJson');
    });
  }

  QueryBuilder<MdocIsar, String, QQueryOperations> recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }
}
