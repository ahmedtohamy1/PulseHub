// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'monitoring_model.g.dart';

@JsonSerializable()
class MonitoringResponse {
  final bool success;

  @JsonKey(name: 'Monitoring_list', includeIfNull: false)
  final List<Monitoring>? monitorings;

  MonitoringResponse({
    required this.success,
    this.monitorings,
  });

  // Custom factory method to handle both "Monitoring_list" and "Monitorings" keys
  factory MonitoringResponse.fromJson(Map<String, dynamic> json) {
    return MonitoringResponse(
      success: json['success'] as bool,
      monitorings: (json['Monitoring_list'] ?? json['Monitorings'])
          ?.map<Monitoring>((dynamic item) =>
              Monitoring.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

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

  Sensor copyWith({
    int? sensorId,
    String? name,
    String? uuid,
    int? usedSensor,
    dynamic? cloudHub,
    dynamic? installDate,
    dynamic? typeId,
    dynamic? dataSource,
    dynamic? readingsPerDay,
    bool? active,
    dynamic? coordinateX,
    dynamic? coordinateY,
    dynamic? coordinateZ,
    dynamic? longitude,
    dynamic? latitude,
    bool? calibrated,
    dynamic? calibrationDate,
    dynamic? calibrationComments,
    String? event,
    String? eventLastStatus,
    String? status,
    dynamic? cloudHubTime,
    dynamic? sendTime,
  }) {
    return Sensor(
      sensorId: sensorId ?? this.sensorId,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
      usedSensor: usedSensor ?? this.usedSensor,
      cloudHub: cloudHub ?? this.cloudHub,
      installDate: installDate ?? this.installDate,
      typeId: typeId ?? this.typeId,
      dataSource: dataSource ?? this.dataSource,
      readingsPerDay: readingsPerDay ?? this.readingsPerDay,
      active: active ?? this.active,
      coordinateX: coordinateX ?? this.coordinateX,
      coordinateY: coordinateY ?? this.coordinateY,
      coordinateZ: coordinateZ ?? this.coordinateZ,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      calibrated: calibrated ?? this.calibrated,
      calibrationDate: calibrationDate ?? this.calibrationDate,
      calibrationComments: calibrationComments ?? this.calibrationComments,
      event: event ?? this.event,
      eventLastStatus: eventLastStatus ?? this.eventLastStatus,
      status: status ?? this.status,
      cloudHubTime: cloudHubTime ?? this.cloudHubTime,
      sendTime: sendTime ?? this.sendTime,
    );
  }
}
