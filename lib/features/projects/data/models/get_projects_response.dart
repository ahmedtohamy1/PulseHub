import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'get_projects_response.g.dart';

@JsonSerializable()
class GetProjectsResponse {
  final bool success;
  @JsonKey(name: 'projects')
  final List<Project> projects;
  @JsonKey(name: 'owners_order')
  final List<int> ownersOrder;

  GetProjectsResponse({
    required this.success,
    required this.projects,
    required this.ownersOrder,
  });

  factory GetProjectsResponse.fromJson(Map<String, dynamic> json) {
    // Handle null or empty 'owners' map
    final ownersMap = json['owners'] as Map<String, dynamic>? ?? {};
    final List<Project> projectsList = [];

    // Parse `owners` to include `Owner` inside each `Project`
    ownersMap.forEach((ownerKey, projects) {
      final owner = parseOwnerKey(ownerKey);
      final projectList = (projects as List<dynamic>)
          .map((projectJson) => Project.fromJsonWithOwner(projectJson, owner))
          .toList();
      projectsList.addAll(projectList);
    });

    return GetProjectsResponse(
      success: json['success'] as bool,
      projects: projectsList,
      ownersOrder: List<int>.from(json['owners_order'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => _$GetProjectsResponseToJson(this);
}

@JsonSerializable()
class Project {
  @JsonKey(name: 'project_id')
  final int projectId;
  final String title;
  final String? picture;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'picture_url')
  final String pictureUrl;
  final int warnings;
  @JsonKey(name: 'is_flag')
  final bool isFlag;
  final Owner owner;

  Project({
    required this.projectId,
    required this.title,
    this.picture,
    this.startDate,
    required this.pictureUrl,
    required this.warnings,
    required this.isFlag,
    required this.owner,
  });

  /// Factory constructor for deserializing a `Project` with an `Owner`
  factory Project.fromJsonWithOwner(Map<String, dynamic> json, Owner owner) {
    return Project(
      projectId: json['project_id'] as int,
      title: json['title'] as String,
      picture: json['picture'] as String?,
      startDate: json['start_date'] as String?,
      pictureUrl: json['picture_url'] as String,
      warnings: json['warnings'] as int,
      isFlag: json['is_flag'] as bool,
      owner: owner,
    );
  }

  /// Factory constructor for deserializing a `Project` without an `Owner`
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Owner {
  @JsonKey(name: 'owner_id')
  final int ownerId;
  final String name;
  final String? logo;
  @JsonKey(name: 'logo_url')
  final String logoUrl;
  final int? order;

  Owner({
    required this.ownerId,
    required this.name,
    this.logo,
    required this.logoUrl,
    this.order,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}

/// Parses the owner key string into an `Owner` object
Owner parseOwnerKey(String ownerKey) {
  // Decode the JSON-like string key
  final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
    jsonDecode(ownerKey.replaceAll("'", '"')),
  );
  return Owner.fromJson(jsonMap);
}
