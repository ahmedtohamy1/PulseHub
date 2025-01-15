// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_sensor_types_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllSensorTypesResponseModel _$GetAllSensorTypesResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetAllSensorTypesResponseModel(
      success: json['success'] as bool,
      sensorTypeList: (json['SensorType_list'] as List<dynamic>)
          .map((e) => SensorTypeList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetAllSensorTypesResponseModelToJson(
        GetAllSensorTypesResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'SensorType_list': instance.sensorTypeList,
    };

SensorTypeList _$SensorTypeListFromJson(Map<String, dynamic> json) =>
    SensorTypeList(
      sensorTypeId: (json['sensor_type_id'] as num).toInt(),
      name: json['name'] as String,
      function: json['function'] as String,
    );

Map<String, dynamic> _$SensorTypeListToJson(SensorTypeList instance) =>
    <String, dynamic>{
      'sensor_type_id': instance.sensorTypeId,
      'name': instance.name,
      'function': instance.function,
    };
