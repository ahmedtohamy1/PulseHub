// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloudhub_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudHubResponse _$CloudHubResponseFromJson(Map<String, dynamic> json) =>
    CloudHubResponse(
      success: json['success'] as bool?,
      buckets: (json['buckets'] as List<dynamic>?)
          ?.map((e) => Bucket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CloudHubResponseToJson(CloudHubResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'buckets': instance.buckets,
    };

Bucket _$BucketFromJson(Map<String, dynamic> json) => Bucket(
      name: json['name'] as String?,
      measurements: (json['measurements'] as List<dynamic>?)
          ?.map((e) => Measurement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BucketToJson(Bucket instance) => <String, dynamic>{
      'name': instance.name,
      'measurements': instance.measurements,
    };

Measurement _$MeasurementFromJson(Map<String, dynamic> json) => Measurement(
      name: json['name'] as String?,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeasurementToJson(Measurement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'topics': instance.topics,
    };

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      name: json['name'] as String?,
      fields: (json['fields'] as List<dynamic>?)
          ?.map((e) => Field.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'name': instance.name,
      'fields': instance.fields,
    };

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
      name: json['name'] as String?,
    );

Map<String, dynamic> _$FieldToJson(Field instance) => <String, dynamic>{
      'name': instance.name,
    };
