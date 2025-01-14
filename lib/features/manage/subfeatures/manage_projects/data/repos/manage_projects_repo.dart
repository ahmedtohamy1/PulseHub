import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart'
    as owner;

abstract class ManageProjectsRepository {
  Future<Either<String, GetAllProjectsResponseModel>> getAllProjects(
      String token);
  Future<Either<String, List<owner.OwnerModel>>> getAllOwners(String token);
  Future<Either<String, bool>> createOwner(
      String token,
      String name,
      String? phone,
      String? address,
      String? city,
      String? country,
      XFile? logo);
}
