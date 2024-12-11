// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'user_details.g.dart';

@JsonSerializable()
class UserDetails {
  @JsonKey(name: 'user_id')
  final int userId;

  final String email;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  final String title;

  final String picture;

  @JsonKey(name: 'is_staff')
  final bool isStaff;

  @JsonKey(name: 'is_superuser')
  final bool isSuperuser;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'date_joined')
  final DateTime dateJoined;

  @JsonKey(name: 'picture_url')
  final String pictureUrl;

  final String mode;

  UserDetails({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.picture,
    required this.isStaff,
    required this.isSuperuser,
    required this.isActive,
    required this.dateJoined,
    required this.pictureUrl,
    required this.mode,
  });

  /// Factory constructor for creating a new instance from a map.
  factory UserDetails.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsFromJson(json);

  /// Method for serializing the instance to a map.
  Map<String, dynamic> toJson() => _$UserDetailsToJson(this);

  @override
  String toString() {
    return 'UserDetails(userId: $userId, email: $email, firstName: $firstName, lastName: $lastName, title: $title, picture: $picture, isStaff: $isStaff, isSuperuser: $isSuperuser, isActive: $isActive, dateJoined: $dateJoined, pictureUrl: $pictureUrl, mode: $mode)';
  }
}
