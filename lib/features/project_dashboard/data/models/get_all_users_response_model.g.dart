// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_users_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllResponseModel _$GetAllResponseModelFromJson(Map<String, dynamic> json) =>
    GetAllResponseModel(
      success: json['success'] as bool?,
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetAllResponseModelToJson(
        GetAllResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'users': instance.users,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: (json['user_id'] as num?)?.toInt(),
      password: $enumDecodeNullable(_$PasswordEnumMap, json['password']),
      lastLogin: json['last_login'],
      isSuperuser: json['is_superuser'] as bool?,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      title: json['title'] as String?,
      picture: json['picture'] as String?,
      isActive: json['is_active'] as bool?,
      isStaff: json['is_staff'] as bool?,
      dateJoined: json['date_joined'] == null
          ? null
          : DateTime.parse(json['date_joined'] as String),
      dateUpdated: json['date_updated'] == null
          ? null
          : DateTime.parse(json['date_updated'] as String),
      secretKey: $enumDecodeNullable(_$SecretKeyEnumMap, json['secret_key']),
      tempOtpToken:
          $enumDecodeNullable(_$TempOtpTokenEnumMap, json['temp_otp_token']),
      maxActiveSessions: (json['max_active_sessions'] as num?)?.toInt(),
      ownersOrder: (json['owners_order'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      mode: $enumDecodeNullable(_$ModeEnumMap, json['mode']),
      pictureUrl: json['picture_url'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'password': _$PasswordEnumMap[instance.password],
      'last_login': instance.lastLogin,
      'is_superuser': instance.isSuperuser,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'title': instance.title,
      'picture': instance.picture,
      'is_active': instance.isActive,
      'is_staff': instance.isStaff,
      'date_joined': instance.dateJoined?.toIso8601String(),
      'date_updated': instance.dateUpdated?.toIso8601String(),
      'secret_key': _$SecretKeyEnumMap[instance.secretKey],
      'temp_otp_token': _$TempOtpTokenEnumMap[instance.tempOtpToken],
      'max_active_sessions': instance.maxActiveSessions,
      'owners_order': instance.ownersOrder,
      'mode': _$ModeEnumMap[instance.mode],
      'picture_url': instance.pictureUrl,
    };

const _$PasswordEnumMap = {
  Password.FOR_SECURITY_REASONS_YOU_CAN_T_VIEW_PASSWORD:
      "For Security Reasons You Can't View password",
};

const _$SecretKeyEnumMap = {
  SecretKey.FOR_SECURITY_REASONS_YOU_CAN_T_VIEW_SECRET_KEY:
      "For Security Reasons You Can't View secret_key",
};

const _$TempOtpTokenEnumMap = {
  TempOtpToken.FOR_SECURITY_REASONS_YOU_CAN_T_VIEW_TEMP_OTP_TOKEN:
      "For Security Reasons You Can't View temp_otp_token",
};

const _$ModeEnumMap = {
  Mode.LIGHT: 'light',
};
