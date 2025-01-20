// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_used_sensors_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUsedSensorsResponseModel _$GetUsedSensorsResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetUsedSensorsResponseModel(
      success: json['success'] as bool?,
      usedSensorList: (json['UsedSensor_list'] as List<dynamic>?)
          ?.map((e) => UsedSensorList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetUsedSensorsResponseModelToJson(
        GetUsedSensorsResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'UsedSensor_list': instance.usedSensorList,
    };

UsedSensorList _$UsedSensorListFromJson(Map<String, dynamic> json) =>
    UsedSensorList(
      usedSensorId: (json['used_sensor_id'] as num?)?.toInt(),
      monitoring: (json['monitoring'] as num?)?.toInt(),
      name: json['name'] as String?,
      function: json['function'] as String?,
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UsedSensorListToJson(UsedSensorList instance) =>
    <String, dynamic>{
      'used_sensor_id': instance.usedSensorId,
      'monitoring': instance.monitoring,
      'name': instance.name,
      'function': instance.function,
      'count': instance.count,
    };
