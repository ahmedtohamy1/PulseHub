// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_projects_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllProjectsResponseModel _$GetAllProjectsResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetAllProjectsResponseModel(
      success: json['success'] as bool,
      projects: (json['projects'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetAllProjectsResponseModelToJson(
        GetAllProjectsResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'projects': instance.projects,
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      projectId: (json['project_id'] as num).toInt(),
      warnings: (json['warnings'] as num).toInt(),
      title: json['title'] as String,
      acronym: json['acronym'] as String,
      picture: json['picture'] as String,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      duration: json['duration'] as String?,
      budget: json['budget'] as String?,
      consultant: json['consultant'] as String?,
      contractor: json['contractor'] as String?,
      constructionDate: json['construction_date'],
      constructionCharacteristics:
          json['construction_characteristics'] as String?,
      description: json['description'] as String?,
      timeZone: json['time_zone'] as String?,
      cordinateSystem: json['cordinate_system'] as String?,
      dateFormate: json['date_formate'] as String?,
      typeOfBuilding: json['type_of_building'] as String?,
      size: json['size'] as String?,
      ageOfBuilding: json['age_of_building'] as String?,
      structure: json['structure'],
      buildingHistory: json['building_history'],
      surroundingEnvironment: json['surrounding_environment'] as String?,
      importanceOfRiskIdentification: json['importance_of_risk_identification'],
      budgetConstraints: json['budget_constraints'],
      plansAndFiles: json['plans_and_files'] as String?,
      pictureUrl: json['picture_url'] as String,
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'project_id': instance.projectId,
      'warnings': instance.warnings,
      'title': instance.title,
      'acronym': instance.acronym,
      'picture': instance.picture,
      'start_date': instance.startDate?.toIso8601String(),
      'duration': instance.duration,
      'budget': instance.budget,
      'consultant': instance.consultant,
      'contractor': instance.contractor,
      'construction_date': instance.constructionDate,
      'construction_characteristics': instance.constructionCharacteristics,
      'description': instance.description,
      'time_zone': instance.timeZone,
      'cordinate_system': instance.cordinateSystem,
      'date_formate': instance.dateFormate,
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
      'picture_url': instance.pictureUrl,
      'owner': instance.owner,
    };

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
      ownerId: (json['owner_id'] as num).toInt(),
      name: json['name'] as String,
      logo: json['logo'] as String,
      logoUrl: json['logo_url'] as String,
    );

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
      'owner_id': instance.ownerId,
      'name': instance.name,
      'logo': instance.logo,
      'logo_url': instance.logoUrl,
    };
