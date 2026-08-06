// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spike_secret.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSpikeSecretCollection on Isar {
  IsarCollection<int, SpikeSecret> get spikeSecrets => this.collection();
}

const SpikeSecretSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SpikeSecret',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'secretId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'payload',
        type: IsarType.string,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'secretId',
        properties: [
          "secretId",
        ],
        unique: true,
        hash: true,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, SpikeSecret>(
    serialize: serializeSpikeSecret,
    deserialize: deserializeSpikeSecret,
    deserializeProperty: deserializeSpikeSecretProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeSpikeSecret(IsarWriter writer, SpikeSecret object) {
  IsarCore.writeString(writer, 1, object.secretId);
  IsarCore.writeString(writer, 2, object.payload);
  return object.id;
}

@isarProtected
SpikeSecret deserializeSpikeSecret(IsarReader reader) {
  final object = SpikeSecret();
  object.id = IsarCore.readId(reader);
  object.secretId = IsarCore.readString(reader, 1) ?? '';
  object.payload = IsarCore.readString(reader, 2) ?? '';
  return object;
}

@isarProtected
dynamic deserializeSpikeSecretProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _SpikeSecretUpdate {
  bool call({
    required int id,
    String? secretId,
    String? payload,
  });
}

class _SpikeSecretUpdateImpl implements _SpikeSecretUpdate {
  const _SpikeSecretUpdateImpl(this.collection);

  final IsarCollection<int, SpikeSecret> collection;

  @override
  bool call({
    required int id,
    Object? secretId = ignore,
    Object? payload = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (secretId != ignore) 1: secretId as String?,
          if (payload != ignore) 2: payload as String?,
        }) >
        0;
  }
}

sealed class _SpikeSecretUpdateAll {
  int call({
    required List<int> id,
    String? secretId,
    String? payload,
  });
}

class _SpikeSecretUpdateAllImpl implements _SpikeSecretUpdateAll {
  const _SpikeSecretUpdateAllImpl(this.collection);

  final IsarCollection<int, SpikeSecret> collection;

  @override
  int call({
    required List<int> id,
    Object? secretId = ignore,
    Object? payload = ignore,
  }) {
    return collection.updateProperties(id, {
      if (secretId != ignore) 1: secretId as String?,
      if (payload != ignore) 2: payload as String?,
    });
  }
}

extension SpikeSecretUpdate on IsarCollection<int, SpikeSecret> {
  _SpikeSecretUpdate get update => _SpikeSecretUpdateImpl(this);

  _SpikeSecretUpdateAll get updateAll => _SpikeSecretUpdateAllImpl(this);
}

sealed class _SpikeSecretQueryUpdate {
  int call({
    String? secretId,
    String? payload,
  });
}

class _SpikeSecretQueryUpdateImpl implements _SpikeSecretQueryUpdate {
  const _SpikeSecretQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<SpikeSecret> query;
  final int? limit;

  @override
  int call({
    Object? secretId = ignore,
    Object? payload = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (secretId != ignore) 1: secretId as String?,
      if (payload != ignore) 2: payload as String?,
    });
  }
}

extension SpikeSecretQueryUpdate on IsarQuery<SpikeSecret> {
  _SpikeSecretQueryUpdate get updateFirst =>
      _SpikeSecretQueryUpdateImpl(this, limit: 1);

  _SpikeSecretQueryUpdate get updateAll => _SpikeSecretQueryUpdateImpl(this);
}

class _SpikeSecretQueryBuilderUpdateImpl implements _SpikeSecretQueryUpdate {
  const _SpikeSecretQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<SpikeSecret, SpikeSecret, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? secretId = ignore,
    Object? payload = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (secretId != ignore) 1: secretId as String?,
        if (payload != ignore) 2: payload as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension SpikeSecretQueryBuilderUpdate
    on QueryBuilder<SpikeSecret, SpikeSecret, QOperations> {
  _SpikeSecretQueryUpdate get updateFirst =>
      _SpikeSecretQueryBuilderUpdateImpl(this, limit: 1);

  _SpikeSecretQueryUpdate get updateAll =>
      _SpikeSecretQueryBuilderUpdateImpl(this);
}

extension SpikeSecretQueryFilter
    on QueryBuilder<SpikeSecret, SpikeSecret, QFilterCondition> {
  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> secretIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> secretIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> secretIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      secretIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      payloadGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      payloadGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> payloadLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      payloadLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> payloadBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> payloadContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition> payloadMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }
}

extension SpikeSecretQueryObject
    on QueryBuilder<SpikeSecret, SpikeSecret, QFilterCondition> {}

extension SpikeSecretQuerySortBy
    on QueryBuilder<SpikeSecret, SpikeSecret, QSortBy> {
  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> sortBySecretId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> sortBySecretIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> sortByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> sortByPayloadDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension SpikeSecretQuerySortThenBy
    on QueryBuilder<SpikeSecret, SpikeSecret, QSortThenBy> {
  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> thenBySecretId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> thenBySecretIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> thenByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterSortBy> thenByPayloadDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension SpikeSecretQueryWhereDistinct
    on QueryBuilder<SpikeSecret, SpikeSecret, QDistinct> {
  QueryBuilder<SpikeSecret, SpikeSecret, QAfterDistinct> distinctBySecretId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpikeSecret, SpikeSecret, QAfterDistinct> distinctByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }
}

extension SpikeSecretQueryProperty1
    on QueryBuilder<SpikeSecret, SpikeSecret, QProperty> {
  QueryBuilder<SpikeSecret, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SpikeSecret, String, QAfterProperty> secretIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SpikeSecret, String, QAfterProperty> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension SpikeSecretQueryProperty2<R>
    on QueryBuilder<SpikeSecret, R, QAfterProperty> {
  QueryBuilder<SpikeSecret, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SpikeSecret, (R, String), QAfterProperty> secretIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SpikeSecret, (R, String), QAfterProperty> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension SpikeSecretQueryProperty3<R1, R2>
    on QueryBuilder<SpikeSecret, (R1, R2), QAfterProperty> {
  QueryBuilder<SpikeSecret, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SpikeSecret, (R1, R2, String), QOperations> secretIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SpikeSecret, (R1, R2, String), QOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}
