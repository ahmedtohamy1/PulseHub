// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timedb_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorDataResponse _$SensorDataResponseFromJson(Map<String, dynamic> json) =>
    SensorDataResponse(
      success: json['success'] as bool?,
      result: json['result'] == null
          ? null
          : Result.fromJson(json['result'] as Map<String, dynamic>),
      frequency: (json['frequency'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toDouble()).toList()),
      ),
      magnitude: (json['magnitude'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toDouble()).toList()),
      ),
      dominateFrequencies:
          (json['dominateFrequencies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toDouble()).toList()),
      ),
    );

Map<String, dynamic> _$SensorDataResponseToJson(SensorDataResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'result': instance.result,
      'frequency': instance.frequency,
      'magnitude': instance.magnitude,
      'dominateFrequencies': instance.dominateFrequencies,
    };

Result _$ResultFromJson(Map<String, dynamic> json) => Result(
      accelX: json['accelX'] == null
          ? null
          : Data.fromJson(json['accelX'] as Map<String, dynamic>),
      accelY: json['accelY'] == null
          ? null
          : Data.fromJson(json['accelY'] as Map<String, dynamic>),
      accelZ: json['accelZ'] == null
          ? null
          : Data.fromJson(json['accelZ'] as Map<String, dynamic>),
      humidity: json['humidity'] == null
          ? null
          : Data.fromJson(json['humidity'] as Map<String, dynamic>),
      temperature: json['temperature'] == null
          ? null
          : Data.fromJson(json['temperature'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'accelX': instance.accelX,
      'accelY': instance.accelY,
      'accelZ': instance.accelZ,
      'humidity': instance.humidity,
      'temperature': instance.temperature,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      time: (json['time'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
      value: (json['value'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'time': instance.time?.map((e) => e.toIso8601String()).toList(),
      'value': instance.value,
    };
