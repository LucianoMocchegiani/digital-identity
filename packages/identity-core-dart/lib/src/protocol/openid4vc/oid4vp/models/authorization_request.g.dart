// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthorizationRequestImpl _$$AuthorizationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthorizationRequestImpl(
      responseType: json['response_type'] as String,
      clientId: json['client_id'] as String,
      responseMode: json['response_mode'] as String?,
      responseUri: json['response_uri'] as String?,
      nonce: json['nonce'] as String?,
      state: json['state'] as String?,
      presentationDefinition:
          json['presentation_definition'] as Map<String, dynamic>?,
      presentationDefinitionUri: json['presentation_definition_uri'] as String?,
      dcqlQuery: json['dcql_query'] as Map<String, dynamic>?,
      clientMetadata: json['client_metadata'] as Map<String, dynamic>?,
      scope: json['scope'] as String?,
      authorizationEncryptedResponseAlg:
          json['authorization_encrypted_response_alg'] as String?,
      authorizationEncryptedResponseEnc:
          json['authorization_encrypted_response_enc'] as String?,
    );

Map<String, dynamic> _$$AuthorizationRequestImplToJson(
        _$AuthorizationRequestImpl instance) =>
    <String, dynamic>{
      'response_type': instance.responseType,
      'client_id': instance.clientId,
      'response_mode': instance.responseMode,
      'response_uri': instance.responseUri,
      'nonce': instance.nonce,
      'state': instance.state,
      'presentation_definition': instance.presentationDefinition,
      'presentation_definition_uri': instance.presentationDefinitionUri,
      'dcql_query': instance.dcqlQuery,
      'client_metadata': instance.clientMetadata,
      'scope': instance.scope,
      'authorization_encrypted_response_alg':
          instance.authorizationEncryptedResponseAlg,
      'authorization_encrypted_response_enc':
          instance.authorizationEncryptedResponseEnc,
    };
