// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'didcomm_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DidCommMessageImpl _$$DidCommMessageImplFromJson(Map<String, dynamic> json) =>
    _$DidCommMessageImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      from: json['from'] as String?,
      to: (json['to'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdTime: (json['created_time'] as num?)?.toInt(),
      expiresTime: (json['expires_time'] as num?)?.toInt(),
      body: json['body'] as Map<String, dynamic>?,
      attachments: (json['~attach'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$$DidCommMessageImplToJson(
        _$DidCommMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'created_time': instance.createdTime,
      'expires_time': instance.expiresTime,
      'body': instance.body,
      '~attach': instance.attachments,
    };
