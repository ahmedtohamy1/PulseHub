// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoringResponse _$MonitoringResponseFromJson(Map<String, dynamic> json) =>
    MonitoringResponse(
      success: json['success'] as bool,
      monitorings: (json['Monitoring_list'] as List<dynamic>?)
          ?.map((e) => Monitoring.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MonitoringResponseToJson(MonitoringResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'Monitoring_list': instance.monitorings,
    };

Monitoring _$MonitoringFromJson(Map<String, dynamic> json) => Monitoring(
      monitoringId: (json['monitoring_id'] as num).toInt(),
      name: json['name'] as String,
      project: (json['project'] as num).toInt(),
      communications: json['communications'] as String?,
      usedSensors: (json['used_sensors'] as List<dynamic>?)
          ?.map((e) => UsedSensor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MonitoringToJson(Monitoring instance) =>
    <String, dynamic>{
      'monitoring_id': instance.monitoringId,
      'name': instance.name,
      'project': instance.project,
      'communications': instance.communications,
      'used_sensors': instance.usedSensors,
    };

UsedSensor _$UsedSensorFromJson(Map<String, dynamic> json) => UsedSensor(
      usedSensorId: (json['used_sensor_id'] as num).toInt(),
      monitoring: (json['monitoring'] as num).toInt(),
      name: json['name'] as String,
      function: json['function'] as String,
      count: (json['count'] as num).toInt(),
      sensors: (json['sensors'] as List<dynamic>?)
          ?.map((e) => Sensor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UsedSensorToJson(UsedSensor instance) =>
    <String, dynamic>{
      'used_sensor_id': instance.usedSensorId,
      'monitoring': instance.monitoring,
      'name': instance.name,
      'function': instance.function,
      'count': instance.count,
      'sensors': instance.sensors,
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
      event: json['event'] as String?,
      eventLastStatus: json['event_last_status'] as String?,
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
