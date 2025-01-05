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
  final Map<String, Data> fields;

  Result({
    required this.fields,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    final fields = <String, Data>{};
    json.forEach((key, value) {
      if (value != null) {
        fields[key] = Data.fromJson(value as Map<String, dynamic>);
      }
    });
    return Result(fields: fields);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    fields.forEach((key, value) {
      json[key] = value.toJson();
    });
    return json;
  }

  // Helper method to get a field's data
  Data? getField(String fieldName) => fields[fieldName];

  // Helper method to get all available field names
  List<String> getFieldNames() => fields.keys.toList();
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
