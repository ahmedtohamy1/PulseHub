// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerModel _$OwnerModelFromJson(Map<String, dynamic> json) => OwnerModel(
      ownerId: (json['owner_id'] as num).toInt(),
      name: json['name'] as String,
      logo: json['logo'] as String?,
      addresse: json['addresse'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String,
    );

Map<String, dynamic> _$OwnerModelToJson(OwnerModel instance) =>
    <String, dynamic>{
      'owner_id': instance.ownerId,
      'name': instance.name,
      'logo': instance.logo,
      'addresse': instance.addresse,
      'country': instance.country,
      'phone': instance.phone,
      'website': instance.website,
      'logo_url': instance.logoUrl,
    };
