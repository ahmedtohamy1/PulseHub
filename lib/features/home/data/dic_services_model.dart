import 'package:json_annotation/json_annotation.dart';

part 'dic_services_model.g.dart';

@JsonSerializable()
class DicServicesResponse {
  final bool success;
  final List<DicService> dicServicesList;

  DicServicesResponse({
    required this.success,
    required this.dicServicesList,
  });

  factory DicServicesResponse.fromJson(Map<String, dynamic> json) {
    final dicServices = json['dic_services'];
    List<DicService> parsedList;

    if (dicServices is Map<String, dynamic>) {
      parsedList = [DicService.fromJson(dicServices)];
    } else if (dicServices is List) {
      parsedList = dicServices
          .map<DicService>((service) => DicService.fromJson(service))
          .toList();
    } else {
      parsedList = [];
    }

    return DicServicesResponse(
      success: json['success'] as bool,
      dicServicesList: parsedList,
    );
  }

  Map<String, dynamic> toJson() => _$DicServicesResponseToJson(this);
}

@JsonSerializable()
class DicService {
  @JsonKey(name: 'dic_services_id')
  final int dicServicesId;
  final int user;
  final bool cloudmate;
  final bool collaboration;
  final bool projectPreparation;
  final bool activeProjects;
  final bool financial;
  final bool administration;

  DicService({
    required this.dicServicesId,
    required this.user,
    required this.cloudmate,
    required this.collaboration,
    required this.projectPreparation,
    required this.activeProjects,
    required this.financial,
    required this.administration,
  });

  factory DicService.fromJson(Map<String, dynamic> json) {
    return DicService(
      dicServicesId: json['dic_services_id'] as int,
      user: json['user'] as int,
      cloudmate: json['cloudmate'] as bool? ?? false,
      collaboration: json['collaboration'] as bool? ?? false,
      projectPreparation: json['project_preparation'] as bool? ?? false,
      activeProjects: json['active_projects'] as bool? ?? false,
      financial: json['financial'] as bool? ?? false,
      administration: json['administration'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$DicServiceToJson(this);
}
