class EndPoints {
  // base url
  static const String apiUrl = "$baseUrl/api";
  static const String baseUrl = "https://pulsehub.synology.me:9099";

  // Auth
  static const String login = "/user/login/";
  static const String logout = "/user/logout/";

  // imgs
  static String imageUrl(String path) => '$baseUrl$path';
}
