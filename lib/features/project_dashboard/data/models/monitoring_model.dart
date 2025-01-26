import 'package:json_annotation/json_annotation.dart';

part 'monitoring_model.g.dart';

@JsonSerializable()
class MonitoringResponseWrapper {
  final int count;
  final String? next;
  final String? previous;
  @JsonKey(name: "results")
  final MonitoringResponse results;

  MonitoringResponseWrapper({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory MonitoringResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$MonitoringResponseWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringResponseWrapperToJson(this);
}

@JsonSerializable()
class MonitoringResponse {
  final bool success;

  @JsonKey(name: 'Monitoring_list')
  final List<Monitoring> monitorings;

  MonitoringResponse({
    required this.success,
    required this.monitorings,
  });

  factory MonitoringResponse.fromJson(Map<String, dynamic> json) =>
      _$MonitoringResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringResponseToJson(this);
}

@JsonSerializable()
class Monitoring {
  @JsonKey(name: 'monitoring_id')
  final int monitoringId;

  final String name;
  final int project;

  final String? communications;

  @JsonKey(name: 'used_sensors')
  final List<UsedSensor>? usedSensors;

  Monitoring({
    required this.monitoringId,
    required this.name,
    required this.project,
    this.communications,
    this.usedSensors,
  });

  factory Monitoring.fromJson(Map<String, dynamic> json) =>
      _$MonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringToJson(this);
}

@JsonSerializable()
class UsedSensor {
  @JsonKey(name: 'used_sensor_id')
  final int usedSensorId;

  final int monitoring;
  final String name;
  final String function;
  final int count;

  final List<Sensor>? sensors;

  UsedSensor({
    required this.usedSensorId,
    required this.monitoring,
    required this.name,
    required this.function,
    required this.count,
    this.sensors,
  });

  factory UsedSensor.fromJson(Map<String, dynamic> json) =>
      _$UsedSensorFromJson(json);

  Map<String, dynamic> toJson() => _$UsedSensorToJson(this);
}

@JsonSerializable()
class Sensor {
  @JsonKey(name: 'sensor_id')
  final int sensorId;
  final String name;
  final String uuid;

  @JsonKey(name: 'used_sensor')
  final int usedSensor;

  @JsonKey(name: 'cloud_hub')
  final dynamic cloudHub;

  @JsonKey(name: 'install_date')
  final dynamic installDate;

  @JsonKey(name: 'type_id')
  final dynamic typeId;

  @JsonKey(name: 'data_source')
  final dynamic dataSource;

  @JsonKey(name: 'readings_per_day')
  final dynamic readingsPerDay;

  final bool active;

  @JsonKey(name: 'coordinate_x')
  final dynamic coordinateX;

  @JsonKey(name: 'coordinate_y')
  final dynamic coordinateY;

  @JsonKey(name: 'coordinate_z')
  final dynamic coordinateZ;

  final dynamic longitude;
  final dynamic latitude;

  final bool calibrated;

  @JsonKey(name: 'calibration_date')
  final dynamic calibrationDate;

  @JsonKey(name: 'calibration_comments')
  final dynamic calibrationComments;

  final String? event;

  @JsonKey(name: 'event_last_status')
  final String? eventLastStatus;

  final String status;

  @JsonKey(name: 'cloud_hub_time')
  final dynamic cloudHubTime;

  @JsonKey(name: 'SEND_TIME')
  final dynamic sendTime;

  Sensor({
    required this.sensorId,
    required this.name,
    required this.uuid,
    required this.usedSensor,
    this.cloudHub,
    this.installDate,
    this.typeId,
    this.dataSource,
    this.readingsPerDay,
    required this.active,
    this.coordinateX,
    this.coordinateY,
    this.coordinateZ,
    this.longitude,
    this.latitude,
    required this.calibrated,
    this.calibrationDate,
    this.calibrationComments,
    this.event,
    this.eventLastStatus,
    required this.status,
    this.cloudHubTime,
    this.sendTime,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);

  Map<String, dynamic> toJson() => _$SensorToJson(this);
}
