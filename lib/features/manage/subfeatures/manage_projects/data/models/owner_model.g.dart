// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerModel _$OwnerModelFromJson(Map<String, dynamic> json) => OwnerModel(
      count: (json['count'] as num).toInt(),
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => Owner.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OwnerModelToJson(OwnerModel instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
      ownerId: (json['owner_id'] as num).toInt(),
      name: json['name'] as String,
      addresse: json['addresse'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String,
    );

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
      'owner_id': instance.ownerId,
      'name': instance.name,
      'addresse': instance.addresse,
      'country': instance.country,
      'phone': instance.phone,
      'website': instance.website,
      'logo_url': instance.logoUrl,
    };
