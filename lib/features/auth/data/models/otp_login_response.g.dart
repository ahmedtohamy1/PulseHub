// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OTPResponseModel _$OTPResponseModelFromJson(Map<String, dynamic> json) =>
    OTPResponseModel(
      otpVerified: json['otp_verified'] as bool,
      otpSuccess: json['otp_success'] as bool,
      otpMessage: json['otp_message'] as String,
      otpAccess: json['otp_access'] as String,
    );

Map<String, dynamic> _$OTPResponseModelToJson(OTPResponseModel instance) =>
    <String, dynamic>{
      'otp_verified': instance.otpVerified,
      'otp_success': instance.otpSuccess,
      'otp_message': instance.otpMessage,
      'otp_access': instance.otpAccess,
    };
