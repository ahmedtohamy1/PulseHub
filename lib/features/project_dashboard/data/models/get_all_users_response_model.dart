import 'package:json_annotation/json_annotation.dart';

part 'get_all_users_response_model.g.dart';
@JsonSerializable()
class GetAllResponseModel {
  @JsonKey(name: "count")
  int count;
  @JsonKey(name: "next")
  String next;
  @JsonKey(name: "previous")
  dynamic previous;
  @JsonKey(name: "results")
  Results results;

  GetAllResponseModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  GetAllResponseModel copyWith({
    int? count,
    String? next,
    dynamic previous,
    Results? results,
  }) =>
      GetAllResponseModel(
        count: count ?? this.count,
        next: next ?? this.next,
        previous: previous ?? this.previous,
        results: results ?? this.results,
      );

  factory GetAllResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetAllResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllResponseModelToJson(this);
}

@JsonSerializable()
class Results {
  @JsonKey(name: "success")
  bool success;
  @JsonKey(name: "users")
  List<User> users;

  Results({
    required this.success,
    required this.users,
  });

  Results copyWith({
    bool? success,
    List<User>? users,
  }) =>
      Results(
        success: success ?? this.success,
        users: users ?? this.users,
      );

  factory Results.fromJson(Map<String, dynamic> json) =>
      _$ResultsFromJson(json);

  Map<String, dynamic> toJson() => _$ResultsToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "password")
  String password;
  @JsonKey(name: "last_login")
  DateTime? lastLogin;
  @JsonKey(name: "is_superuser")
  bool isSuperuser;
  @JsonKey(name: "email")
  String email;
  @JsonKey(name: "first_name")
  String firstName;
  @JsonKey(name: "last_name")
  String lastName;
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "is_active")
  bool isActive;
  @JsonKey(name: "is_staff")
  bool isStaff;
  @JsonKey(name: "date_joined")
  DateTime dateJoined;
  @JsonKey(name: "date_updated")
  DateTime dateUpdated;
  @JsonKey(name: "secret_key")
  String secretKey;
  @JsonKey(name: "temp_otp_token")
  String tempOtpToken;
  @JsonKey(name: "max_active_sessions")
  int maxActiveSessions;
  @JsonKey(name: "owners_order")
  List<int> ownersOrder;
  @JsonKey(name: "mode")
  String mode;
  @JsonKey(name: "mfa")
  bool mfa;
  @JsonKey(name: "picture_url")
  String pictureUrl;

  User({
    required this.userId,
    required this.password,
    required this.lastLogin,
    required this.isSuperuser,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.isActive,
    required this.isStaff,
    required this.dateJoined,
    required this.dateUpdated,
    required this.secretKey,
    required this.tempOtpToken,
    required this.maxActiveSessions,
    required this.ownersOrder,
    required this.mode,
    required this.mfa,
    required this.pictureUrl,
  });

  User copyWith({
    int? userId,
    String? password,
    DateTime? lastLogin,
    bool? isSuperuser,
    String? email,
    String? firstName,
    String? lastName,
    String? title,
    bool? isActive,
    bool? isStaff,
    DateTime? dateJoined,
    DateTime? dateUpdated,
    String? secretKey,
    String? tempOtpToken,
    int? maxActiveSessions,
    List<int>? ownersOrder,
    String? mode,
    bool? mfa,
    String? pictureUrl,
  }) =>
      User(
        userId: userId ?? this.userId,
        password: password ?? this.password,
        lastLogin: lastLogin ?? this.lastLogin,
        isSuperuser: isSuperuser ?? this.isSuperuser,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        title: title ?? this.title,
        isActive: isActive ?? this.isActive,
        isStaff: isStaff ?? this.isStaff,
        dateJoined: dateJoined ?? this.dateJoined,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        secretKey: secretKey ?? this.secretKey,
        tempOtpToken: tempOtpToken ?? this.tempOtpToken,
        maxActiveSessions: maxActiveSessions ?? this.maxActiveSessions,
        ownersOrder: ownersOrder ?? this.ownersOrder,
        mode: mode ?? this.mode,
        mfa: mfa ?? this.mfa,
        pictureUrl: pictureUrl ?? this.pictureUrl,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
