// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CredentialOfferImpl _$$CredentialOfferImplFromJson(
        Map<String, dynamic> json) =>
    _$CredentialOfferImpl(
      credentialIssuer: json['credential_issuer'] as String,
      credentialConfigurationIds:
          (json['credential_configuration_ids'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      grants: json['grants'] == null
          ? null
          : GrantsContainer.fromJson(json['grants'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CredentialOfferImplToJson(
        _$CredentialOfferImpl instance) =>
    <String, dynamic>{
      'credential_issuer': instance.credentialIssuer,
      'credential_configuration_ids': instance.credentialConfigurationIds,
      'grants': instance.grants,
    };

_$GrantsContainerImpl _$$GrantsContainerImplFromJson(
        Map<String, dynamic> json) =>
    _$GrantsContainerImpl(
      preAuthorized:
          json['urn:ietf:params:oauth:grant-type:pre-authorized_code'] == null
              ? null
              : PreAuthorizedGrant.fromJson(
                  json['urn:ietf:params:oauth:grant-type:pre-authorized_code']
                      as Map<String, dynamic>),
      authCode: json['authorization_code'] == null
          ? null
          : AuthorizationCodeGrant.fromJson(
              json['authorization_code'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GrantsContainerImplToJson(
        _$GrantsContainerImpl instance) =>
    <String, dynamic>{
      'urn:ietf:params:oauth:grant-type:pre-authorized_code':
          instance.preAuthorized,
      'authorization_code': instance.authCode,
    };

_$PreAuthorizedGrantImpl _$$PreAuthorizedGrantImplFromJson(
        Map<String, dynamic> json) =>
    _$PreAuthorizedGrantImpl(
      preAuthorizedCode: json['pre-authorized_code'] as String,
      txCode: json['tx_code'] == null
          ? null
          : TxCodeInfo.fromJson(json['tx_code'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PreAuthorizedGrantImplToJson(
        _$PreAuthorizedGrantImpl instance) =>
    <String, dynamic>{
      'pre-authorized_code': instance.preAuthorizedCode,
      'tx_code': instance.txCode,
    };

_$TxCodeInfoImpl _$$TxCodeInfoImplFromJson(Map<String, dynamic> json) =>
    _$TxCodeInfoImpl(
      length: (json['length'] as num?)?.toInt(),
      inputMode: json['input_mode'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$TxCodeInfoImplToJson(_$TxCodeInfoImpl instance) =>
    <String, dynamic>{
      'length': instance.length,
      'input_mode': instance.inputMode,
      'description': instance.description,
    };

_$AuthorizationCodeGrantImpl _$$AuthorizationCodeGrantImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthorizationCodeGrantImpl(
      issuerState: json['issuer_state'] as String?,
      authorizationServer: json['authorization_server'] as String?,
    );

Map<String, dynamic> _$$AuthorizationCodeGrantImplToJson(
        _$AuthorizationCodeGrantImpl instance) =>
    <String, dynamic>{
      'issuer_state': instance.issuerState,
      'authorization_server': instance.authorizationServer,
    };
