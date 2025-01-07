import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/project_dashboard/data/models/ai_analyze_data_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_collaborators_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_medial_library_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_used_sensors_response_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_details.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/monitoring_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_update_request.dart';
import 'package:pulsehub/features/project_dashboard/data/models/sensor_activity_log_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/tickets_messages_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/timedb_response.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo_impl.dart';

abstract class DashRepository {
  Future<Either<String, ProjectDashboards>> getDashs(
      String token, int projectId);
  Future<Either<String, CloudHubResponse>> getDashDetails(
      String org, int projectId, String token);
  Future<Either<String, SensorDataResponse>> getTimeDb(
      String token, QueryParams queryParams);
  Future<Either<String, bool>> createDash(String token, String name,
      String description, String group, int projectId);
  Future<Either<String, MonitoringResponse>> getMonitoring(
      String token, int projectId);
  Future<Either<String, MonitoringCloudHubResponse>> getMonitoringCloudHub(
      String token);
  Future<Either<String, SensorDataResponse>> getSensorData(
      String token, int sensorId);
  Future<Either<String, MonitoringCloudhubDetails>> getCloudhubData(
      String token, int cloudhubId);
  Future<Either<String, AiAnalyzeDataModel>> analyzeSensorData(
      String token, QueryParams queryParams, String projectId);
  Future<Either<String, SensorActivityLog>> getSensorActivityLog(
      String token, int sensorId);
  Future<Either<String, TicketMessagesModel>> getTicketMessages(
      String token, int ticketId);
  Future<Either<String, bool>> createTicketMessage(
      String token, int ticketId, String message);
  Future<Either<String, bool>> updateProject(
      String token, int projectId, ProjectUpdateRequest request);
  Future<Either<String, bool>> deleteProject(String token, int projectId);
  Future<Either<String, GetUsedSensorsResponseModel>> getUsedSensors(
      String token);
  Future<Either<String, bool>> updateUsedSensors(
      String token, int usedSensorId, int count);
  Future<Either<String, bool>> deleteUsedSensors(
      String token, int usedSensorId);
  Future<Either<String, bool>> createUsedSensors(
      String token, int usedSensorTypeId, int count, int monitoringId);
  Future<Either<String, bool>> createMediaLibraryFile(
      String token,
      int projectId,
      String fileName,
      String fileDescription,
      PlatformFile file);
  Future<Either<String, GetMediaLibrariesResponseModel>> getMediaLibrary(
      String token, int projectId);
  Future<Either<String, bool>> deleteMediaLibrary(
      String token, int mediaLibraryId);
  Future<Either<String, GetCollaboratorsResponseModel>> getCollaborators(
      String token, int projectId);
  Future<Either<String, bool>> updateCollaborators(
      String token,
      int groupId,
      int projectId,
      String name,
      String description,
      bool isAnalyzer,
      bool isViewer,
      bool isEditor,
      bool isMonitor,
      bool isManager,
      bool isNotificationSender);
  Future<Either<String, bool>> deleteCollaborators(
      String token, int groupId);
}
