// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dic_services_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DicServicesResponse _$DicServicesResponseFromJson(Map<String, dynamic> json) =>
    DicServicesResponse(
      success: json['success'] as bool,
      dicServicesList: (json['dicServicesList'] as List<dynamic>)
          .map((e) => DicService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DicServicesResponseToJson(
        DicServicesResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'dicServicesList': instance.dicServicesList,
    };

DicService _$DicServiceFromJson(Map<String, dynamic> json) => DicService(
      dicServicesId: (json['dic_services_id'] as num).toInt(),
      user: (json['user'] as num).toInt(),
      cloudmate: json['cloudmate'] as bool,
      collaboration: json['collaboration'] as bool,
      projectPreparation: json['project_preparation'] as bool,
      activeProjects: json['active_projects'] as bool,
      financial: json['financial'] as bool,
      administration: json['administration'] as bool,
      duratrans: json['duratrans'] as bool,
      codeHub: json['code_hub'] as bool,
      businessHub: json['business_hub'] as bool,
      businessIntelligence: json['business_intelligence'] as bool,
      salesHub: json['sales_hub'] as bool,
    );

Map<String, dynamic> _$DicServiceToJson(DicService instance) =>
    <String, dynamic>{
      'dic_services_id': instance.dicServicesId,
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
