// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivityIsarCollection on Isar {
  IsarCollection<ActivityIsar> get activityIsars => this.collection();
}

const ActivityIsarSchema = CollectionSchema(
  name: r'ActivityIsar',
  id: 1146267803081734019,
  properties: {
    r'credentialIds': PropertySchema(
      id: 0,
      name: r'credentialIds',
      type: IsarType.stringList,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'entityHost': PropertySchema(
      id: 2,
      name: r'entityHost',
      type: IsarType.string,
    ),
    r'entityId': PropertySchema(
      id: 3,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityName': PropertySchema(
      id: 4,
      name: r'entityName',
      type: IsarType.string,
    ),
    r'presentedCredentialIds': PropertySchema(
      id: 5,
      name: r'presentedCredentialIds',
      type: IsarType.stringList,
    ),
    r'recordId': PropertySchema(
      id: 6,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'requestName': PropertySchema(
      id: 7,
      name: r'requestName',
      type: IsarType.string,
    ),
    r'requestPurpose': PropertySchema(
      id: 8,
      name: r'requestPurpose',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 10,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _activityIsarEstimateSize,
  serialize: _activityIsarSerialize,
  deserialize: _activityIsarDeserialize,
  deserializeProp: _activityIsarDeserializeProp,
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
  getId: _activityIsarGetId,
  getLinks: _activityIsarGetLinks,
  attach: _activityIsarAttach,
  version: '3.1.0+1',
);

int _activityIsarEstimateSize(
  ActivityIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.credentialIds;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.entityHost;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.entityId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.entityName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.presentedCredentialIds;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.recordId.length * 3;
  {
    final value = object.requestName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.requestPurpose;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _activityIsarSerialize(
  ActivityIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.credentialIds);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.entityHost);
  writer.writeString(offsets[3], object.entityId);
  writer.writeString(offsets[4], object.entityName);
  writer.writeStringList(offsets[5], object.presentedCredentialIds);
  writer.writeString(offsets[6], object.recordId);
  writer.writeString(offsets[7], object.requestName);
  writer.writeString(offsets[8], object.requestPurpose);
  writer.writeString(offsets[9], object.status);
  writer.writeString(offsets[10], object.type);
}

ActivityIsar _activityIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivityIsar();
  object.credentialIds = reader.readStringList(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.entityHost = reader.readStringOrNull(offsets[2]);
  object.entityId = reader.readStringOrNull(offsets[3]);
  object.entityName = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.presentedCredentialIds = reader.readStringList(offsets[5]);
  object.recordId = reader.readString(offsets[6]);
  object.requestName = reader.readStringOrNull(offsets[7]);
  object.requestPurpose = reader.readStringOrNull(offsets[8]);
  object.status = reader.readString(offsets[9]);
  object.type = reader.readString(offsets[10]);
  return object;
}

P _activityIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activityIsarGetId(ActivityIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activityIsarGetLinks(ActivityIsar object) {
  return [];
}

void _activityIsarAttach(
    IsarCollection<dynamic> col, Id id, ActivityIsar object) {
  object.id = id;
}

extension ActivityIsarByIndex on IsarCollection<ActivityIsar> {
  Future<ActivityIsar?> getByRecordId(String recordId) {
    return getByIndex(r'recordId', [recordId]);
  }

  ActivityIsar? getByRecordIdSync(String recordId) {
    return getByIndexSync(r'recordId', [recordId]);
  }

  Future<bool> deleteByRecordId(String recordId) {
    return deleteByIndex(r'recordId', [recordId]);
  }

  bool deleteByRecordIdSync(String recordId) {
    return deleteByIndexSync(r'recordId', [recordId]);
  }

  Future<List<ActivityIsar?>> getAllByRecordId(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordId', values);
  }

  List<ActivityIsar?> getAllByRecordIdSync(List<String> recordIdValues) {
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

  Future<Id> putByRecordId(ActivityIsar object) {
    return putByIndex(r'recordId', object);
  }

  Id putByRecordIdSync(ActivityIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordId(List<ActivityIsar> objects) {
    return putAllByIndex(r'recordId', objects);
  }

  List<Id> putAllByRecordIdSync(List<ActivityIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordId', objects, saveLinks: saveLinks);
  }
}

extension ActivityIsarQueryWhereSort
    on QueryBuilder<ActivityIsar, ActivityIsar, QWhere> {
  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ActivityIsarQueryWhere
    on QueryBuilder<ActivityIsar, ActivityIsar, QWhereClause> {
  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhereClause> recordIdEqualTo(
      String recordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordId',
        value: [recordId],
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterWhereClause>
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

extension ActivityIsarQueryFilter
    on QueryBuilder<ActivityIsar, ActivityIsar, QFilterCondition> {
  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'credentialIds',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'credentialIds',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credentialIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'credentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'credentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'credentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'credentialIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'credentialIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'credentialIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'credentialIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'credentialIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'credentialIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'credentialIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      credentialIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'credentialIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'entityHost',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'entityHost',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityHost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityHost',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityHost',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityHost',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityHostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityHost',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'entityId',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'entityId',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'entityName',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'entityName',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityName',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      entityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityName',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'presentedCredentialIds',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'presentedCredentialIds',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'presentedCredentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'presentedCredentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'presentedCredentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'presentedCredentialIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'presentedCredentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'presentedCredentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'presentedCredentialIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'presentedCredentialIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'presentedCredentialIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'presentedCredentialIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'presentedCredentialIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'presentedCredentialIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'presentedCredentialIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'presentedCredentialIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'presentedCredentialIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      presentedCredentialIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'presentedCredentialIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      recordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      recordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'requestName',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'requestName',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestName',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestName',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'requestPurpose',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'requestPurpose',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestPurpose',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestPurpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestPurpose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestPurpose',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      requestPurposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestPurpose',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension ActivityIsarQueryObject
    on QueryBuilder<ActivityIsar, ActivityIsar, QFilterCondition> {}

extension ActivityIsarQueryLinks
    on QueryBuilder<ActivityIsar, ActivityIsar, QFilterCondition> {}

extension ActivityIsarQuerySortBy
    on QueryBuilder<ActivityIsar, ActivityIsar, QSortBy> {
  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByEntityHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityHost', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      sortByEntityHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityHost', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      sortByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByRequestName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestName', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      sortByRequestNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestName', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      sortByRequestPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestPurpose', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      sortByRequestPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestPurpose', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ActivityIsarQuerySortThenBy
    on QueryBuilder<ActivityIsar, ActivityIsar, QSortThenBy> {
  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByEntityHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityHost', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      thenByEntityHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityHost', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      thenByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByRequestName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestName', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      thenByRequestNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestName', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      thenByRequestPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestPurpose', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy>
      thenByRequestPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestPurpose', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ActivityIsarQueryWhereDistinct
    on QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> {
  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct>
      distinctByCredentialIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credentialIds');
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByEntityHost(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityHost', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByEntityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByEntityName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct>
      distinctByPresentedCredentialIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'presentedCredentialIds');
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByRecordId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByRequestName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByRequestPurpose(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestPurpose',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityIsar, ActivityIsar, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension ActivityIsarQueryProperty
    on QueryBuilder<ActivityIsar, ActivityIsar, QQueryProperty> {
  QueryBuilder<ActivityIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivityIsar, List<String>?, QQueryOperations>
      credentialIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialIds');
    });
  }

  QueryBuilder<ActivityIsar, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<ActivityIsar, String?, QQueryOperations> entityHostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityHost');
    });
  }

  QueryBuilder<ActivityIsar, String?, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<ActivityIsar, String?, QQueryOperations> entityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityName');
    });
  }

  QueryBuilder<ActivityIsar, List<String>?, QQueryOperations>
      presentedCredentialIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'presentedCredentialIds');
    });
  }

  QueryBuilder<ActivityIsar, String, QQueryOperations> recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<ActivityIsar, String?, QQueryOperations> requestNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestName');
    });
  }

  QueryBuilder<ActivityIsar, String?, QQueryOperations>
      requestPurposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestPurpose');
    });
  }

  QueryBuilder<ActivityIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ActivityIsar, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
