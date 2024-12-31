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
      dominate_frequencies:
          (json['dominate_frequencies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toDouble()).toList()),
      ),
      anomaly_percentage:
          (json['anomaly_percentage'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      anomaly_regions: (json['anomaly_regions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => (e as List<dynamic>)
                    .map((e) => (e as num).toDouble())
                    .toList())
                .toList()),
      ),
      ticket: json['ticket'] as Map<String, dynamic>?,
      open_ticket: json['open_ticket'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SensorDataResponseToJson(SensorDataResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'result': instance.result,
      'frequency': instance.frequency,
      'magnitude': instance.magnitude,
      'dominate_frequencies': instance.dominate_frequencies,
      'anomaly_percentage': instance.anomaly_percentage,
      'anomaly_regions': instance.anomaly_regions,
      'ticket': instance.ticket,
      'open_ticket': instance.open_ticket,
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
