import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  @JsonKey(name: 'otp_verified')
  final bool otpVerified;
  final String access;
  final String refresh;
  final User user;

  LoginResponseModel({
    required this.otpVerified,
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'first_name')
  final String firstName;
  final String picture;
  @JsonKey(name: 'is_staff')
  final bool isStaff;
  @JsonKey(name: 'is_superuser')
  final bool isSuperuser;
  @JsonKey(name: 'picture_url')
  final String pictureUrl;
  final String mode;

  User({
    required this.userId,
    required this.firstName,
    required this.picture,
    required this.isStaff,
    required this.isSuperuser,
    required this.pictureUrl,
    required this.mode,
  });

  /// Factory constructor for creating a new instance from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Method for converting the instance to a JSON map.
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
