import 'package:json_annotation/json_annotation.dart';

part 'project_update_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProjectUpdateRequest {
  final String? title;
  final String? acronym;
  final String? startDate;
  final String? duration;
  final String? budget;
  final String? consultant;
  final String? contractor;
  final String? constructionDate;
  final String? constructionCharacteristics;
  final String? description;
  final String? timeZone;
  final String? cordinateSystem;
  final String? dateFormate;
  final String? typeOfBuilding;
  final String? size;
  final String? ageOfBuilding;
  final String? structure;
  final String? buildingHistory;
  final String? surroundingEnvironment;
  final String? importanceOfRiskIdentification;
  final String? budgetConstraints;
  final String? plansAndFiles;

  const ProjectUpdateRequest({
    this.title,
    this.acronym,
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
  });

  factory ProjectUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProjectUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectUpdateRequestToJson(this);

  ProjectUpdateRequest copyWith({
    String? title,
    String? acronym,
    String? startDate,
    String? duration,
    String? budget,
    String? consultant,
    String? contractor,
    String? constructionDate,
    String? constructionCharacteristics,
    String? description,
    String? timeZone,
    String? cordinateSystem,
    String? dateFormate,
    String? typeOfBuilding,
    String? size,
    String? ageOfBuilding,
    String? structure,
    String? buildingHistory,
    String? surroundingEnvironment,
    String? importanceOfRiskIdentification,
    String? budgetConstraints,
    String? plansAndFiles,
  }) {
    return ProjectUpdateRequest(
      title: title ?? this.title,
      acronym: acronym ?? this.acronym,
      startDate: startDate ?? this.startDate,
      duration: duration ?? this.duration,
      budget: budget ?? this.budget,
      consultant: consultant ?? this.consultant,
      contractor: contractor ?? this.contractor,
      constructionDate: constructionDate ?? this.constructionDate,
      constructionCharacteristics:
          constructionCharacteristics ?? this.constructionCharacteristics,
      description: description ?? this.description,
      timeZone: timeZone ?? this.timeZone,
      cordinateSystem: cordinateSystem ?? this.cordinateSystem,
      dateFormate: dateFormate ?? this.dateFormate,
      typeOfBuilding: typeOfBuilding ?? this.typeOfBuilding,
      size: size ?? this.size,
      ageOfBuilding: ageOfBuilding ?? this.ageOfBuilding,
      structure: structure ?? this.structure,
      buildingHistory: buildingHistory ?? this.buildingHistory,
      surroundingEnvironment:
          surroundingEnvironment ?? this.surroundingEnvironment,
      importanceOfRiskIdentification:
          importanceOfRiskIdentification ?? this.importanceOfRiskIdentification,
      budgetConstraints: budgetConstraints ?? this.budgetConstraints,
      plansAndFiles: plansAndFiles ?? this.plansAndFiles,
    );
  }
}
