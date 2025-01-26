// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dashboards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDashboards _$ProjectDashboardsFromJson(Map<String, dynamic> json) =>
    ProjectDashboards(
      success: json['success'] as bool,
      dashboards: (json['dashboards'] as List<dynamic>)
          .map((e) => Dashboard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProjectDashboardsToJson(ProjectDashboards instance) =>
    <String, dynamic>{
      'success': instance.success,
      'dashboards': instance.dashboards,
    };

Dashboard _$DashboardFromJson(Map<String, dynamic> json) => Dashboard(
      dashboardId: (json['dashboard_id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String?,
      lastEdition: json['last_edition'] as String,
      sites: json['sites'] as String?,
      groups: json['groups'] as String,
      project: (json['project'] as num).toInt(),
      components: (json['components'] as List<dynamic>)
          .map((e) => Component.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
      'dashboard_id': instance.dashboardId,
      'name': instance.name,
      'description': instance.description,
      'created_by': instance.createdBy,
      'last_edition': instance.lastEdition,
      'sites': instance.sites,
      'groups': instance.groups,
      'project': instance.project,
      'components': instance.components,
    };

Component _$ComponentFromJson(Map<String, dynamic> json) => Component(
      componentId: (json['component_id'] as num).toInt(),
      name: json['name'] as String,
      content: json['content'] as Map<String, dynamic>?,
      dashboard: (json['dashboard'] as num).toInt(),
    );

Map<String, dynamic> _$ComponentToJson(Component instance) => <String, dynamic>{
      'component_id': instance.componentId,
      'name': instance.name,
      'content': instance.content,
      'dashboard': instance.dashboard,
    };
