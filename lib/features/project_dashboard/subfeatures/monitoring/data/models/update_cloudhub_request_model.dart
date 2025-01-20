// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'update_cloudhub_request_model.g.dart';

@JsonSerializable()
class UpdateCloudhubRequestModel {
  @JsonKey(name: "monitoring")
  String? monitoring;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "notes")
  String? notes;
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "qr_code")
  String? qrCode;
  @JsonKey(name: "wifi_setup")
  String? wifiSetup;
  @JsonKey(name: "WIFI_SSID")
  String? wifiSsid;
  @JsonKey(name: "WIFI_PASSWORD")
  String? wifiPassword;
  @JsonKey(name: "Timedb_SERVER")
  String? timedbServer;
  @JsonKey(name: "Timedb_PORT")
  String? timedbPort;
  @JsonKey(name: "Timedb_USER")
  String? timedbUser;
  @JsonKey(name: "Timedb_PASS")
  String? timedbPass;
  @JsonKey(name: "Protocol")
  String? protocol;
  UpdateCloudhubRequestModel({
    this.monitoring,
    this.name,
    this.notes,
    this.code,
    this.qrCode,
    this.wifiSetup,
    this.wifiSsid,
    this.wifiPassword,
    this.timedbServer,
    this.timedbPort,
    this.timedbUser,
    this.timedbPass,
    this.protocol,
  });


  factory UpdateCloudhubRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateCloudhubRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCloudhubRequestModelToJson(this);
}
