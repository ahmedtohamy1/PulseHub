import 'package:json_annotation/json_annotation.dart';

part 'monitoring_cloudhub_model.g.dart';

@JsonSerializable()
class MonitoringCloudHubResponse {
  final bool success;
  final List<CloudHub>? cloudhubs;

  MonitoringCloudHubResponse({
    required this.success,
    this.cloudhubs,
  });

  factory MonitoringCloudHubResponse.fromJson(Map<String, dynamic> json) =>
      _$MonitoringCloudHubResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringCloudHubResponseToJson(this);
}

@JsonSerializable()
class CloudHub {
  @JsonKey(name: 'cloudhub_id')
  final int cloudhubId;

  final int monitoring;
  final String name;
  final String? notes;
  final String? code;

  @JsonKey(name: 'qr_code')
  final dynamic qrCode;

  @JsonKey(name: 'wifi_setup')
  final String? wifiSetup;

  @JsonKey(name: 'WIFI_SSID')
  final String? wifiSsid;

  @JsonKey(name: 'WIFI_PASSWORD')
  final dynamic wifiPassword;

  @JsonKey(name: 'Timedb_SERVER')
  final dynamic timedbServer;

  @JsonKey(name: 'Timedb_PORT')
  final dynamic timedbPort;

  @JsonKey(name: 'Timedb_USER')
  final dynamic timedbUser;

  @JsonKey(name: 'Timedb_PASS')
  final dynamic timedbPass;

  @JsonKey(name: 'Protocol')
  final dynamic protocol;

  @JsonKey(name: 'qr_code_url')
  final dynamic qrCodeUrl;

  CloudHub({
    required this.cloudhubId,
    required this.monitoring,
    required this.name,
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
    this.qrCodeUrl,
  });

  factory CloudHub.fromJson(Map<String, dynamic> json) =>
      _$CloudHubFromJson(json);

  Map<String, dynamic> toJson() => _$CloudHubToJson(this);
}
