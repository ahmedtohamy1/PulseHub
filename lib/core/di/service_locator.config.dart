// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/cubit/auth_cubit.dart' as _i698;
import '../../features/auth/data/repositories/auth_repository.dart' as _i573;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../networking/dio_module.dart' as _i444;
import '../networking/my_api.dart' as _i713;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dioModule = _$DioModule();
    gh.lazySingleton<_i361.Dio>(() => dioModule.provideDio());
    gh.lazySingleton<_i713.MyApi>(() => _i713.MyApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i573.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i713.MyApi>()));
    gh.factory<_i698.AuthCubit>(
        () => _i698.AuthCubit(gh<_i573.AuthRepository>()));
    return this;
  }
}

class _$DioModule extends _i444.DioModule {}
