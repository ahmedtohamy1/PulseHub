import 'package:json_annotation/json_annotation.dart';

part 'ai_q2_response_model.g.dart';

@JsonSerializable()
class AiQ2ResponseModel {
  @JsonKey(name: "success")
  bool success;
  @JsonKey(name: "response")
  Response response;

  AiQ2ResponseModel({
    required this.success,
    required this.response,
  });

  factory AiQ2ResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AiQ2ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AiQ2ResponseModelToJson(this);
}

@JsonSerializable()
class Response {
  @JsonKey(name: "message")
  String message;
  @JsonKey(name: "time")
  String time;
  @JsonKey(name: "normalized_evaluation")
  double normalizedEvaluation;
  @JsonKey(name: "bert_evaluation")
  double bertEvaluation;
  @JsonKey(name: "retrieved_chunks")
  String retrievedChunks;

  Response({
    required this.message,
    required this.time,
    required this.normalizedEvaluation,
    required this.bertEvaluation,
    required this.retrievedChunks,
  });

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
