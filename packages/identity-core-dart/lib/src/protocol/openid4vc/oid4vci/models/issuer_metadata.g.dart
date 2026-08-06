// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issuer_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IssuerMetadataImpl _$$IssuerMetadataImplFromJson(Map<String, dynamic> json) =>
    _$IssuerMetadataImpl(
      credentialIssuer: json['credential_issuer'] as String,
      credentialEndpoint: json['credential_endpoint'] as String,
      tokenEndpoint: json['token_endpoint'] as String?,
      credentialConfigurationsSupported:
          json['credential_configurations_supported'] as Map<String, dynamic>,
      display: (json['display'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      authorizationServers: (json['authorization_servers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$IssuerMetadataImplToJson(
        _$IssuerMetadataImpl instance) =>
    <String, dynamic>{
      'credential_issuer': instance.credentialIssuer,
      'credential_endpoint': instance.credentialEndpoint,
      'token_endpoint': instance.tokenEndpoint,
      'credential_configurations_supported':
          instance.credentialConfigurationsSupported,
      'display': instance.display,
      'authorization_servers': instance.authorizationServers,
    };
