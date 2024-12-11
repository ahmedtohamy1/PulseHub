import 'package:json_annotation/json_annotation.dart';
import 'package:pulsehub/features/auth/data/models/login_response_model.dart';

part 'otp_verify.g.dart';

@JsonSerializable(explicitToJson: true)
class OtpVerify {
  final bool success;
  final String message;
  @JsonKey(name: 'remember_me')
  final bool rememberMe;
  @JsonKey(name: 'remember_me_until')
  final String rememberMeUntil;
  final String access;
  final String refresh;
  final User user;

  OtpVerify({
    required this.success,
    required this.message,
    required this.rememberMe,
    required this.rememberMeUntil,
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory OtpVerify.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyToJson(this);
}
