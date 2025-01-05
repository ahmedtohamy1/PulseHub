import 'package:json_annotation/json_annotation.dart';

part 'sensor_activity_log_model.g.dart';

@JsonSerializable()
class SensorActivityLog {
  @JsonKey(name: "success")
  final bool? success;
  @JsonKey(name: "sensor_signals_tickets")
  final List<Ticket>? sensorSignalsTickets;

  SensorActivityLog({
    this.success,
    this.sensorSignalsTickets,
  });

  factory SensorActivityLog.fromJson(Map<String, dynamic> json) =>
      _$SensorActivityLogFromJson(json);

  Map<String, dynamic> toJson() => _$SensorActivityLogToJson(this);
}

@JsonSerializable()
class Ticket {
  @JsonKey(name: "ticket_id")
  final int? ticketId;
  @JsonKey(name: "created_at")
  final String? createdAt;
  @JsonKey(name: "sensor")
  final int? sensor;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "description")
  final String? description;
  @JsonKey(name: "open")
  final bool? open;
  @JsonKey(name: "ticket_users")
  final List<TicketUser>? ticketUsers;

  Ticket({
    this.ticketId,
    this.createdAt,
    this.sensor,
    this.name,
    this.description,
    this.open,
    this.ticketUsers,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);
}

@JsonSerializable()
class TicketUser {
  @JsonKey(name: "user_id")
  final int? userId;
  @JsonKey(name: "first_name")
  final String? firstName;
  @JsonKey(name: "last_name")
  final String? lastName;
  @JsonKey(name: "picture_url")
  final String? pictureUrl;

  TicketUser({
    this.userId,
    this.firstName,
    this.lastName,
    this.pictureUrl,
  });

  factory TicketUser.fromJson(Map<String, dynamic> json) =>
      _$TicketUserFromJson(json);
  Map<String, dynamic> toJson() => _$TicketUserToJson(this);
}
