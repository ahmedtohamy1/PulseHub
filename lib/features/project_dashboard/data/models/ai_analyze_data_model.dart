import 'package:json_annotation/json_annotation.dart';

part 'ai_analyze_data_model.g.dart';

@JsonSerializable()
class AiAnalyzeDataModel {
  final bool success;
  final String message;

  AiAnalyzeDataModel({
    required this.success,
    required this.message,
  });

  factory AiAnalyzeDataModel.fromJson(Map<String, dynamic> json) =>
      _$AiAnalyzeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AiAnalyzeDataModelToJson(this);
}
