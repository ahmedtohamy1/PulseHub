import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/project_dashboard/data/models/ai_analyze_data_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/cloudhub_model.dart';
import 'package:pulsehub/features/project_dashboard/data/models/get_all_users_response_model.dart';
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
import 'package:pulsehub/features/project_dashboard/data/models/update_cloudhub_request_model.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo.dart';

@LazySingleton(as: DashRepository)
class DashRepoImpl extends DashRepository {
  final MyApi myApiService;

  DashRepoImpl(this.myApiService);
  @override
  Future<Either<String, ProjectDashboards>> getDashs(
      String token, int projectId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getDashs,
        token: token,
        queryParameters: {'project_id': projectId},
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        final json = response.data;

        return Right(ProjectDashboards.fromJson(json));
      } else {
        return Left('Failed to get Dashs: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> deleteDash(
      String token, int dashId) async {
    try {
      final response = await myApiService.delete(
        EndPoints.createDash,
        token: token,
        queryParameters: {'dashboard_id': dashId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to delete dash: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, CloudHubResponse>> getDashDetails(
      String org, int projectId, String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getDashDetails,
        token: token,
        queryParameters: {'project_id': projectId, 'org': org},
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        final json = response.data;

        return Right(CloudHubResponse.fromJson(json));
      } else {
        return Left('Failed to get Dashs: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, SensorDataResponse>> getTimeDb(
      String token, QueryParams queryParams) async {
    try {
      final response = await myApiService.get(
        EndPoints.timeDbData,
        token: token,
        queryParameters: queryParams.toJson(),
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        final json = response.data;

        return Right(SensorDataResponse.fromJson(json));
      } else {
        return Left('Failed to get Dashs: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> createDash(String token, String name,
      String description, String group, int projectId) async {
    try {
      final response = await myApiService.post(
        EndPoints.createDash,
        token: token,
        data: {
          "name": name,
          "description": description,
          "groups": group,
          "project": projectId,
        },
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to get Dashs: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, MonitoringResponse>> getMonitoring(
      String token, int projectId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getMonitoring,
        token: token,
        queryParameters: {'project_id': projectId},
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(MonitoringResponse.fromJson(response.data));
      } else {
        return Left('Failed to get monitoring: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, MonitoringCloudHubResponse>> getMonitoringCloudHub(
      String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getMonitoringCloudHub,
        token: token,
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(MonitoringCloudHubResponse.fromJson(response.data));
      } else {
        return Left('Failed to get monitoring: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, SensorDataResponse>> getSensorData(
      String token, int sensorId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getSensorData,
        token: token,
        queryParameters: {'sensor_id': sensorId},
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(SensorDataResponse.fromJson(response.data));
      } else {
        return Left('Failed to get sensor data: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, AiAnalyzeDataModel>> analyzeSensorData(
      String token, QueryParams queryParams, String projectId) async {
    try {
      final response = await myApiService.get(
        EndPoints.analyzeSensorData,
        token: token,
        queryParameters: {
          ...queryParams.toJson(),
          'project_id': projectId,
        },
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(AiAnalyzeDataModel.fromJson(response.data));
      } else {
        return Left('Failed to get sensor data: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, MonitoringCloudhubDetails>> getCloudhubData(
      String token, int cloudhubId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getCloudhubData,
        token: token,
        queryParameters: {'cloudhub_id': cloudhubId},
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(MonitoringCloudhubDetails.fromJson(response.data));
      } else {
        return Left('Failed to get sensor data: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, SensorActivityLog>> getSensorActivityLog(
      String token, int sensorId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getSensorActivityLog,
        token: token,
        queryParameters: {'sensor_id': sensorId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(SensorActivityLog.fromJson(response.data));
      } else {
        return Left(
            'Failed to get sensor activity log: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, TicketMessagesModel>> getTicketMessages(
      String token, int ticketId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getTicketMessages,
        token: token,
        queryParameters: {'ticket_id': ticketId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(TicketMessagesModel.fromJson(response.data));
      } else {
        return Left('Failed to get ticket messages: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> createTicketMessage(
      String token, int ticketId, String message) async {
    try {
      final response = await myApiService.post(
        EndPoints.createTicketMessage,
        token: token,
        encodeAsJson: true,
        queryParameters: {'ticket_id': ticketId},
        data: {'message': message},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to create ticket message: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> updateProject(
      String token, int projectId, ProjectUpdateRequest request) async {
    try {
      final Map<String, dynamic> filteredData = request.toJson()
        ..removeWhere((key, value) => value == null || value == '');

      final response = await myApiService.post(
        EndPoints.updateProject,
        token: token,
        queryParameters: {'id': projectId},
        data: filteredData,
        encodeAsJson: true,
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to update project: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> deleteProject(
      String token, int projectId) async {
    try {
      final response = await myApiService.delete(
        EndPoints.updateProject,
        token: token,
        queryParameters: {'id': projectId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to delete project: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, GetUsedSensorsResponseModel>> getUsedSensors(
      String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getUsedSensor,
        token: token,
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(GetUsedSensorsResponseModel.fromJson(response.data));
      } else {
        return Left('Failed to get used sensors: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> updateUsedSensors(
      String token, int usedSensorId, int count) async {
    try {
      final response = await myApiService.post(
        EndPoints.getUsedSensor,
        token: token,
        queryParameters: {"id": usedSensorId},
        data: {"count": count},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(response.data['success'] == true);
      } else {
        return Left('Failed to get used sensors: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> deleteUsedSensors(
      String token, int usedSensorId) async {
    try {
      final response = await myApiService.delete(
        EndPoints.getUsedSensor,
        token: token,
        queryParameters: {"id": usedSensorId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(response.data['success'] == true);
      } else {
        return Left('Failed to get used sensors: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> createUsedSensors(
      String token, int usedSensorTypeId, int count, int monitoringId) async {
    try {
      final response = await myApiService.post(
        EndPoints.getUsedSensor,
        token: token,
        data: {
          "sensor_type_id": usedSensorTypeId,
          "count": count,
          "monitoring": monitoringId
        },
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to create used sensors: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> createMediaLibraryFile(
      String token,
      int projectId,
      String fileName,
      String fileDescription,
      PlatformFile file) async {
    try {
      // Create form data
      final formData = FormData.fromMap({
        'project': projectId,
        'file_name': fileName,
        'description': fileDescription,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await myApiService.post(
        EndPoints.mediaLibrary,
        token: token,
        data: formData,
      );

      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left(
            'Failed to create media library file: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, GetMediaLibrariesResponseModel>> getMediaLibrary(
      String token, int projectId) async {
    try {
      final response = await myApiService.get(
        EndPoints.mediaLibrary,
        token: token,
        queryParameters: {'project_id': projectId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(GetMediaLibrariesResponseModel.fromJson(response.data));
      } else {
        return Left('Failed to get media library: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> deleteMediaLibrary(
      String token, int mediaLibraryId) async {
    try {
      final response = await myApiService.delete(
        EndPoints.mediaLibrary,
        token: token,
        queryParameters: {'id': mediaLibraryId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to delete media library: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, GetCollaboratorsResponseModel>> getCollaborators(
      String token, int projectId) async {
    try {
      final response = await myApiService.get(
        EndPoints.getCollaborators,
        token: token,
        queryParameters: {'id': projectId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(GetCollaboratorsResponseModel.fromJson(response.data));
      } else {
        return Left('Failed to get collaborators: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
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
      bool isNotificationSender) async {
    try {
      final response = await myApiService.post(
        EndPoints.updateCollaborators,
        token: token,
        queryParameters: {'id': groupId},
        data: {
          "project": projectId,
          "name": name,
          "description": description,
          "is_analyzer": isAnalyzer,
          "is_viewer": isViewer,
          "is_editor": isEditor,
          "is_monitor": isMonitor,
          "is_manager": isManager,
          "is_notifications_sender": isNotificationSender,
        },
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to update collaborators: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> deleteCollaborators(
      String token, int groupId) async {
    try {
      final response = await myApiService.delete(
        EndPoints.updateCollaborators,
        token: token,
        queryParameters: {'id': groupId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to delete collaborators: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> createCollaboratorsGroup(
      String token,
      int projectId,
      String name,
      String description,
      bool isAnalyzer,
      bool isViewer,
      bool isEditor,
      bool isMonitor,
      bool isManager,
      bool isNotificationSender) async {
    try {
      final response = await myApiService.post(
        EndPoints.createCollaboratorsGroup,
        token: token,
        data: {
          "project": projectId,
          "name": name,
          "description": description,
          "is_analyzer": isAnalyzer,
          "is_viewer": isViewer,
          "is_editor": isEditor,
          "is_monitor": isMonitor,
          "is_manager": isManager,
          "is_notifications_sender": isNotificationSender,
        },
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left(
            'Failed to create collaborators group: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> addUserToCollaboratorsGroup(
      String token, List<int>? groupIds, List<int> userIds,
      {List<int>? projectIds}) async {
    try {
      final Map<String, dynamic> data = {
        "user_ids": userIds,
      };

      if (groupIds != null) {
        data["group_ids"] = groupIds;
      }
      if (projectIds != null) {
        data["project_ids"] = projectIds;
      }

      final response = await myApiService.post(
        EndPoints.addUserToCollaboratorsGroup,
        token: token,
        encodeAsJson: true,
        data: data,
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left(
            'Failed to add user to collaborators group: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> removeUserFromCollaboratorsGroup(
      String token, List<int> groupIds, int userId) async {
    try {
      final response = await myApiService.post(
        EndPoints.removeUserFromCollaboratorsGroup,
        token: token,
        encodeAsJson: true,
        data: {
          "group_ids": groupIds,
          "user_ids": [userId],
        },
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left(
            'Failed to remove user from collaborators group: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, GetAllResponseModel>> getAllUsers(String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getAllUsers,
        token: token,
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return Right(GetAllResponseModel.fromJson(response.data));
      } else {
        return Left('Failed to get all users: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> updateCloudhub(
      String token, int cloudhubId, UpdateCloudhubRequestModel request) async {
    try {
      final Map<String, dynamic> filteredData = request.toJson()
        ..removeWhere((key, value) => value == null || value == '');

      final response = await myApiService.post(
        EndPoints.getMonitoringCloudHub,
        token: token,
        queryParameters: {'cloudhub_id': cloudhubId},
        data: filteredData,
        encodeAsJson: true,
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to update cloudhub: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> markMessageAsSeen(
      String token, int messageId) async {
    try {
      final response = await myApiService.get(
        EndPoints.markMessageAsSeen,
        token: token,
        queryParameters: {'message_id': messageId},
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to mark message as seen: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }

  @override
  Future<Either<String, bool>> createCloudhubSensor(
      String token, int cloudhubId, String sensorName) async {
    try {
      final response = await myApiService.post(
        EndPoints.getSensorData,
        token: token,
        data: {
          "name": sensorName,
          "cloud_hub": cloudhubId,
        },
      );
      if ((response.statusCode == StatusCode.created ||
              response.statusCode == StatusCode.ok) &&
          response.data['success']) {
        return const Right(true);
      } else {
        return Left('Failed to create cloudhub sensor: ${response.statusCode}');
      }
    } catch (error) {
      return Left('Exception occurred: $error');
    }
  }
}

class QueryParams {
  final String? aggregateFunc;
  final String? bucket;
  final String? deviationThreshold;
  final String? fields;
  final String? measurementName;
  final String? org;
  final bool rawData; // Fixed value
  final String? sensorsToAnalyze;
  final String? timeRangeStart;
  final String timeRangeStop;
  final String? topic;
  final String? windowPeriod;
  final String? windowSize;

  QueryParams({
    this.aggregateFunc,
    this.bucket,
    this.deviationThreshold,
    this.fields,
    this.measurementName,
    this.org,
    this.topic,
    this.sensorsToAnalyze,
    this.timeRangeStart,
    String? timeRangeStop,
    this.windowSize,
    this.windowPeriod,
  })  : rawData = false,
        timeRangeStop = timeRangeStop ?? 'now';

  Map<String, dynamic> toJson() {
    return {
      'aggregate_func': aggregateFunc,
      'bucket': bucket,
      'deviation_threshold': deviationThreshold,
      'fields': fields,
      'measurement_name': measurementName,
      'org': org,
      'raw_data': rawData,
      'sensors_to_analyze': sensorsToAnalyze,
      'time_range_start': timeRangeStart,
      'time_range_stop': timeRangeStop,
      'topic': topic,
      'window_size': windowSize,
      'window_period': windowPeriod,
    };
  }
}
