// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'get_all_users_response_model.g.dart';

@JsonSerializable()
class GetAllResponseModel {
  @JsonKey(name: "success")
  bool? success;
  @JsonKey(name: "users")
  List<User>? users;

  GetAllResponseModel({
    this.success,
    this.users,
  });

  GetAllResponseModel copyWith({
    bool? success,
    List<User>? users,
  }) =>
      GetAllResponseModel(
        success: success ?? this.success,
        users: users ?? this.users,
      );

  factory GetAllResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetAllResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllResponseModelToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: "user_id")
  int? userId;
  @JsonKey(name: "password")
  Password? password;
  @JsonKey(name: "last_login")
  dynamic lastLogin;
  @JsonKey(name: "is_superuser")
  bool? isSuperuser;
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "first_name")
  String? firstName;
  @JsonKey(name: "last_name")
  String? lastName;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "picture")
  String? picture;
  @JsonKey(name: "is_active")
  bool? isActive;
  @JsonKey(name: "is_staff")
  bool? isStaff;
  @JsonKey(name: "date_joined")
  DateTime? dateJoined;
  @JsonKey(name: "date_updated")
  DateTime? dateUpdated;
  @JsonKey(name: "secret_key")
  SecretKey? secretKey;
  @JsonKey(name: "temp_otp_token")
  TempOtpToken? tempOtpToken;
  @JsonKey(name: "max_active_sessions")
  int? maxActiveSessions;
  @JsonKey(name: "owners_order")
  List<int>? ownersOrder;
  @JsonKey(name: "mode")
  Mode? mode;
  @JsonKey(name: "picture_url")
  String? pictureUrl;

  User({
    this.userId,
    this.password,
    this.lastLogin,
    this.isSuperuser,
    this.email,
    this.firstName,
    this.lastName,
    this.title,
    this.picture,
    this.isActive,
    this.isStaff,
    this.dateJoined,
    this.dateUpdated,
    this.secretKey,
    this.tempOtpToken,
    this.maxActiveSessions,
    this.ownersOrder,
    this.mode,
    this.pictureUrl,
  });

  User copyWith({
    int? userId,
    Password? password,
    dynamic lastLogin,
    bool? isSuperuser,
    String? email,
    String? firstName,
    String? lastName,
    String? title,
    String? picture,
    bool? isActive,
    bool? isStaff,
    DateTime? dateJoined,
    DateTime? dateUpdated,
    SecretKey? secretKey,
    TempOtpToken? tempOtpToken,
    int? maxActiveSessions,
    List<int>? ownersOrder,
    Mode? mode,
    String? pictureUrl,
  }) =>
      User(
        userId: userId ?? this.userId,
        password: password ?? this.password,
        lastLogin: lastLogin ?? this.lastLogin,
        isSuperuser: isSuperuser ?? this.isSuperuser,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        title: title ?? this.title,
        picture: picture ?? this.picture,
        isActive: isActive ?? this.isActive,
        isStaff: isStaff ?? this.isStaff,
        dateJoined: dateJoined ?? this.dateJoined,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        secretKey: secretKey ?? this.secretKey,
        tempOtpToken: tempOtpToken ?? this.tempOtpToken,
        maxActiveSessions: maxActiveSessions ?? this.maxActiveSessions,
        ownersOrder: ownersOrder ?? this.ownersOrder,
        mode: mode ?? this.mode,
        pictureUrl: pictureUrl ?? this.pictureUrl,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

enum Mode {
  @JsonValue("light")
  LIGHT
}

enum Password {
  @JsonValue("For Security Reasons You Can't View password")
  FOR_SECURITY_REASONS_YOU_CAN_T_VIEW_PASSWORD
}

enum SecretKey {
  @JsonValue("For Security Reasons You Can't View secret_key")
  FOR_SECURITY_REASONS_YOU_CAN_T_VIEW_SECRET_KEY
}

enum TempOtpToken {
  @JsonValue("For Security Reasons You Can't View temp_otp_token")
  FOR_SECURITY_REASONS_YOU_CAN_T_VIEW_TEMP_OTP_TOKEN
}
