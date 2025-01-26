import 'package:json_annotation/json_annotation.dart';

part 'get_all_projects_response_model.g.dart';

@JsonSerializable()
class GetAllProjectsResponseModel {
    @JsonKey(name: "count")
    int count;
    @JsonKey(name: "next")
    String next;
    @JsonKey(name: "previous")
    dynamic previous;
    @JsonKey(name: "results")
    Results results;

    GetAllProjectsResponseModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    GetAllProjectsResponseModel copyWith({
        int? count,
        String? next,
        dynamic previous,
        Results? results,
    }) => 
        GetAllProjectsResponseModel(
            count: count ?? this.count,
            next: next ?? this.next,
            previous: previous ?? this.previous,
            results: results ?? this.results,
        );

    factory GetAllProjectsResponseModel.fromJson(Map<String, dynamic> json) => _$GetAllProjectsResponseModelFromJson(json);

    Map<String, dynamic> toJson() => _$GetAllProjectsResponseModelToJson(this);
}

@JsonSerializable()
class Results {
    @JsonKey(name: "success")
    bool success;
    @JsonKey(name: "projects")
    List<Project> projects;

    Results({
        required this.success,
        required this.projects,
    });

    Results copyWith({
        bool? success,
        List<Project>? projects,
    }) => 
        Results(
            success: success ?? this.success,
            projects: projects ?? this.projects,
        );

    factory Results.fromJson(Map<String, dynamic> json) => _$ResultsFromJson(json);

    Map<String, dynamic> toJson() => _$ResultsToJson(this);
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
    String acronym;
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
        required this.acronym,
        required this.startDate,
        required this.duration,
        required this.budget,
        required this.consultant,
        required this.contractor,
        required this.constructionDate,
        required this.constructionCharacteristics,
        required this.description,
        required this.timeZone,
        required this.cordinateSystem,
        required this.dateFormate,
        required this.typeOfBuilding,
        required this.size,
        required this.ageOfBuilding,
        required this.structure,
        required this.buildingHistory,
        required this.surroundingEnvironment,
        required this.importanceOfRiskIdentification,
        required this.budgetConstraints,
        required this.plansAndFiles,
        required this.pictureUrl,
        required this.owner,
    });

    Project copyWith({
        int? projectId,
        int? warnings,
        String? title,
        String? acronym,
        DateTime? startDate,
        String? duration,
        String? budget,
        String? consultant,
        String? contractor,
        dynamic constructionDate,
        String? constructionCharacteristics,
        String? description,
        String? timeZone,
        String? cordinateSystem,
        String? dateFormate,
        String? typeOfBuilding,
        String? size,
        String? ageOfBuilding,
        dynamic structure,
        dynamic buildingHistory,
        String? surroundingEnvironment,
        dynamic importanceOfRiskIdentification,
        dynamic budgetConstraints,
        String? plansAndFiles,
        String? pictureUrl,
        Owner? owner,
    }) => 
        Project(
            projectId: projectId ?? this.projectId,
            warnings: warnings ?? this.warnings,
            title: title ?? this.title,
            acronym: acronym ?? this.acronym,
            startDate: startDate ?? this.startDate,
            duration: duration ?? this.duration,
            budget: budget ?? this.budget,
            consultant: consultant ?? this.consultant,
            contractor: contractor ?? this.contractor,
            constructionDate: constructionDate ?? this.constructionDate,
            constructionCharacteristics: constructionCharacteristics ?? this.constructionCharacteristics,
            description: description ?? this.description,
            timeZone: timeZone ?? this.timeZone,
            cordinateSystem: cordinateSystem ?? this.cordinateSystem,
            dateFormate: dateFormate ?? this.dateFormate,
            typeOfBuilding: typeOfBuilding ?? this.typeOfBuilding,
            size: size ?? this.size,
            ageOfBuilding: ageOfBuilding ?? this.ageOfBuilding,
            structure: structure ?? this.structure,
            buildingHistory: buildingHistory ?? this.buildingHistory,
            surroundingEnvironment: surroundingEnvironment ?? this.surroundingEnvironment,
            importanceOfRiskIdentification: importanceOfRiskIdentification ?? this.importanceOfRiskIdentification,
            budgetConstraints: budgetConstraints ?? this.budgetConstraints,
            plansAndFiles: plansAndFiles ?? this.plansAndFiles,
            pictureUrl: pictureUrl ?? this.pictureUrl,
            owner: owner ?? this.owner,
        );

    factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

    Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Owner {
    @JsonKey(name: "owner_id")
    int ownerId;
    @JsonKey(name: "name")
    String name;
    @JsonKey(name: "logo_url")
    String logoUrl;

    Owner({
        required this.ownerId,
        required this.name,
        required this.logoUrl,
    });

    Owner copyWith({
        int? ownerId,
        String? name,
        String? logoUrl,
    }) => 
        Owner(
            ownerId: ownerId ?? this.ownerId,
            name: name ?? this.name,
            logoUrl: logoUrl ?? this.logoUrl,
        );

    factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

    Map<String, dynamic> toJson() => _$OwnerToJson(this);
}
