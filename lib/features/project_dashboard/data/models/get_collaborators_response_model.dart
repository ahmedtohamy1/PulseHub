import 'package:json_annotation/json_annotation.dart';

part 'get_collaborators_response_model.g.dart';

@JsonSerializable()
class GetCollaboratorsResponseModel {
  @JsonKey(name: "success")
  bool? success;
  @JsonKey(name: "groups")
  List<Group>? groups;

  GetCollaboratorsResponseModel({
    this.success,
    this.groups,
  });

  GetCollaboratorsResponseModel copyWith({
    bool? success,
    List<Group>? groups,
  }) =>
      GetCollaboratorsResponseModel(
        success: success ?? this.success,
        groups: groups ?? this.groups,
      );

  factory GetCollaboratorsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetCollaboratorsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetCollaboratorsResponseModelToJson(this);
}

@JsonSerializable()
class Group {
  @JsonKey(name: "group_id")
  int? groupId;
  @JsonKey(name: "project")
  int? project;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "is_viewer")
  bool? isViewer;
  @JsonKey(name: "is_analyzer")
  bool? isAnalyzer;
  @JsonKey(name: "is_editor")
  bool? isEditor;
  @JsonKey(name: "is_monitor")
  bool? isMonitor;
  @JsonKey(name: "is_manager")
  bool? isManager;
  @JsonKey(name: "is_notifications_sender")
  bool? isNotificationsSender;
  @JsonKey(name: "members")
  List<Member>? members;

  Group({
    this.groupId,
    this.project,
    this.name,
    this.description,
    this.isViewer,
    this.isAnalyzer,
    this.isEditor,
    this.isMonitor,
    this.isManager,
    this.isNotificationsSender,
    this.members,
  });

  Group copyWith({
    int? groupId,
    int? project,
    String? name,
    String? description,
    bool? isViewer,
    bool? isAnalyzer,
    bool? isEditor,
    bool? isMonitor,
    bool? isManager,
    bool? isNotificationsSender,
    List<Member>? members,
  }) =>
      Group(
        groupId: groupId ?? this.groupId,
        project: project ?? this.project,
        name: name ?? this.name,
        description: description ?? this.description,
        isViewer: isViewer ?? this.isViewer,
        isAnalyzer: isAnalyzer ?? this.isAnalyzer,
        isEditor: isEditor ?? this.isEditor,
        isMonitor: isMonitor ?? this.isMonitor,
        isManager: isManager ?? this.isManager,
        isNotificationsSender:
            isNotificationsSender ?? this.isNotificationsSender,
        members: members ?? this.members,
      );

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class Member {
  @JsonKey(name: "user_id")
  int? userId;
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "first_name")
  String? firstName;
  @JsonKey(name: "last_name")
  String? lastName;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "picture")
  String? picture;
  @JsonKey(name: "owners_order")
  List<int>? ownersOrder;
  @JsonKey(name: "picture_url")
  String? pictureUrl;
  @JsonKey(name: "mode")
  String? mode;

  Member({
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.title,
    this.picture,
    this.ownersOrder,
    this.pictureUrl,
    this.mode,
  });

  Member copyWith({
    int? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? title,
    String? picture,
    List<int>? ownersOrder,
    String? pictureUrl,
    String? mode,
  }) =>
      Member(
        userId: userId ?? this.userId,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        title: title ?? this.title,
        picture: picture ?? this.picture,
        ownersOrder: ownersOrder ?? this.ownersOrder,
        pictureUrl: pictureUrl ?? this.pictureUrl,
        mode: mode ?? this.mode,
      );

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}
