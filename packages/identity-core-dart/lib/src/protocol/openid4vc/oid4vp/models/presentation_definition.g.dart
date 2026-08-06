// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresentationDefinitionImpl _$$PresentationDefinitionImplFromJson(
        Map<String, dynamic> json) =>
    _$PresentationDefinitionImpl(
      id: json['id'] as String,
      inputDescriptors: (json['input_descriptors'] as List<dynamic>)
          .map((e) => InputDescriptor.fromJson(e as Map<String, dynamic>))
          .toList(),
      submissionRequirements:
          (json['submission_requirements'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
      name: json['name'] as String?,
      purpose: json['purpose'] as String?,
    );

Map<String, dynamic> _$$PresentationDefinitionImplToJson(
        _$PresentationDefinitionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'input_descriptors': instance.inputDescriptors,
      'submission_requirements': instance.submissionRequirements,
      'name': instance.name,
      'purpose': instance.purpose,
    };

_$InputDescriptorImpl _$$InputDescriptorImplFromJson(
        Map<String, dynamic> json) =>
    _$InputDescriptorImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      purpose: json['purpose'] as String?,
      constraints: json['constraints'] as Map<String, dynamic>,
      format: json['format'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$InputDescriptorImplToJson(
        _$InputDescriptorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'purpose': instance.purpose,
      'constraints': instance.constraints,
      'format': instance.format,
    };
