import 'package:json_annotation/json_annotation.dart';

part 'project_dashboards.g.dart';

@JsonSerializable()
class ProjectDashboards {
  final bool success;
  final List<Dashboard> dashboards;

  ProjectDashboards({
    required this.success,
    required this.dashboards,
  });

  factory ProjectDashboards.fromJson(Map<String, dynamic> json) =>
      _$ProjectDashboardsFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDashboardsToJson(this);
}

@JsonSerializable()
class Dashboard {
  @JsonKey(name: 'dashboard_id')
  final int dashboardId;
  final String name;
  final String? description;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'last_edition')
  final String lastEdition;
  final String? sites;
  final String groups;
  final int project;
  final List<Component> components;

  Dashboard({
    required this.dashboardId,
    required this.name,
    required this.description,
    this.createdBy,
    required this.lastEdition,
    this.sites,
    required this.groups,
    required this.project,
    required this.components,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardToJson(this);
}

@JsonSerializable()
class Component {
  @JsonKey(name: 'component_id')
  final int componentId;
  final String name;
  final Map<String, dynamic>? content;
  final int dashboard;

  Component({
    required this.componentId,
    required this.name,
    this.content,
    required this.dashboard,
  });

  factory Component.fromJson(Map<String, dynamic> json) =>
      _$ComponentFromJson(json);

  Map<String, dynamic> toJson() => _$ComponentToJson(this);
}
