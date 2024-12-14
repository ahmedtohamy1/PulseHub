// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectResponse _$ProjectResponseFromJson(Map<String, dynamic> json) =>
    ProjectResponse(
      success: json['success'] as bool?,
      project: json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectResponseToJson(ProjectResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'project': instance.project,
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      projectId: (json['project_id'] as num?)?.toInt(),
      warnings: (json['warnings'] as num?)?.toInt(),
      title: json['title'] as String?,
      acronym: json['acronym'] as String?,
      pictureUrl: json['picture_url'] as String?,
      picture: json['picture'] as String?,
      startDate: json['start_date'] as String?,
      duration: json['duration'] as String?,
      budget: json['budget'] as String?,
      consultant: json['consultant'] as String?,
      contractor: json['contractor'] as String?,
      constructionDate: json['construction_date'] as String?,
      constructionCharacteristics:
          json['construction_characteristics'] as String?,
      description: json['description'] as String?,
      timeZone: json['time_zone'] as String?,
      coordinateSystem: json['cordinate_system'] as String?,
      dateFormat: json['date_formate'] as String?,
      typeOfBuilding: json['type_of_building'] as String?,
      size: json['size'] as String?,
      ageOfBuilding: json['age_of_building'] as String?,
      structure: json['structure'] as String?,
      buildingHistory: json['building_history'] as String?,
      surroundingEnvironment: json['surrounding_environment'] as String?,
      importanceOfRiskIdentification:
          json['importance_of_risk_identification'] as String?,
      budgetConstraints: json['budget_constraints'] as String?,
      plansAndFiles: json['plans_and_files'] as String?,
      monitorings: (json['monitorings'] as List<dynamic>?)
          ?.map((e) => Monitoring.fromJson(e as Map<String, dynamic>))
          .toList(),
      owner: json['owner'] == null
          ? null
          : Owner.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'project_id': instance.projectId,
      'warnings': instance.warnings,
      'title': instance.title,
      'acronym': instance.acronym,
      'picture_url': instance.pictureUrl,
      'picture': instance.picture,
      'start_date': instance.startDate,
      'duration': instance.duration,
      'budget': instance.budget,
      'consultant': instance.consultant,
      'contractor': instance.contractor,
      'construction_date': instance.constructionDate,
      'construction_characteristics': instance.constructionCharacteristics,
      'description': instance.description,
      'time_zone': instance.timeZone,
      'cordinate_system': instance.coordinateSystem,
      'date_formate': instance.dateFormat,
      'type_of_building': instance.typeOfBuilding,
      'size': instance.size,
      'age_of_building': instance.ageOfBuilding,
      'structure': instance.structure,
      'building_history': instance.buildingHistory,
      'surrounding_environment': instance.surroundingEnvironment,
      'importance_of_risk_identification':
          instance.importanceOfRiskIdentification,
      'budget_constraints': instance.budgetConstraints,
      'plans_and_files': instance.plansAndFiles,
      'monitorings': instance.monitorings,
      'owner': instance.owner,
    };

Monitoring _$MonitoringFromJson(Map<String, dynamic> json) => Monitoring(
      monitoringId: (json['monitoring_id'] as num?)?.toInt(),
      monitoringName: json['monitoring_name'] as String?,
      monitoringCommunications: json['monitoring_communications'] as String?,
    );

Map<String, dynamic> _$MonitoringToJson(Monitoring instance) =>
    <String, dynamic>{
      'monitoring_id': instance.monitoringId,
      'monitoring_name': instance.monitoringName,
      'monitoring_communications': instance.monitoringCommunications,
    };

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
      ownerId: (json['owner_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
      'owner_id': instance.ownerId,
      'name': instance.name,
      'logo_url': instance.logoUrl,
    };
