import 'package:json_annotation/json_annotation.dart';


part 'project_response.g.dart';

@JsonSerializable()
class ProjectResponse {
  final bool success;
  final List<Project> projects;

  ProjectResponse({
    required this.success,
    required this.projects,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    final projectData = json['projects'];
    List<Project> parsedProjects;

    if (projectData is Map<String, dynamic>) {
      parsedProjects = [Project.fromJson(projectData)];
    } else if (projectData is List) {
      parsedProjects = projectData.map<Project>((p) => Project.fromJson(p)).toList();
    } else {
      parsedProjects = [];
    }

    return ProjectResponse(
      success: json['success'] as bool,
      projects: parsedProjects,
    );
  }

  Map<String, dynamic> toJson() => _$ProjectResponseToJson(this);
}


@JsonSerializable()
class Project {
  @JsonKey(name: 'project_id')
  final int projectId;
  final int warnings;
  final String title;
  final String acronym;
  @JsonKey(name: 'picture_url')
  final String pictureUrl;
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
  final Owner owner;

  Project({
    required this.projectId,
    required this.warnings,
    required this.title,
    required this.acronym,
    required this.pictureUrl,
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
    required this.owner,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}


@JsonSerializable()
class Owner {
  @JsonKey(name: 'owner_id')
  final int ownerId;
  final String name;
  @JsonKey(name: 'logo_url')
  final String logoUrl;

  Owner({
    required this.ownerId,
    required this.name,
    required this.logoUrl,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}
