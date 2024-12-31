import 'package:json_annotation/json_annotation.dart';

part 'timedb_response.g.dart';

@JsonSerializable()
class SensorDataResponse {
  final bool? success;
  final Result? result;
  final Map<String, List<double>>? frequency;
  final Map<String, List<double>>? magnitude;
  final Map<String, List<double>>? dominate_frequencies;
  final Map<String, double>? anomaly_percentage;
  final Map<String, List<List<double>>>? anomaly_regions;
  final Map<String, dynamic>? ticket;
  final Map<String, dynamic>? open_ticket;

  SensorDataResponse({
    this.success,
    this.result,
    this.frequency,
    this.magnitude,
    this.dominate_frequencies,
    this.anomaly_percentage,
    this.anomaly_regions,
    this.ticket,
    this.open_ticket,
  });

  factory SensorDataResponse.fromJson(Map<String, dynamic> json) =>
      _$SensorDataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SensorDataResponseToJson(this);
}

@JsonSerializable()
class Result {
  final Data? accelX;
  final Data? accelY;
  final Data? accelZ;
  final Data? humidity;
  final Data? temperature;

  Result({
    this.accelX,
    this.accelY,
    this.accelZ,
    this.humidity,
    this.temperature,
  });

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResultToJson(this);
}

@JsonSerializable()
class Data {
  final List<DateTime>? time;
  final List<double>? value;

  Data({this.time, this.value});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

// Custom serializer for DateTime
DateTime? _dateTimeFromJson(String? str) {
  if (str == null) return null;
  return DateTime.parse(str);
}

String? _dateTimeToJson(DateTime? dateTime) {
  if (dateTime == null) return null;
  return dateTime.toIso8601String();
}
