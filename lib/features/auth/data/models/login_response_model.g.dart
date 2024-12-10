// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      otpVerified: json['otp_verified'] as bool,
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'otp_verified': instance.otpVerified,
      'access': instance.access,
      'refresh': instance.refresh,
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: (json['user_id'] as num).toInt(),
      firstName: json['first_name'] as String,
      picture: json['picture'] as String,
      isStaff: json['is_staff'] as bool,
      isSuperuser: json['is_superuser'] as bool,
      pictureUrl: json['picture_url'] as String,
      mode: json['mode'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'first_name': instance.firstName,
      'picture': instance.picture,
      'is_staff': instance.isStaff,
      'is_superuser': instance.isSuperuser,
      'picture_url': instance.pictureUrl,
      'mode': instance.mode,
    };
