// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dcql_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DcqlQueryImpl _$$DcqlQueryImplFromJson(Map<String, dynamic> json) =>
    _$DcqlQueryImpl(
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => DcqlCredentialQuery.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DcqlQueryImplToJson(_$DcqlQueryImpl instance) =>
    <String, dynamic>{
      'credentials': instance.credentials,
    };

_$DcqlCredentialQueryImpl _$$DcqlCredentialQueryImplFromJson(
        Map<String, dynamic> json) =>
    _$DcqlCredentialQueryImpl(
      id: json['id'] as String,
      format: json['format'] as String,
      meta: json['meta'] as Map<String, dynamic>?,
      claims: (json['claims'] as List<dynamic>?)
          ?.map((e) => DcqlClaim.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DcqlCredentialQueryImplToJson(
        _$DcqlCredentialQueryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'format': instance.format,
      'meta': instance.meta,
      'claims': instance.claims,
    };

_$DcqlClaimImpl _$$DcqlClaimImplFromJson(Map<String, dynamic> json) =>
    _$DcqlClaimImpl(
      path: _dcqlPathFromJson(json['path']),
      namespace: json['namespace'] as String?,
      claimName: json['claim_name'] as String?,
      optional: json['optional'] as bool? ?? false,
    );

Map<String, dynamic> _$$DcqlClaimImplToJson(_$DcqlClaimImpl instance) =>
    <String, dynamic>{
      'path': _dcqlPathToJson(instance.path),
      'namespace': instance.namespace,
      'claim_name': instance.claimName,
      'optional': instance.optional,
    };
