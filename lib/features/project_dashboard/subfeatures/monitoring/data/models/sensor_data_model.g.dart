// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorResponse _$SensorResponseFromJson(Map<String, dynamic> json) =>
    SensorResponse(
      success: json['success'] as bool,
      sensor: Sensor.fromJson(json['sensor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SensorResponseToJson(SensorResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'sensor': instance.sensor,
    };

Sensor _$SensorFromJson(Map<String, dynamic> json) => Sensor(
      sensorId: (json['sensor_id'] as num).toInt(),
      name: json['name'] as String,
      uuid: json['uuid'] as String,
      usedSensor: (json['used_sensor'] as num).toInt(),
      cloudHub: json['cloud_hub'],
      installDate: json['install_date'],
      typeId: json['type_id'],
      dataSource: json['data_source'],
      readingsPerDay: json['readings_per_day'],
      active: json['active'] as bool,
      coordinateX: json['coordinate_x'],
      coordinateY: json['coordinate_y'],
      coordinateZ: json['coordinate_z'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      calibrated: json['calibrated'] as bool,
      calibrationDate: json['calibration_date'],
      calibrationComments: json['calibration_comments'],
      event: json['event'] as String,
      eventLastStatus: json['event_last_status'] as String,
      status: json['status'] as String,
      cloudHubTime: json['cloud_hub_time'],
      sendTime: json['SEND_TIME'],
    );

Map<String, dynamic> _$SensorToJson(Sensor instance) => <String, dynamic>{
      'sensor_id': instance.sensorId,
      'name': instance.name,
      'uuid': instance.uuid,
      'used_sensor': instance.usedSensor,
      'cloud_hub': instance.cloudHub,
      'install_date': instance.installDate,
      'type_id': instance.typeId,
      'data_source': instance.dataSource,
      'readings_per_day': instance.readingsPerDay,
      'active': instance.active,
      'coordinate_x': instance.coordinateX,
      'coordinate_y': instance.coordinateY,
      'coordinate_z': instance.coordinateZ,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'calibrated': instance.calibrated,
      'calibration_date': instance.calibrationDate,
      'calibration_comments': instance.calibrationComments,
      'event': instance.event,
      'event_last_status': instance.eventLastStatus,
      'status': instance.status,
      'cloud_hub_time': instance.cloudHubTime,
      'SEND_TIME': instance.sendTime,
    };
