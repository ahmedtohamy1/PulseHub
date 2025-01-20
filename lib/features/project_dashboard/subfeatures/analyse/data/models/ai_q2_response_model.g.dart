// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_q2_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiQ2ResponseModel _$AiQ2ResponseModelFromJson(Map<String, dynamic> json) =>
    AiQ2ResponseModel(
      success: json['success'] as bool,
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AiQ2ResponseModelToJson(AiQ2ResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'response': instance.response,
    };

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      message: json['message'] as String,
      time: json['time'] as String,
      normalizedEvaluation: (json['normalized_evaluation'] as num).toDouble(),
      bertEvaluation: (json['bert_evaluation'] as num).toDouble(),
      retrievedChunks: json['retrieved_chunks'] as String,
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'message': instance.message,
      'time': instance.time,
      'normalized_evaluation': instance.normalizedEvaluation,
      'bert_evaluation': instance.bertEvaluation,
      'retrieved_chunks': instance.retrievedChunks,
    };
