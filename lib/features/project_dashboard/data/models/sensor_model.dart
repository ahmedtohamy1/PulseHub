import 'package:json_annotation/json_annotation.dart';

part 'sensor_model.g.dart';

@JsonSerializable()
class Sensor {
  final String id;
  final String name;
  final String type;
  final double x;
  final double y;
  final String status;

  Sensor({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.status,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);
  Map<String, dynamic> toJson() => _$SensorToJson(this);
}

@JsonSerializable()
class ImageSensorPlacement {
  final String imageUrl;
  final List<Sensor> sensors;

  ImageSensorPlacement({
    required this.imageUrl,
    required this.sensors,
  });

  factory ImageSensorPlacement.fromJson(Map<String, dynamic> json) =>
      _$ImageSensorPlacementFromJson(json);
  Map<String, dynamic> toJson() => _$ImageSensorPlacementToJson(this);
}
