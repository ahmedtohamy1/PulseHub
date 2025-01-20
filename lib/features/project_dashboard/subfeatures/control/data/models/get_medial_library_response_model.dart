import 'package:json_annotation/json_annotation.dart';

part 'get_medial_library_response_model.g.dart';

@JsonSerializable()
class GetMediaLibrariesResponseModel {
  @JsonKey(name: "success")
  bool? success;
  @JsonKey(name: "media_libraries")
  List<MediaLibrary>? mediaLibraries;

  GetMediaLibrariesResponseModel({
    this.success,
    this.mediaLibraries,
  });

  GetMediaLibrariesResponseModel copyWith({
    bool? success,
    List<MediaLibrary>? mediaLibraries,
  }) =>
      GetMediaLibrariesResponseModel(
        success: success ?? this.success,
        mediaLibraries: mediaLibraries ?? this.mediaLibraries,
      );

  factory GetMediaLibrariesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetMediaLibrariesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetMediaLibrariesResponseModelToJson(this);
}

@JsonSerializable()
class MediaLibrary {
  @JsonKey(name: "media_library_id")
  int? mediaLibraryId;
  @JsonKey(name: "project")
  int? project;
  @JsonKey(name: "file_name")
  String? fileName;
  @JsonKey(name: "description")
  dynamic description;
  @JsonKey(name: "file")
  String? file;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "file_url")
  String? fileUrl;

  MediaLibrary({
    this.mediaLibraryId,
    this.project,
    this.fileName,
    this.description,
    this.file,
    this.createdAt,
    this.fileUrl,
  });

  MediaLibrary copyWith({
    int? mediaLibraryId,
    int? project,
    String? fileName,
    dynamic description,
    String? file,
    DateTime? createdAt,
    String? fileUrl,
  }) =>
      MediaLibrary(
        mediaLibraryId: mediaLibraryId ?? this.mediaLibraryId,
        project: project ?? this.project,
        fileName: fileName ?? this.fileName,
        description: description ?? this.description,
        file: file ?? this.file,
        createdAt: createdAt ?? this.createdAt,
        fileUrl: fileUrl ?? this.fileUrl,
      );

  factory MediaLibrary.fromJson(Map<String, dynamic> json) =>
      _$MediaLibraryFromJson(json);

  Map<String, dynamic> toJson() => _$MediaLibraryToJson(this);
}
