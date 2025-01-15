import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart';

import 'manage_owners_repo.dart';

@Injectable(as: ManageOwnersRepository)
class ManageOwnersRepositoryImpl implements ManageOwnersRepository {
  final MyApi myApiService;
  ManageOwnersRepositoryImpl(this.myApiService);
  @override
  Future<Either<String, List<OwnerModel>>> getAllOwners(String token) async {
    try {
      final response =
          await myApiService.get(EndPoints.getAllOwners, token: token);
      if (response.statusCode == StatusCode.ok) {
        final List<dynamic> data = response.data as List<dynamic>;
        final owners = data
            .map((json) => OwnerModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return right(owners);
      } else {
        return left(response.statusCode.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }
}
