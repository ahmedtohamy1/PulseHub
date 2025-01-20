// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectUpdateRequest _$ProjectUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    ProjectUpdateRequest(
      title: json['title'] as String?,
      acronym: json['acronym'] as String?,
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
      cordinateSystem: json['cordinate_system'] as String?,
      dateFormate: json['date_formate'] as String?,
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
    );

Map<String, dynamic> _$ProjectUpdateRequestToJson(
        ProjectUpdateRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'acronym': instance.acronym,
      'start_date': instance.startDate,
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
    };
