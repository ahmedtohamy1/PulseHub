// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_collaborators_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCollaboratorsResponseModel _$GetCollaboratorsResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetCollaboratorsResponseModel(
      success: json['success'] as bool?,
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetCollaboratorsResponseModelToJson(
        GetCollaboratorsResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'groups': instance.groups,
    };

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      groupId: (json['group_id'] as num?)?.toInt(),
      project: (json['project'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      isViewer: json['is_viewer'] as bool?,
      isAnalyzer: json['is_analyzer'] as bool?,
      isEditor: json['is_editor'] as bool?,
      isMonitor: json['is_monitor'] as bool?,
      isManager: json['is_manager'] as bool?,
      isNotificationsSender: json['is_notifications_sender'] as bool?,
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'group_id': instance.groupId,
      'project': instance.project,
      'name': instance.name,
      'description': instance.description,
      'is_viewer': instance.isViewer,
      'is_analyzer': instance.isAnalyzer,
      'is_editor': instance.isEditor,
      'is_monitor': instance.isMonitor,
      'is_manager': instance.isManager,
      'is_notifications_sender': instance.isNotificationsSender,
      'members': instance.members,
    };

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      userId: (json['user_id'] as num?)?.toInt(),
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      title: json['title'] as String?,
      picture: json['picture'] as String?,
      ownersOrder: (json['owners_order'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      pictureUrl: json['picture_url'] as String?,
      mode: json['mode'] as String?,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'title': instance.title,
      'picture': instance.picture,
      'owners_order': instance.ownersOrder,
      'picture_url': instance.pictureUrl,
      'mode': instance.mode,
    };
