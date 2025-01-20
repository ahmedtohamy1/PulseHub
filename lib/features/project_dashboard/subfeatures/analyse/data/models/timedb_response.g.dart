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
      fields: (json['fields'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Data.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'fields': instance.fields,
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
