// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_dic_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDicRequestModel _$UpdateDicRequestModelFromJson(
        Map<String, dynamic> json) =>
    UpdateDicRequestModel(
      user: (json['user'] as num).toInt(),
      cloudmate: json['cloudmate'] as bool?,
      collaboration: json['collaboration'] as bool?,
      projectPreparation: json['project_preparation'] as bool?,
      activeProjects: json['active_projects'] as bool?,
      financial: json['financial'] as bool?,
      administration: json['administration'] as bool?,
      duratrans: json['duratrans'] as bool?,
      codeHub: json['code_hub'] as bool?,
      businessHub: json['business_hub'] as bool?,
      businessIntelligence: json['business_intelligence'] as bool?,
      salesHub: json['sales_hub'] as bool?,
    );

Map<String, dynamic> _$UpdateDicRequestModelToJson(
        UpdateDicRequestModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'cloudmate': instance.cloudmate,
      'collaboration': instance.collaboration,
      'project_preparation': instance.projectPreparation,
      'active_projects': instance.activeProjects,
      'financial': instance.financial,
      'administration': instance.administration,
      'duratrans': instance.duratrans,
      'code_hub': instance.codeHub,
      'business_hub': instance.businessHub,
      'business_intelligence': instance.businessIntelligence,
      'sales_hub': instance.salesHub,
    };
