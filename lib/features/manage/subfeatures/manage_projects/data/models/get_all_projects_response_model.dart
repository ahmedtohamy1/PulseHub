import 'package:json_annotation/json_annotation.dart';

part 'get_all_projects_response_model.g.dart';

@JsonSerializable()
class GetAllProjectsResponseModel {
  @JsonKey(name: "success")
  bool success;
  @JsonKey(name: "projects")
  List<Project> projects;

  GetAllProjectsResponseModel({
    required this.success,
    required this.projects,
  });

  factory GetAllProjectsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetAllProjectsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllProjectsResponseModelToJson(this);
}

@JsonSerializable()
class Project {
  @JsonKey(name: "project_id")
  int projectId;
  @JsonKey(name: "warnings")
  int warnings;
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "acronym")
  String? acronym;
  @JsonKey(name: "picture")
  String? picture;
  @JsonKey(name: "start_date")
  DateTime? startDate;
  @JsonKey(name: "duration")
  String? duration;
  @JsonKey(name: "budget")
  String? budget;
  @JsonKey(name: "consultant")
  String? consultant;
  @JsonKey(name: "contractor")
  String? contractor;
  @JsonKey(name: "construction_date")
  dynamic constructionDate;
  @JsonKey(name: "construction_characteristics")
  String? constructionCharacteristics;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "time_zone")
  String? timeZone;
  @JsonKey(name: "cordinate_system")
  String? cordinateSystem;
  @JsonKey(name: "date_formate")
  String? dateFormate;
  @JsonKey(name: "type_of_building")
  String? typeOfBuilding;
  @JsonKey(name: "size")
  String? size;
  @JsonKey(name: "age_of_building")
  String? ageOfBuilding;
  @JsonKey(name: "structure")
  dynamic structure;
  @JsonKey(name: "building_history")
  dynamic buildingHistory;
  @JsonKey(name: "surrounding_environment")
  String? surroundingEnvironment;
  @JsonKey(name: "importance_of_risk_identification")
  dynamic importanceOfRiskIdentification;
  @JsonKey(name: "budget_constraints")
  dynamic budgetConstraints;
  @JsonKey(name: "plans_and_files")
  String? plansAndFiles;
  @JsonKey(name: "picture_url")
  String pictureUrl;
  @JsonKey(name: "owner")
  Owner owner;

  Project({
    required this.projectId,
    required this.warnings,
    required this.title,
    this.acronym,
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
    this.cordinateSystem,
    this.dateFormate,
    this.typeOfBuilding,
    this.size,
    this.ageOfBuilding,
    this.structure,
    this.buildingHistory,
    this.surroundingEnvironment,
    this.importanceOfRiskIdentification,
    this.budgetConstraints,
    this.plansAndFiles,
    required this.pictureUrl,
    required this.owner,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Owner {
  @JsonKey(name: "owner_id")
  int ownerId;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "logo")
  String? logo;
  @JsonKey(name: "logo_url")
  String logoUrl;

  Owner({
    required this.ownerId,
    required this.name,
    this.logo,
    required this.logoUrl,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}
