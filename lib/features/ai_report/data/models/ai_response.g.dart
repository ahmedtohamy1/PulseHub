// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseModel _$ResponseModelFromJson(Map<String, dynamic> json) =>
    ResponseModel(
      success: json['success'] as bool,
      response: ResponseData.fromJson(json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResponseModelToJson(ResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'response': instance.response,
    };

ResponseData _$ResponseDataFromJson(Map<String, dynamic> json) => ResponseData(
      message: json['message'] as String,
      usingRag: json['using_rag'] as bool,
      time: json['time'] as String,
      normalizedEvaluation: (json['normalized_evaluation'] as num?)?.toDouble(),
      bertEvaluation: (json['bert_evaluation'] as num?)?.toInt(),
      retrievedChunks: json['retrieved_chunks'] as String?,
    );

Map<String, dynamic> _$ResponseDataToJson(ResponseData instance) =>
    <String, dynamic>{
      'message': instance.message,
      'using_rag': instance.usingRag,
      'time': instance.time,
      'normalized_evaluation': instance.normalizedEvaluation,
      'bert_evaluation': instance.bertEvaluation,
      'retrieved_chunks': instance.retrievedChunks,
    };
