

import 'package:json_annotation/json_annotation.dart';

part 'get_one_dash_components.g.dart';

@JsonSerializable()

class GetOneDashComponents {
    @JsonKey(name: "success")
    bool success;
    @JsonKey(name: "dashboard")
    Dashboard dashboard;

    GetOneDashComponents({
        required this.success,
        required this.dashboard,
    });

    GetOneDashComponents copyWith({
        bool? success,
        Dashboard? dashboard,
    }) => 
        GetOneDashComponents(
            success: success ?? this.success,
            dashboard: dashboard ?? this.dashboard,
        );

    factory GetOneDashComponents.fromJson(Map<String, dynamic> json) => _$GetOneDashComponentsFromJson(json);

    Map<String, dynamic> toJson() => _$GetOneDashComponentsToJson(this);
}

@JsonSerializable()
class Dashboard {
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
    dynamic sites;
    @JsonKey(name: "groups")
    String groups;
    @JsonKey(name: "project")
    int project;

    Dashboard({
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

    Dashboard copyWith({
        int? dashboardId,
        List<Component>? components,
        String? name,
        String? description,
        dynamic createdBy,
        DateTime? lastEdition,
        dynamic sites,
        String? groups,
        int? project,
    }) => 
        Dashboard(
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

    factory Dashboard.fromJson(Map<String, dynamic> json) => _$DashboardFromJson(json);

    Map<String, dynamic> toJson() => _$DashboardToJson(this);
}

@JsonSerializable()
class Component {
    @JsonKey(name: "component_id")
    int componentId;
    @JsonKey(name: "name")
    String name;
    @JsonKey(name: "content")
    Content? content;
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
        Content? content,
        int? dashboard,
    }) => 
        Component(
            componentId: componentId ?? this.componentId,
            name: name ?? this.name,
            content: content ?? this.content,
            dashboard: dashboard ?? this.dashboard,
        );

    factory Component.fromJson(Map<String, dynamic> json) => _$ComponentFromJson(json);

    Map<String, dynamic> toJson() => _$ComponentToJson(this);
}

@JsonSerializable()
class Content {
    @JsonKey(name: "sensors")
    Map<String, List<double>> sensors;
    @JsonKey(name: "picture_name")
    String pictureName;

    Content({
        required this.sensors,
        required this.pictureName,
    });

    Content copyWith({
        Map<String, List<double>>? sensors,
        String? pictureName,
    }) => 
        Content(
            sensors: sensors ?? this.sensors,
            pictureName: pictureName ?? this.pictureName,
        );

    factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

    Map<String, dynamic> toJson() => _$ContentToJson(this);
}
