import 'package:json_annotation/json_annotation.dart';

part 'owner_model.g.dart';

@JsonSerializable()
class OwnerModel {
  @JsonKey(name: "owner_id")
  int ownerId;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "logo")
  String logo;
  @JsonKey(name: "addresse")
  String? addresse;
  @JsonKey(name: "country")
  String? country;
  @JsonKey(name: "phone")
  String? phone;
  @JsonKey(name: "website")
  String? website;
  @JsonKey(name: "logo_url")
  String logoUrl;

  OwnerModel({
    required this.ownerId,
    required this.name,
    required this.logo,
    required this.addresse,
    required this.country,
    required this.phone,
    required this.website,
    required this.logoUrl,
  });

  OwnerModel copyWith({
    int? ownerId,
    String? name,
    String? logo,
    String? addresse,
    String? country,
    String? phone,
    String? website,
    String? logoUrl,
  }) =>
      OwnerModel(
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        logo: logo ?? this.logo,
        addresse: addresse ?? this.addresse,
        country: country ?? this.country,
        phone: phone ?? this.phone,
        website: website ?? this.website,
        logoUrl: logoUrl ?? this.logoUrl,
      );

  factory OwnerModel.fromJson(Map<String, dynamic> json) =>
      _$OwnerModelFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerModelToJson(this);
}
