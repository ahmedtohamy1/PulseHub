import 'package:json_annotation/json_annotation.dart';

part 'get_used_sensors_response_model.g.dart';

@JsonSerializable()
class GetUsedSensorsResponseModel {
  @JsonKey(name: "success")
  final bool? success;
  @JsonKey(name: "UsedSensor_list")
  final List<UsedSensorList>? usedSensorList;

  GetUsedSensorsResponseModel({
    this.success,
    this.usedSensorList,
  });

  GetUsedSensorsResponseModel copyWith({
    bool? success,
    List<UsedSensorList>? usedSensorList,
  }) =>
      GetUsedSensorsResponseModel(
        success: success ?? this.success,
        usedSensorList: usedSensorList ?? this.usedSensorList,
      );

  factory GetUsedSensorsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetUsedSensorsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetUsedSensorsResponseModelToJson(this);
}

@JsonSerializable()
class UsedSensorList {
  @JsonKey(name: "used_sensor_id")
  final int? usedSensorId;
  @JsonKey(name: "monitoring")
  final int? monitoring;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "function")
  final String? function;
  @JsonKey(name: "count")
  final int? count;

  UsedSensorList({
    this.usedSensorId,
    this.monitoring,
    this.name,
    this.function,
    this.count,
  });

  UsedSensorList copyWith({
    int? usedSensorId,
    int? monitoring,
    String? name,
    String? function,
    int? count,
  }) =>
      UsedSensorList(
        usedSensorId: usedSensorId ?? this.usedSensorId,
        monitoring: monitoring ?? this.monitoring,
        name: name ?? this.name,
        function: function ?? this.function,
        count: count ?? this.count,
      );

  factory UsedSensorList.fromJson(Map<String, dynamic> json) =>
      _$UsedSensorListFromJson(json);

  Map<String, dynamic> toJson() => _$UsedSensorListToJson(this);
}
