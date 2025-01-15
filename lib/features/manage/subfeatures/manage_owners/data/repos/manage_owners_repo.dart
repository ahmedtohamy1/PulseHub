import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart';

abstract class ManageOwnersRepository {
  Future<Either<String, List<OwnerModel>>> getAllOwners(String token);

  Future<Either<String, bool>> createOwner(
      String token,
      String name,
      String? phone,
      String? address,
      String? city,
      String? country,
      XFile? logo);

  Future<Either<String, bool>> deleteOwner(String token, int ownerId);
}
