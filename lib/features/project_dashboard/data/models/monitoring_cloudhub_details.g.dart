// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring_cloudhub_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoringCloudhubDetails _$MonitoringCloudhubDetailsFromJson(
        Map<String, dynamic> json) =>
    MonitoringCloudhubDetails(
      success: json['success'] as bool,
      cloudhub: CloudHub.fromJson(json['cloudhub'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MonitoringCloudhubDetailsToJson(
        MonitoringCloudhubDetails instance) =>
    <String, dynamic>{
      'success': instance.success,
      'cloudhub': instance.cloudhub,
    };

CloudHub _$CloudHubFromJson(Map<String, dynamic> json) => CloudHub(
      cloudhubId: (json['cloudhub_id'] as num).toInt(),
      monitoring: (json['monitoring'] as num).toInt(),
      name: json['name'] as String,
      notes: json['notes'] as String,
      code: json['code'] as String,
      qrCode: json['qr_code'] as String?,
      wifiSetup: json['wifi_setup'] as String,
      wifiSsid: json['WIFI_SSID'] as String,
      wifiPassword: json['WIFI_PASSWORD'] as String?,
      timedbServer: json['Timedb_SERVER'] as String?,
      timedbPort: json['Timedb_PORT'] as String?,
      timedbUser: json['Timedb_USER'] as String?,
      timedbPass: json['Timedb_PASS'] as String?,
      protocol: json['Protocol'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?,
      sensors: json['sensors'] as List<dynamic>,
    );

Map<String, dynamic> _$CloudHubToJson(CloudHub instance) => <String, dynamic>{
      'cloudhub_id': instance.cloudhubId,
      'monitoring': instance.monitoring,
      'name': instance.name,
      'notes': instance.notes,
      'code': instance.code,
      'qr_code': instance.qrCode,
      'wifi_setup': instance.wifiSetup,
      'WIFI_SSID': instance.wifiSsid,
      'WIFI_PASSWORD': instance.wifiPassword,
      'Timedb_SERVER': instance.timedbServer,
      'Timedb_PORT': instance.timedbPort,
      'Timedb_USER': instance.timedbUser,
      'Timedb_PASS': instance.timedbPass,
      'Protocol': instance.protocol,
      'qr_code_url': instance.qrCodeUrl,
      'sensors': instance.sensors,
    };
