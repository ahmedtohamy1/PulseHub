// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_users_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllResponseModel _$GetAllResponseModelFromJson(Map<String, dynamic> json) =>
    GetAllResponseModel(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String,
      previous: json['previous'],
      results: Results.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetAllResponseModelToJson(
        GetAllResponseModel instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

Results _$ResultsFromJson(Map<String, dynamic> json) => Results(
      success: json['success'] as bool,
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResultsToJson(Results instance) => <String, dynamic>{
      'success': instance.success,
      'users': instance.users,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: (json['user_id'] as num).toInt(),
      password: json['password'] as String,
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
      isSuperuser: json['is_superuser'] as bool,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      title: json['title'] as String,
      isActive: json['is_active'] as bool,
      isStaff: json['is_staff'] as bool,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      dateUpdated: DateTime.parse(json['date_updated'] as String),
      secretKey: json['secret_key'] as String,
      tempOtpToken: json['temp_otp_token'] as String,
      maxActiveSessions: (json['max_active_sessions'] as num).toInt(),
      ownersOrder: (json['owners_order'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      mode: json['mode'] as String,
      mfa: json['mfa'] as bool,
      pictureUrl: json['picture_url'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'password': instance.password,
      'last_login': instance.lastLogin?.toIso8601String(),
      'is_superuser': instance.isSuperuser,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'title': instance.title,
      'is_active': instance.isActive,
      'is_staff': instance.isStaff,
      'date_joined': instance.dateJoined.toIso8601String(),
      'date_updated': instance.dateUpdated.toIso8601String(),
      'secret_key': instance.secretKey,
      'temp_otp_token': instance.tempOtpToken,
      'max_active_sessions': instance.maxActiveSessions,
      'owners_order': instance.ownersOrder,
      'mode': instance.mode,
      'mfa': instance.mfa,
      'picture_url': instance.pictureUrl,
    };
