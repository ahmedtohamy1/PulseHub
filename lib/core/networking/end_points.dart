class EndPoints {
  // base url
  static const String apiUrl = "$baseUrl/api";
  static const String baseUrl = "https://pulsehub.synology.me:9099";

  // Auth
  static const String login = "/user/login/";
  static const String logout = "/user/logout/";
  static const String sendPasswordResetCode = "/user/forget-password/";
  static const String verifyLoginOTP = "/user/verify-otp/";

  // User
  static const String activeSessions = "/user/active-sessions/";
  static const String userDetails = "/user/details/";

  // imgs
  static String imageUrl(String path) => '$baseUrl$path';
}
