// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetails _$UserDetailsFromJson(Map<String, dynamic> json) => UserDetails(
      userId: (json['user_id'] as num).toInt(),
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      title: json['title'] as String,
      picture: json['picture'] as String,
      isStaff: json['is_staff'] as bool,
      isSuperuser: json['is_superuser'] as bool,
      isActive: json['is_active'] as bool,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      pictureUrl: json['picture_url'] as String,
      mode: json['mode'] as String,
    );

Map<String, dynamic> _$UserDetailsToJson(UserDetails instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'title': instance.title,
      'picture': instance.picture,
      'is_staff': instance.isStaff,
      'is_superuser': instance.isSuperuser,
      'is_active': instance.isActive,
      'date_joined': instance.dateJoined.toIso8601String(),
      'picture_url': instance.pictureUrl,
      'mode': instance.mode,
    };
