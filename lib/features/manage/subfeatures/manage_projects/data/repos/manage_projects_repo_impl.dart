import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/networking/end_points.dart';
import 'package:pulsehub/core/networking/my_api.dart';
import 'package:pulsehub/core/networking/status_code.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/get_all_projects_response_model.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_projects/data/models/owner_model.dart'
    as owner;

import 'manage_projects_repo.dart';

@Injectable(as: ManageProjectsRepository)
class ManageProjectsRepositoryImpl implements ManageProjectsRepository {
  final MyApi myApiService;
  ManageProjectsRepositoryImpl(this.myApiService);

  @override
  Future<Either<String, GetAllProjectsResponseModel>> getAllProjects(
      String token) async {
    try {
      final response = await myApiService.get(
        EndPoints.getProject,
        token: token,
      );
      if (response.statusCode == StatusCode.ok) {
        return right(GetAllProjectsResponseModel.fromJson(response.data));
      } else {
        return left(response.statusCode.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, List<owner.OwnerModel>>> getAllOwners(
      String token) async {
    try {
      final response =
          await myApiService.get(EndPoints.getAllOwners, token: token);
      if (response.statusCode == StatusCode.ok) {
        final List<dynamic> data = response.data as List<dynamic>;
        final owners = data
            .map((json) =>
                owner.OwnerModel.fromJson(json as Map<String, dynamic>))
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
  Future<Either<String, bool>> createProject(
      String token,
      String title,
      int ownerId,
      XFile? picture,
      String? acronym,
      String? consultant,
      String? contractor) async {
    try {
      // Add optional fields only if they are not null
      final Map<String, dynamic> requestData = {
        'title': title,
        'owner': ownerId,
      };
      if (acronym != null && acronym.isNotEmpty) {
        requestData['acronym'] = acronym;
      }
      if (consultant != null && consultant.isNotEmpty) {
        requestData['consultant'] = consultant;
      }
      if (contractor != null && contractor.isNotEmpty) {
        requestData['contractor'] = contractor;
      }
      if (picture != null) {
          requestData['picture'] = await MultipartFile.fromFile(
          picture.path,
          filename: picture.name,
        );
      }
      final response = await myApiService.post(
        EndPoints.getProject,
        token: token,
        data: requestData,
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
