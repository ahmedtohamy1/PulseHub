import 'package:json_annotation/json_annotation.dart';

part 'cloudhub_model.g.dart';

@JsonSerializable()
class CloudHubResponse {
  final bool? success;
  final List<Bucket>? buckets;

  CloudHubResponse({this.success, this.buckets});

  factory CloudHubResponse.fromJson(Map<String, dynamic> json) =>
      _$CloudHubResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CloudHubResponseToJson(this);
}

@JsonSerializable()
class Bucket {
  final String? name;
  final List<Measurement>? measurements;

  Bucket({this.name, this.measurements});

  factory Bucket.fromJson(Map<String, dynamic> json) => _$BucketFromJson(json);

  Map<String, dynamic> toJson() => _$BucketToJson(this);
}

@JsonSerializable()
class Measurement {
  final String? name;
  final List<Topic>? topics;

  Measurement({this.name, this.topics});

  factory Measurement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementToJson(this);
}

@JsonSerializable()
class Topic {
  final String? name;
  final List<Field>? fields;

  Topic({this.name, this.fields});

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

@JsonSerializable()
class Field {
  final String? name;

  Field({this.name});

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  Map<String, dynamic> toJson() => _$FieldToJson(this);
}
