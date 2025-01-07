// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_medial_library_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetMediaLibrariesResponseModel _$GetMediaLibrariesResponseModelFromJson(
        Map<String, dynamic> json) =>
    GetMediaLibrariesResponseModel(
      success: json['success'] as bool?,
      mediaLibraries: (json['media_libraries'] as List<dynamic>?)
          ?.map((e) => MediaLibrary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetMediaLibrariesResponseModelToJson(
        GetMediaLibrariesResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'media_libraries': instance.mediaLibraries,
    };

MediaLibrary _$MediaLibraryFromJson(Map<String, dynamic> json) => MediaLibrary(
      mediaLibraryId: (json['media_library_id'] as num?)?.toInt(),
      project: (json['project'] as num?)?.toInt(),
      fileName: json['file_name'] as String?,
      description: json['description'],
      file: json['file'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      fileUrl: json['file_url'] as String?,
    );

Map<String, dynamic> _$MediaLibraryToJson(MediaLibrary instance) =>
    <String, dynamic>{
      'media_library_id': instance.mediaLibraryId,
      'project': instance.project,
      'file_name': instance.fileName,
      'description': instance.description,
      'file': instance.file,
      'created_at': instance.createdAt?.toIso8601String(),
      'file_url': instance.fileUrl,
    };
