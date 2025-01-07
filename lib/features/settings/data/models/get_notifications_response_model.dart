import 'package:json_annotation/json_annotation.dart';

part 'get_notifications_response_model.g.dart';

@JsonSerializable()
class GetNotificationResponseModel {
  @JsonKey(name: "success")
  bool? success;
  @JsonKey(name: "notifications")
  List<Notification>? notifications;

  GetNotificationResponseModel({
    this.success,
    this.notifications,
  });

  GetNotificationResponseModel copyWith({
    bool? success,
    List<Notification>? notifications,
  }) =>
      GetNotificationResponseModel(
        success: success ?? this.success,
        notifications: notifications ?? this.notifications,
      );

  factory GetNotificationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetNotificationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetNotificationResponseModelToJson(this);
}

@JsonSerializable()
class Notification {
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "warnings")
  List<Warning>? warnings;

  Notification({
    this.title,
    this.warnings,
  });

  Notification copyWith({
    String? title,
    List<Warning>? warnings,
  }) =>
      Notification(
        title: title ?? this.title,
        warnings: warnings ?? this.warnings,
      );

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}

@JsonSerializable()
class Warning {
  @JsonKey(name: "sensor_id")
  int? sensorId;
  @JsonKey(name: "tickets_details")
  List<TicketsDetail>? ticketsDetails;

  Warning({
    this.sensorId,
    this.ticketsDetails,
  });

  Warning copyWith({
    int? sensorId,
    List<TicketsDetail>? ticketsDetails,
  }) =>
      Warning(
        sensorId: sensorId ?? this.sensorId,
        ticketsDetails: ticketsDetails ?? this.ticketsDetails,
      );

  factory Warning.fromJson(Map<String, dynamic> json) =>
      _$WarningFromJson(json);

  Map<String, dynamic> toJson() => _$WarningToJson(this);
}

@JsonSerializable()
class TicketsDetail {
  @JsonKey(name: "ticket_name")
  String? ticketName;
  @JsonKey(name: "ticket_description")
  String? ticketDescription;
  @JsonKey(name: "unseen_messages")
  int? unseenMessages;

  TicketsDetail({
    this.ticketName,
    this.ticketDescription,
    this.unseenMessages,
  });

  TicketsDetail copyWith({
    String? ticketName,
    String? ticketDescription,
    int? unseenMessages,
  }) =>
      TicketsDetail(
        ticketName: ticketName ?? this.ticketName,
        ticketDescription: ticketDescription ?? this.ticketDescription,
        unseenMessages: unseenMessages ?? this.unseenMessages,
      );

  factory TicketsDetail.fromJson(Map<String, dynamic> json) =>
      _$TicketsDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TicketsDetailToJson(this);
}
