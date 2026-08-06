// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'did_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDidIsarCollection on Isar {
  IsarCollection<DidIsar> get didIsars => this.collection();
}

const DidIsarSchema = CollectionSchema(
  name: r'DidIsar',
  id: 166136803436256116,
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
    r'documentJson': PropertySchema(
      id: 2,
      name: r'documentJson',
      type: IsarType.string,
    ),
    r'keyIds': PropertySchema(
      id: 3,
      name: r'keyIds',
      type: IsarType.stringList,
    ),
    r'method': PropertySchema(
      id: 4,
      name: r'method',
      type: IsarType.string,
    )
  },
  estimateSize: _didIsarEstimateSize,
  serialize: _didIsarSerialize,
  deserialize: _didIsarDeserialize,
  deserializeProp: _didIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'did': IndexSchema(
      id: -4238199618338197262,
      name: r'did',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'did',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _didIsarGetId,
  getLinks: _didIsarGetLinks,
  attach: _didIsarAttach,
  version: '3.1.0+1',
);

int _didIsarEstimateSize(
  DidIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.did.length * 3;
  bytesCount += 3 + object.documentJson.length * 3;
  bytesCount += 3 + object.keyIds.length * 3;
  {
    for (var i = 0; i < object.keyIds.length; i++) {
      final value = object.keyIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.method.length * 3;
  return bytesCount;
}

void _didIsarSerialize(
  DidIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.did);
  writer.writeString(offsets[2], object.documentJson);
  writer.writeStringList(offsets[3], object.keyIds);
  writer.writeString(offsets[4], object.method);
}

DidIsar _didIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DidIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.did = reader.readString(offsets[1]);
  object.documentJson = reader.readString(offsets[2]);
  object.id = id;
  object.keyIds = reader.readStringList(offsets[3]) ?? [];
  object.method = reader.readString(offsets[4]);
  return object;
}

P _didIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _didIsarGetId(DidIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _didIsarGetLinks(DidIsar object) {
  return [];
}

void _didIsarAttach(IsarCollection<dynamic> col, Id id, DidIsar object) {
  object.id = id;
}

extension DidIsarByIndex on IsarCollection<DidIsar> {
  Future<DidIsar?> getByDid(String did) {
    return getByIndex(r'did', [did]);
  }

  DidIsar? getByDidSync(String did) {
    return getByIndexSync(r'did', [did]);
  }

  Future<bool> deleteByDid(String did) {
    return deleteByIndex(r'did', [did]);
  }

  bool deleteByDidSync(String did) {
    return deleteByIndexSync(r'did', [did]);
  }

  Future<List<DidIsar?>> getAllByDid(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return getAllByIndex(r'did', values);
  }

  List<DidIsar?> getAllByDidSync(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'did', values);
  }

  Future<int> deleteAllByDid(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'did', values);
  }

  int deleteAllByDidSync(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'did', values);
  }

  Future<Id> putByDid(DidIsar object) {
    return putByIndex(r'did', object);
  }

  Id putByDidSync(DidIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'did', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDid(List<DidIsar> objects) {
    return putAllByIndex(r'did', objects);
  }

  List<Id> putAllByDidSync(List<DidIsar> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'did', objects, saveLinks: saveLinks);
  }
}

extension DidIsarQueryWhereSort on QueryBuilder<DidIsar, DidIsar, QWhere> {
  QueryBuilder<DidIsar, DidIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DidIsarQueryWhere on QueryBuilder<DidIsar, DidIsar, QWhereClause> {
  QueryBuilder<DidIsar, DidIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DidIsar, DidIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<DidIsar, DidIsar, QAfterWhereClause> didEqualTo(String did) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'did',
        value: [did],
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterWhereClause> didNotEqualTo(String did) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [],
              upper: [did],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [did],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [did],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [],
              upper: [did],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DidIsarQueryFilter
    on QueryBuilder<DidIsar, DidIsar, QFilterCondition> {
  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didEqualTo(
    String value, {
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didGreaterThan(
    String value, {
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didLessThan(
    String value, {
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didBetween(
    String lower,
    String upper, {
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didStartsWith(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didEndsWith(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didContains(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didMatches(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> didIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> documentJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition>
      documentJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition>
      keyIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keyIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keyIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keyIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keyIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyIds',
        value: '',
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition>
      keyIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keyIds',
        value: '',
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> keyIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'method',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'method',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'method',
        value: '',
      ));
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterFilterCondition> methodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'method',
        value: '',
      ));
    });
  }
}

extension DidIsarQueryObject
    on QueryBuilder<DidIsar, DidIsar, QFilterCondition> {}

extension DidIsarQueryLinks
    on QueryBuilder<DidIsar, DidIsar, QFilterCondition> {}

extension DidIsarQuerySortBy on QueryBuilder<DidIsar, DidIsar, QSortBy> {
  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByDocumentJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentJson', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByDocumentJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentJson', Sort.desc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> sortByMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.desc);
    });
  }
}

extension DidIsarQuerySortThenBy
    on QueryBuilder<DidIsar, DidIsar, QSortThenBy> {
  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByDocumentJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentJson', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByDocumentJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentJson', Sort.desc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.asc);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QAfterSortBy> thenByMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.desc);
    });
  }
}

extension DidIsarQueryWhereDistinct
    on QueryBuilder<DidIsar, DidIsar, QDistinct> {
  QueryBuilder<DidIsar, DidIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DidIsar, DidIsar, QDistinct> distinctByDid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'did', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QDistinct> distinctByDocumentJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DidIsar, DidIsar, QDistinct> distinctByKeyIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyIds');
    });
  }

  QueryBuilder<DidIsar, DidIsar, QDistinct> distinctByMethod(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'method', caseSensitive: caseSensitive);
    });
  }
}

extension DidIsarQueryProperty
    on QueryBuilder<DidIsar, DidIsar, QQueryProperty> {
  QueryBuilder<DidIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DidIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DidIsar, String, QQueryOperations> didProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'did');
    });
  }

  QueryBuilder<DidIsar, String, QQueryOperations> documentJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentJson');
    });
  }

  QueryBuilder<DidIsar, List<String>, QQueryOperations> keyIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyIds');
    });
  }

  QueryBuilder<DidIsar, String, QQueryOperations> methodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'method');
    });
  }
}
