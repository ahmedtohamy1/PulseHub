import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/env/env_config.dart';

class EndPoints {
  // base url
  static String get baseUrl => sl<EnvConfig>().baseUrl;
  static String get apiUrl => "$baseUrl/api";

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
  static const String updateProject = "/project/update/";
  static const String getUserProjects = "/user/projects/";

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
  static const String analyzeSensorDataQ2 = "/analysis/ai-q2/";
  static const String getSensorActivityLog = "/project/ticket/";
  static const String getTicketMessages = "/project/ticket-messages/";
  static const String createTicketMessage = "/project/ticket-messages/";
  static const String getUsedSensor = "/project/used-sensor/";
  static const String mediaLibrary = "/project/media-library/";
  static const String getCollaborators = "/project/groups/";
  static const String updateCollaborators = "/project/group/update/";
  static const String createCollaboratorsGroup = "/project/group/";
  static const String addUserToCollaboratorsGroup = "/user/groups/";
  static const String removeUserFromCollaboratorsGroup = "/user/groups-remove/";
  static const String getAllUsers = "/user/manage/";
  static const String markMessageAsSeen = "/project/message-seen/";
  static const String getUnseenMessages = "/project/unseen-messages/";
  static const String getNotifications = "/project/notifications/";
  static const String getAllOwners = "/owner/";
  static const String updateDeleteOwner = "/owner/update/";
  static const String getAllSensorTypes = "/utilities/sensor-type/";
  static const String getAllUserLog = "/user/log/";

  // imgs
  static String imageUrl(String path) => '$baseUrl$path';
}
