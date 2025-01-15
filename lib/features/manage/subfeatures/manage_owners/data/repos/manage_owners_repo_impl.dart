import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  Future<Either<String, bool>> createOwner(
      String token,
      String name,
      String? phone,
      String? address,
      String? city,
      String? country,
      XFile? logo) async {
    try {
      // Create base request data
      final Map<String, dynamic> requestData = {
        'name': name,
      };

      // Add optional fields only if they are not null
      if (phone != null && phone.isNotEmpty) {
        requestData['phone'] = phone;
      }
      if (address != null && address.isNotEmpty) {
        requestData['addresse'] = address;
      }
      if (city != null && city.isNotEmpty) {
        requestData['city'] = city;
      }
      if (country != null && country.isNotEmpty) {
        requestData['country'] = country;
      }

      // If logo is provided, add it as multipart file
      FormData? formData;
      if (logo != null) {
        formData = FormData.fromMap({
          ...requestData,
          'logo': await MultipartFile.fromFile(
            logo.path,
            filename: logo.name,
          ),
        });
      }

      final response = await myApiService.post(
        EndPoints.getAllOwners,
        token: token,
        data: formData ?? requestData,
      );

      if (response.statusCode == StatusCode.ok ||
          response.statusCode == StatusCode.created) {
        return right(true);
      } else {
        return left(response.statusCode.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> deleteOwner(String token, int ownerId) async {
    try {
      final response = await myApiService.delete(
        EndPoints.updateDeleteOwner,
        token: token,
        queryParameters: {'id': ownerId},
      );
      if (response.statusCode == StatusCode.ok) {
        return right(true);
      } else {
        return left(response.statusCode.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> updateOwner(
      String token,
      int ownerId,
      String name,
      String? phone,
      String? address,
      String? country,
      XFile? logo,
      String? website) async {
    try {
      final Map<String, dynamic> requestData = {
        'name': name,
      };
      FormData? formData;
 
      // Add optional fields only if they are not null
      if (phone != null && phone.isNotEmpty) {
          requestData['phone'] = phone;
      }
      if (address != null && address.isNotEmpty) {
        requestData['addresse'] = address;
      }
      if (country != null && country.isNotEmpty) {
        requestData['country'] = country;
      }
      if (website != null && website.isNotEmpty) {
        requestData['website'] = website;
      }

      // If logo is provided, add it as multipart file
      if (logo != null) {
        formData = FormData.fromMap({
          ...requestData,
          'logo': await MultipartFile.fromFile(logo.path),
        });
      }

      final response = await myApiService.post(
        EndPoints.updateDeleteOwner,
        token: token,
        queryParameters: {'id': ownerId},
        data: formData ?? requestData,
      );
      if (response.statusCode == StatusCode.ok ||
          response.statusCode == StatusCode.created) {
        return right(true);
      } else {
        return left(response.statusCode.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }
}
