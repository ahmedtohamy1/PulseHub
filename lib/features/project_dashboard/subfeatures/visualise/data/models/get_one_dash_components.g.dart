// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_one_dash_components.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetOneDashComponents _$GetOneDashComponentsFromJson(
        Map<String, dynamic> json) =>
    GetOneDashComponents(
      success: json['success'] as bool,
      dashboard: Dashboard.fromJson(json['dashboard'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetOneDashComponentsToJson(
        GetOneDashComponents instance) =>
    <String, dynamic>{
      'success': instance.success,
      'dashboard': instance.dashboard,
    };

Dashboard _$DashboardFromJson(Map<String, dynamic> json) => Dashboard(
      dashboardId: (json['dashboard_id'] as num).toInt(),
      components: (json['components'] as List<dynamic>)
          .map((e) => Component.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      description: json['description'] as String,
      createdBy: json['created_by'],
      lastEdition: DateTime.parse(json['last_edition'] as String),
      sites: json['sites'],
      groups: json['groups'] as String,
      project: (json['project'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
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
      content: json['content'] == null
          ? null
          : Content.fromJson(json['content'] as Map<String, dynamic>),
      dashboard: (json['dashboard'] as num).toInt(),
    );

Map<String, dynamic> _$ComponentToJson(Component instance) => <String, dynamic>{
      'component_id': instance.componentId,
      'name': instance.name,
      'content': instance.content,
      'dashboard': instance.dashboard,
    };

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
      sensors: (json['sensors'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toDouble()).toList()),
      ),
      pictureName: json['picture_name'] as String,
    );

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'sensors': instance.sensors,
      'picture_name': instance.pictureName,
    };
