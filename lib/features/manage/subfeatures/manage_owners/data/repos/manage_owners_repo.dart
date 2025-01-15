import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart';

abstract class ManageOwnersRepository {
  Future<Either<String, List<OwnerModel>>> getAllOwners(String token);
}
