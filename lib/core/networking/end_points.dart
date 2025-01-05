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
  static const String getDics = "/user/dic-services/";
  static const String resetPassword = "/user/password-reset/";

  // Projects
  static const String getProjects = "/project/fetch-projects/";
  static const String getProject = "/project/";
  static const String flagProject = "/project/flag-project/";

  // Dashboards
  static const String getDashs = "/project/dashboards/";
  static const String aiQuestion = "/analysis/ai/";
  static const String getDashDetails = "/project/timedb-schema/";
  static const String timeDbData = "/project/timedb/";
  static const String createDash = "/project/dashboard/";
  static const String getMonitoring = "/project/monitoring/";
  static const String getMonitoringCloudHub = "/project/cloudhub/";
  static const String getSensorData = "/project/sensor/";
  static const String getCloudhubData = "/project/cloudhub/";
  static const String analyzeSensorData = "/analysis/ai-q1/";
  static const String getSensorActivityLog = "/project/ticket/";
  static const String getTicketMessages = "/project/ticket-messages/";
  static const String createTicketMessage = "/project/ticket-messages/";
  // imgs
  static String imageUrl(String path) => '$baseUrl$path';
}
