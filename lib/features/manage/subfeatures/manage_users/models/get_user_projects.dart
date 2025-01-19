import 'package:json_annotation/json_annotation.dart';

part 'get_user_projects.g.dart';

@JsonSerializable()
class GetUsersProjects {
  @JsonKey(name: "success")
  bool success;
  @JsonKey(name: "projects_list")
  List<ProjectsList> projectsList;

  GetUsersProjects({
    required this.success,
    required this.projectsList,
  });

  GetUsersProjects copyWith({
    bool? success,
    List<ProjectsList>? projectsList,
  }) =>
      GetUsersProjects(
        success: success ?? this.success,
        projectsList: projectsList ?? this.projectsList,
      );

  factory GetUsersProjects.fromJson(Map<String, dynamic> json) =>
      _$GetUsersProjectsFromJson(json);

  Map<String, dynamic> toJson() => _$GetUsersProjectsToJson(this);
}

@JsonSerializable()
class ProjectsList {
  @JsonKey(name: "project_id")
  int projectId;
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "picture", defaultValue: "")
  String picture;
  @JsonKey(name: "start_date")
  DateTime? startDate;
  @JsonKey(name: "picture_url")
  String pictureUrl;
  @JsonKey(name: "warnings")
  int warnings;
  @JsonKey(name: "is_flag")
  bool isFlag;

  ProjectsList({
    required this.projectId,
    required this.title,
    required this.picture,
    required this.startDate,
    required this.pictureUrl,
    required this.warnings,
    required this.isFlag,
  });

  ProjectsList copyWith({
    int? projectId,
    String? title,
    String? picture,
    DateTime? startDate,
    String? pictureUrl,
    int? warnings,
    bool? isFlag,
  }) =>
      ProjectsList(
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        picture: picture ?? this.picture,
        startDate: startDate ?? this.startDate,
        pictureUrl: pictureUrl ?? this.pictureUrl,
        warnings: warnings ?? this.warnings,
        isFlag: isFlag ?? this.isFlag,
      );

  factory ProjectsList.fromJson(Map<String, dynamic> json) =>
      _$ProjectsListFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectsListToJson(this);
}
