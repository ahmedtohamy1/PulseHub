import 'package:json_annotation/json_annotation.dart';

part 'otp_login_response.g.dart';

@JsonSerializable()
class OTPResponseModel {
  @JsonKey(name: 'otp_verified')
  final bool otpVerified;
  @JsonKey(name: 'otp_success')
  final bool otpSuccess;
  @JsonKey(name: 'otp_message')
  final String otpMessage;
  @JsonKey(name: 'otp_access')
  final String otpAccess;

  OTPResponseModel({
    required this.otpVerified,
    required this.otpSuccess,
    required this.otpMessage,
    required this.otpAccess,
  });

  factory OTPResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OTPResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OTPResponseModelToJson(this);
}
