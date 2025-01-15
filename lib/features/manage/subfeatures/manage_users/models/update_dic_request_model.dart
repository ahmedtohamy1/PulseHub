// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:json_annotation/json_annotation.dart';

part 'update_dic_request_model.g.dart';
@JsonSerializable()
class UpdateDicRequestModel {

  final int user;
  final bool? cloudmate;
  final bool? collaboration;
  @JsonKey(name: 'project_preparation')
  final bool? projectPreparation;
  @JsonKey(name: 'active_projects')
  final bool? activeProjects;
  final bool? financial;
  final bool? administration;
  final bool? duratrans;
  @JsonKey(name: 'code_hub')
  final bool? codeHub;
  @JsonKey(name: 'business_hub')
  final bool? businessHub;
  @JsonKey(name: 'business_intelligence')
  final bool?  businessIntelligence;
  @JsonKey(name: 'sales_hub')
  final bool? salesHub;
  UpdateDicRequestModel({
    required this.user,
    required this.cloudmate,
    required this.collaboration,
    required this.projectPreparation,
    required this.activeProjects,
    required this.financial,
    required this.administration,
    required this.duratrans,
    required this.codeHub,
    required this.businessHub,
    required this.businessIntelligence,
    required this.salesHub,
  });

 
 
  Map<String, dynamic> toJson() => _$UpdateDicRequestModelToJson(this);
}
