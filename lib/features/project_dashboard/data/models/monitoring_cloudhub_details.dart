import 'package:json_annotation/json_annotation.dart';

part 'monitoring_cloudhub_details.g.dart';

@JsonSerializable()
class MonitoringCloudhubDetails {
  final bool success;
  final CloudHub cloudhub;

  MonitoringCloudhubDetails({
    required this.success,
    required this.cloudhub,
  });

  factory MonitoringCloudhubDetails.fromJson(Map<String, dynamic> json) =>
      _$MonitoringCloudhubDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringCloudhubDetailsToJson(this);
}

@JsonSerializable()
class CloudHub {
  @JsonKey(name: 'cloudhub_id')
  final int cloudhubId;
  final int monitoring;
  final String name;
  final String notes;
  final String code;
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @JsonKey(name: 'wifi_setup')
  final String wifiSetup;
  @JsonKey(name: 'WIFI_SSID')
  final String wifiSsid;
  @JsonKey(name: 'WIFI_PASSWORD')
  final String? wifiPassword;
  @JsonKey(name: 'Timedb_SERVER')
  final String? timedbServer;
  @JsonKey(name: 'Timedb_PORT')
  final String? timedbPort;
  @JsonKey(name: 'Timedb_USER')
  final String? timedbUser;
  @JsonKey(name: 'Timedb_PASS')
  final String? timedbPass;
  @JsonKey(name: 'Protocol')
  final String? protocol;
  @JsonKey(name: 'qr_code_url')
  final String? qrCodeUrl;
  final List<dynamic> sensors;

  CloudHub({
    required this.cloudhubId,
    required this.monitoring,
    required this.name,
    required this.notes,
    required this.code,
    this.qrCode,
    required this.wifiSetup,
    required this.wifiSsid,
    this.wifiPassword,
    this.timedbServer,
    this.timedbPort,
    this.timedbUser,
    this.timedbPass,
    this.protocol,
    this.qrCodeUrl,
    required this.sensors,
  });

  factory CloudHub.fromJson(Map<String, dynamic> json) =>
      _$CloudHubFromJson(json);

  Map<String, dynamic> toJson() => _$CloudHubToJson(this);
}
