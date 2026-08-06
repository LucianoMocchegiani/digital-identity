// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CredentialResponseImpl _$$CredentialResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CredentialResponseImpl(
      credential: json['credential'] as String?,
      transactionId: json['transaction_id'] as String?,
      cNonce: json['c_nonce'] as String?,
      cNonceExpiresIn: (json['c_nonce_expires_in'] as num?)?.toInt(),
      notificationId: json['notification_id'] as String?,
    );

Map<String, dynamic> _$$CredentialResponseImplToJson(
        _$CredentialResponseImpl instance) =>
    <String, dynamic>{
      'credential': instance.credential,
      'transaction_id': instance.transactionId,
      'c_nonce': instance.cNonce,
      'c_nonce_expires_in': instance.cNonceExpiresIn,
      'notification_id': instance.notificationId,
    };
