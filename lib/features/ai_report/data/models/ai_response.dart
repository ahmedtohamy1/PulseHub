import 'package:json_annotation/json_annotation.dart';

part 'ai_response.g.dart';

@JsonSerializable()
class ResponseModel {
  final bool success;
  final ResponseData response;

  ResponseModel({
    required this.success,
    required this.response,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseModelToJson(this);
}

@JsonSerializable()
class ResponseData {
  final String message;
  @JsonKey(name: 'using_rag')
  final bool usingRag;
  final String time;
  @JsonKey(name: 'normalized_evaluation')
  final double? normalizedEvaluation;
  @JsonKey(name: 'bert_evaluation')
  final int? bertEvaluation;
  @JsonKey(name: 'retrieved_chunks')
  final String? retrievedChunks;

  ResponseData({
    required this.message,
    required this.usingRag,
    required this.time,
    this.normalizedEvaluation,
    this.bertEvaluation,
    this.retrievedChunks,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) =>
      _$ResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseDataToJson(this);
}
