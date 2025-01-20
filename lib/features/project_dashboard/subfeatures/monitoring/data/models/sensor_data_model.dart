import 'package:json_annotation/json_annotation.dart';

part 'sensor_data_model.g.dart';

@JsonSerializable()
class SensorResponse {
  final bool success;
  final Sensor sensor;

  SensorResponse({required this.success, required this.sensor});

  factory SensorResponse.fromJson(Map<String, dynamic> json) =>
      _$SensorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SensorResponseToJson(this);
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
  final dynamic cloudHub; // Use dynamic for nullable fields
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
  final String event;
  @JsonKey(name: 'event_last_status')
  final String eventLastStatus;
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
    required this.event,
    required this.eventLastStatus,
    required this.status,
    this.cloudHubTime,
    this.sendTime,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);

  Map<String, dynamic> toJson() => _$SensorToJson(this);
}
