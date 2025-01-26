import 'package:json_annotation/json_annotation.dart';

part 'get_dash_components.g.dart';

@JsonSerializable()
class GetDashComponents {
  @JsonKey(name: "success")
  bool success;
  @JsonKey(name: "dashboard_list")
  List<DashboardList> dashboardList;

  GetDashComponents({
    required this.success,
    required this.dashboardList,
  });

  GetDashComponents copyWith({
    bool? success,
    List<DashboardList>? dashboardList,
  }) =>
      GetDashComponents(
        success: success ?? this.success,
        dashboardList: dashboardList ?? this.dashboardList,
      );

  factory GetDashComponents.fromJson(Map<String, dynamic> json) =>
      _$GetDashComponentsFromJson(json);

  Map<String, dynamic> toJson() => _$GetDashComponentsToJson(this);
}

@JsonSerializable()
class DashboardList {
  @JsonKey(name: "dashboard_id")
  int dashboardId;
  @JsonKey(name: "components")
  List<Component> components;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "description")
  String description;
  @JsonKey(name: "created_by")
  dynamic createdBy;
  @JsonKey(name: "last_edition")
  DateTime lastEdition;
  @JsonKey(name: "sites")
  String? sites;
  @JsonKey(name: "groups")
  String groups;
  @JsonKey(name: "project")
  int project;

  DashboardList({
    required this.dashboardId,
    required this.components,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.lastEdition,
    required this.sites,
    required this.groups,
    required this.project,
  });

  DashboardList copyWith({
    int? dashboardId,
    List<Component>? components,
    String? name,
    String? description,
    dynamic createdBy,
    DateTime? lastEdition,
    String? sites,
    String? groups,
    int? project,
  }) =>
      DashboardList(
        dashboardId: dashboardId ?? this.dashboardId,
        components: components ?? this.components,
        name: name ?? this.name,
        description: description ?? this.description,
        createdBy: createdBy ?? this.createdBy,
        lastEdition: lastEdition ?? this.lastEdition,
        sites: sites ?? this.sites,
        groups: groups ?? this.groups,
        project: project ?? this.project,
      );

  factory DashboardList.fromJson(Map<String, dynamic> json) =>
      _$DashboardListFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardListToJson(this);
}

@JsonSerializable()
class Component {
  @JsonKey(name: "component_id")
  int componentId;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "content")
  dynamic content;
  @JsonKey(name: "dashboard")
  int dashboard;

  Component({
    required this.componentId,
    required this.name,
    required this.content,
    required this.dashboard,
  });

  Component copyWith({
    int? componentId,
    String? name,
    dynamic content,
    int? dashboard,
  }) =>
      Component(
        componentId: componentId ?? this.componentId,
        name: name ?? this.name,
        content: content ?? this.content,
        dashboard: dashboard ?? this.dashboard,
      );

  factory Component.fromJson(Map<String, dynamic> json) =>
      _$ComponentFromJson(json);

  Map<String, dynamic> toJson() => _$ComponentToJson(this);
}

@JsonSerializable()
class ContentElement {
  @JsonKey(name: "sensor")
  int sensor;
  @JsonKey(name: "coordinate")
  List<int> coordinate;

  ContentElement({
    required this.sensor,
    required this.coordinate,
  });

  ContentElement copyWith({
    int? sensor,
    List<int>? coordinate,
  }) =>
      ContentElement(
        sensor: sensor ?? this.sensor,
        coordinate: coordinate ?? this.coordinate,
      );

  factory ContentElement.fromJson(Map<String, dynamic> json) =>
      _$ContentElementFromJson(json);

  Map<String, dynamic> toJson() => _$ContentElementToJson(this);
}

@JsonSerializable()
class PurpleContent {
  @JsonKey(name: "sensors")
  Map<String, List<double>> sensors;
  @JsonKey(name: "picture_name")
  String pictureName;

  PurpleContent({
    required this.sensors,
    required this.pictureName,
  });

  PurpleContent copyWith({
    Map<String, List<double>>? sensors,
    String? pictureName,
  }) =>
      PurpleContent(
        sensors: sensors ?? this.sensors,
        pictureName: pictureName ?? this.pictureName,
      );

  factory PurpleContent.fromJson(Map<String, dynamic> json) =>
      _$PurpleContentFromJson(json);

  Map<String, dynamic> toJson() => _$PurpleContentToJson(this);
}
