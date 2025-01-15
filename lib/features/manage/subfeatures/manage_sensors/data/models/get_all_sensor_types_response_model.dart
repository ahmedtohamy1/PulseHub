import 'package:json_annotation/json_annotation.dart';

part 'get_all_sensor_types_response_model.g.dart';

@JsonSerializable()
class GetAllSensorTypesResponseModel {
  @JsonKey(name: "success")
  bool success;
  @JsonKey(name: "SensorType_list")
  List<SensorTypeList> sensorTypeList;

  GetAllSensorTypesResponseModel({
    required this.success,
    required this.sensorTypeList,
  });

  GetAllSensorTypesResponseModel copyWith({
    bool? success,
    List<SensorTypeList>? sensorTypeList,
  }) =>
      GetAllSensorTypesResponseModel(
        success: success ?? this.success,
        sensorTypeList: sensorTypeList ?? this.sensorTypeList,
      );

  factory GetAllSensorTypesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetAllSensorTypesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllSensorTypesResponseModelToJson(this);
}

@JsonSerializable()
class SensorTypeList {
  @JsonKey(name: "sensor_type_id")
  int sensorTypeId;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "function")
  String function;

  SensorTypeList({
    required this.sensorTypeId,
    required this.name,
    required this.function,
  });

  SensorTypeList copyWith({
    int? sensorTypeId,
    String? name,
    String? function,
  }) =>
      SensorTypeList(
        sensorTypeId: sensorTypeId ?? this.sensorTypeId,
        name: name ?? this.name,
        function: function ?? this.function,
      );

  factory SensorTypeList.fromJson(Map<String, dynamic> json) =>
      _$SensorTypeListFromJson(json);

  Map<String, dynamic> toJson() => _$SensorTypeListToJson(this);
}
