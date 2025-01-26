import 'package:json_annotation/json_annotation.dart';

part 'owner_model.g.dart';

@JsonSerializable()
class OwnerModel {
  @JsonKey(name: "count")
  int count;
  @JsonKey(name: "next")
  dynamic next;
  @JsonKey(name: "previous")
  dynamic previous;
  @JsonKey(name: "results")
  List<Owner> results;

  OwnerModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  OwnerModel copyWith({
    int? count,
    dynamic next,
    dynamic previous,
    List<Owner>? results,
  }) =>
      OwnerModel(
        count: count ?? this.count,
        next: next ?? this.next,
        previous: previous ?? this.previous,
        results: results ?? this.results,
      );

  factory OwnerModel.fromJson(Map<String, dynamic> json) =>
      _$OwnerModelFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerModelToJson(this);
}

@JsonSerializable()
class Owner {
  @JsonKey(name: "owner_id")
  int ownerId;
  @JsonKey(name: "name")
  String name;
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

  Owner({
    required this.ownerId,
    required this.name,
    this.addresse,
    this.country,
    this.phone,
    this.website,
    required this.logoUrl,
  });

  Owner copyWith({
    int? ownerId,
    String? name,
    String? addresse,
    String? country,
    String? phone,
    String? website,
    String? logoUrl,
  }) =>
      Owner(
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        addresse: addresse ?? this.addresse,
        country: country ?? this.country,
        phone: phone ?? this.phone,
        website: website ?? this.website,
        logoUrl: logoUrl ?? this.logoUrl,
      );

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}
