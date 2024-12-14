// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_projects_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetProjectsResponse _$GetProjectsResponseFromJson(Map<String, dynamic> json) =>
    GetProjectsResponse(
      success: json['success'] as bool,
      projects: (json['projects'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      ownersOrder: (json['owners_order'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$GetProjectsResponseToJson(
        GetProjectsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'projects': instance.projects,
      'owners_order': instance.ownersOrder,
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      projectId: (json['project_id'] as num).toInt(),
      title: json['title'] as String,
      picture: json['picture'] as String,
      startDate: json['start_date'] as String?,
      pictureUrl: json['picture_url'] as String,
      warnings: (json['warnings'] as num).toInt(),
      isFlag: json['is_flag'] as bool,
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'project_id': instance.projectId,
      'title': instance.title,
      'picture': instance.picture,
      'start_date': instance.startDate,
      'picture_url': instance.pictureUrl,
      'warnings': instance.warnings,
      'is_flag': instance.isFlag,
      'owner': instance.owner,
    };

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
      ownerId: (json['owner_id'] as num).toInt(),
      name: json['name'] as String,
      logo: json['logo'] as String,
      logoUrl: json['logo_url'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
      'owner_id': instance.ownerId,
      'name': instance.name,
      'logo': instance.logo,
      'logo_url': instance.logoUrl,
      'order': instance.order,
    };
