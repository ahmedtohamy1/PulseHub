// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_cloudhub_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCloudhubRequestModel _$UpdateCloudhubRequestModelFromJson(
        Map<String, dynamic> json) =>
    UpdateCloudhubRequestModel(
      monitoring: json['monitoring'] as String?,
      name: json['name'] as String?,
      notes: json['notes'] as String?,
      code: json['code'] as String?,
      qrCode: json['qr_code'] as String?,
      wifiSetup: json['wifi_setup'] as String?,
      wifiSsid: json['WIFI_SSID'] as String?,
      wifiPassword: json['WIFI_PASSWORD'] as String?,
      timedbServer: json['Timedb_SERVER'] as String?,
      timedbPort: json['Timedb_PORT'] as String?,
      timedbUser: json['Timedb_USER'] as String?,
      timedbPass: json['Timedb_PASS'] as String?,
      protocol: json['Protocol'] as String?,
    );

Map<String, dynamic> _$UpdateCloudhubRequestModelToJson(
        UpdateCloudhubRequestModel instance) =>
    <String, dynamic>{
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
    };
