// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_dash_components.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetDashComponents _$GetDashComponentsFromJson(Map<String, dynamic> json) =>
    GetDashComponents(
      success: json['success'] as bool,
      dashboardList: (json['dashboard_list'] as List<dynamic>)
          .map((e) => DashboardList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetDashComponentsToJson(GetDashComponents instance) =>
    <String, dynamic>{
      'success': instance.success,
      'dashboard_list': instance.dashboardList,
    };

DashboardList _$DashboardListFromJson(Map<String, dynamic> json) =>
    DashboardList(
      dashboardId: (json['dashboard_id'] as num).toInt(),
      components: (json['components'] as List<dynamic>)
          .map((e) => Component.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      description: json['description'] as String,
      createdBy: json['created_by'],
      lastEdition: DateTime.parse(json['last_edition'] as String),
      sites: json['sites'] as String?,
      groups: json['groups'] as String,
      project: (json['project'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardListToJson(DashboardList instance) =>
    <String, dynamic>{
      'dashboard_id': instance.dashboardId,
      'components': instance.components,
      'name': instance.name,
      'description': instance.description,
      'created_by': instance.createdBy,
      'last_edition': instance.lastEdition.toIso8601String(),
      'sites': instance.sites,
      'groups': instance.groups,
      'project': instance.project,
    };

Component _$ComponentFromJson(Map<String, dynamic> json) => Component(
      componentId: (json['component_id'] as num).toInt(),
      name: json['name'] as String,
      content: json['content'],
      dashboard: (json['dashboard'] as num).toInt(),
    );

Map<String, dynamic> _$ComponentToJson(Component instance) => <String, dynamic>{
      'component_id': instance.componentId,
      'name': instance.name,
      'content': instance.content,
      'dashboard': instance.dashboard,
    };

ContentElement _$ContentElementFromJson(Map<String, dynamic> json) =>
    ContentElement(
      sensor: (json['sensor'] as num).toInt(),
      coordinate: (json['coordinate'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ContentElementToJson(ContentElement instance) =>
    <String, dynamic>{
      'sensor': instance.sensor,
      'coordinate': instance.coordinate,
    };

PurpleContent _$PurpleContentFromJson(Map<String, dynamic> json) =>
    PurpleContent(
      sensors: (json['sensors'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toDouble()).toList()),
      ),
      pictureName: json['picture_name'] as String,
    );

Map<String, dynamic> _$PurpleContentToJson(PurpleContent instance) =>
    <String, dynamic>{
      'sensors': instance.sensors,
      'picture_name': instance.pictureName,
    };
