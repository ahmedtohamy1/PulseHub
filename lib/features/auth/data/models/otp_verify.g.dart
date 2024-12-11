// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerify _$OtpVerifyFromJson(Map<String, dynamic> json) => OtpVerify(
      success: json['success'] as bool,
      message: json['message'] as String,
      rememberMe: json['remember_me'] as bool,
      rememberMeUntil: json['remember_me_until'] as String,
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OtpVerifyToJson(OtpVerify instance) => <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'remember_me': instance.rememberMe,
      'remember_me_until': instance.rememberMeUntil,
      'access': instance.access,
      'refresh': instance.refresh,
      'user': instance.user.toJson(),
    };
