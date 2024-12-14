import 'package:json_annotation/json_annotation.dart';

part 'project_response.g.dart';

@JsonSerializable()
class ProjectResponse {
  final bool? success;
  final Project? project;

  ProjectResponse({
    this.success,
    this.project,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectResponseToJson(this);
}

@JsonSerializable()
class Project {
  @JsonKey(name: 'project_id')
  final int? projectId;
  final int? warnings;
  final String? title;
  final String? acronym;
  @JsonKey(name: 'picture_url')
  final String? pictureUrl;
  final String? picture;
  @JsonKey(name: 'start_date')
  final String? startDate;
  final String? duration;
  final String? budget;
  final String? consultant;
  final String? contractor;
  @JsonKey(name: 'construction_date')
  final String? constructionDate;
  @JsonKey(name: 'construction_characteristics')
  final String? constructionCharacteristics;
  final String? description;
  @JsonKey(name: 'time_zone')
  final String? timeZone;
  @JsonKey(name: 'cordinate_system')
  final String? coordinateSystem;
  @JsonKey(name: 'date_formate')
  final String? dateFormat;
  @JsonKey(name: 'type_of_building')
  final String? typeOfBuilding;
  final String? size;
  @JsonKey(name: 'age_of_building')
  final String? ageOfBuilding;
  final String? structure;
  @JsonKey(name: 'building_history')
  final String? buildingHistory;
  @JsonKey(name: 'surrounding_environment')
  final String? surroundingEnvironment;
  @JsonKey(name: 'importance_of_risk_identification')
  final String? importanceOfRiskIdentification;
  @JsonKey(name: 'budget_constraints')
  final String? budgetConstraints;
  @JsonKey(name: 'plans_and_files')
  final String? plansAndFiles;
  final List<Monitoring>? monitorings;
  final Owner? owner;

  Project({
    this.projectId,
    this.warnings,
    this.title,
    this.acronym,
    this.pictureUrl,
    this.picture,
    this.startDate,
    this.duration,
    this.budget,
    this.consultant,
    this.contractor,
    this.constructionDate,
    this.constructionCharacteristics,
    this.description,
    this.timeZone,
    this.coordinateSystem,
    this.dateFormat,
    this.typeOfBuilding,
    this.size,
    this.ageOfBuilding,
    this.structure,
    this.buildingHistory,
    this.surroundingEnvironment,
    this.importanceOfRiskIdentification,
    this.budgetConstraints,
    this.plansAndFiles,
    this.monitorings,
    this.owner,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Monitoring {
  @JsonKey(name: 'monitoring_id')
  final int? monitoringId;
  @JsonKey(name: 'monitoring_name')
  final String? monitoringName;
  @JsonKey(name: 'monitoring_communications')
  final String? monitoringCommunications;

  Monitoring({
    this.monitoringId,
    this.monitoringName,
    this.monitoringCommunications,
  });

  factory Monitoring.fromJson(Map<String, dynamic> json) =>
      _$MonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringToJson(this);
}

@JsonSerializable()
class Owner {
  @JsonKey(name: 'owner_id')
  final int? ownerId;
  final String? name;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  Owner({
    this.ownerId,
    this.name,
    this.logoUrl,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}
