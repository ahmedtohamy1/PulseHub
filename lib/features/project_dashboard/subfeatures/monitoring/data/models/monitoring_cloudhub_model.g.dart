// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring_cloudhub_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoringCloudHubResponse _$MonitoringCloudHubResponseFromJson(
        Map<String, dynamic> json) =>
    MonitoringCloudHubResponse(
      success: json['success'] as bool,
      cloudhubs: (json['cloudhubs'] as List<dynamic>?)
          ?.map((e) => CloudHub.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MonitoringCloudHubResponseToJson(
        MonitoringCloudHubResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'cloudhubs': instance.cloudhubs,
    };

CloudHub _$CloudHubFromJson(Map<String, dynamic> json) => CloudHub(
      cloudhubId: (json['cloudhub_id'] as num).toInt(),
      monitoring: (json['monitoring'] as num).toInt(),
      name: json['name'] as String,
      notes: json['notes'] as String?,
      code: json['code'] as String?,
      qrCode: json['qr_code'],
      wifiSetup: json['wifi_setup'] as String?,
      wifiSsid: json['WIFI_SSID'] as String?,
      wifiPassword: json['WIFI_PASSWORD'],
      timedbServer: json['Timedb_SERVER'],
      timedbPort: json['Timedb_PORT'],
      timedbUser: json['Timedb_USER'],
      timedbPass: json['Timedb_PASS'],
      protocol: json['Protocol'],
      qrCodeUrl: json['qr_code_url'],
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
    };
