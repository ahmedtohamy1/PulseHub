// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sensor _$SensorFromJson(Map<String, dynamic> json) => Sensor(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$SensorToJson(Sensor instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'x': instance.x,
      'y': instance.y,
      'status': instance.status,
    };

ImageSensorPlacement _$ImageSensorPlacementFromJson(
        Map<String, dynamic> json) =>
    ImageSensorPlacement(
      imageUrl: json['imageUrl'] as String,
      sensors: (json['sensors'] as List<dynamic>)
          .map((e) => Sensor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ImageSensorPlacementToJson(
        ImageSensorPlacement instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'sensors': instance.sensors,
    };
