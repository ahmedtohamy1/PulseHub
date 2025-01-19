// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_projects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUsersProjects _$GetUsersProjectsFromJson(Map<String, dynamic> json) =>
    GetUsersProjects(
      success: json['success'] as bool,
      projectsList: (json['projects_list'] as List<dynamic>)
          .map((e) => ProjectsList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetUsersProjectsToJson(GetUsersProjects instance) =>
    <String, dynamic>{
      'success': instance.success,
      'projects_list': instance.projectsList,
    };

ProjectsList _$ProjectsListFromJson(Map<String, dynamic> json) => ProjectsList(
      projectId: (json['project_id'] as num).toInt(),
      title: json['title'] as String,
      picture: json['picture'] as String? ?? '',
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      pictureUrl: json['picture_url'] as String,
      warnings: (json['warnings'] as num).toInt(),
      isFlag: json['is_flag'] as bool,
    );

Map<String, dynamic> _$ProjectsListToJson(ProjectsList instance) =>
    <String, dynamic>{
      'project_id': instance.projectId,
      'title': instance.title,
      'picture': instance.picture,
      'start_date': instance.startDate?.toIso8601String(),
      'picture_url': instance.pictureUrl,
      'warnings': instance.warnings,
      'is_flag': instance.isFlag,
    };
