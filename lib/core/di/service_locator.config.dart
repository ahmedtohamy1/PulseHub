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

import '../../features/ai_report/cubit/ai_report_cubit.dart' as _i782;
import '../../features/ai_report/data/ai_report_repo.dart' as _i767;
import '../../features/ai_report/data/ai_report_repo_impl.dart' as _i1064;
import '../../features/auth/cubit/auth_cubit.dart' as _i698;
import '../../features/auth/data/repositories/auth_repository.dart' as _i573;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/dics/cubit/dic_cubit.dart' as _i819;
import '../../features/dics/data/repos/dic_repo.dart' as _i90;
import '../../features/dics/data/repos/dic_repo_impl.dart' as _i1046;
import '../../features/project_dashboard/cubit/project_dashboard_cubit.dart'
    as _i495;
import '../../features/project_dashboard/data/repos/dash_repo.dart' as _i346;
import '../../features/project_dashboard/data/repos/dash_repo_impl.dart'
    as _i503;
import '../../features/projects/cubit/cubit/projects_cubit.dart' as _i616;
import '../../features/projects/data/repos/proects_repo_impl.dart' as _i12;
import '../../features/projects/data/repos/projects_repo.dart' as _i234;
import '../../features/settings/cubit/settings_cubit.dart' as _i960;
import '../../features/settings/data/repos/settings_repo.dart' as _i878;
import '../../features/settings/data/repos/settings_repo_impl.dart' as _i181;
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
    gh.lazySingleton<_i346.DashRepository>(
        () => _i503.DashRepoImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i90.DicRepository>(
        () => _i1046.DicRepoImpl(gh<_i713.MyApi>()));
    gh.factory<_i495.ProjectDashboardCubit>(
        () => _i495.ProjectDashboardCubit(gh<_i346.DashRepository>()));
    gh.lazySingleton<_i573.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i767.AiReportRepository>(
        () => _i1064.AiReportRepositoryImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i234.ProjectsRepository>(
        () => _i12.ProjectsRepoImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i878.SettingsRepository>(
        () => _i181.SettingsRepoImpl(gh<_i713.MyApi>()));
    gh.factory<_i782.AiReportCubit>(
        () => _i782.AiReportCubit(gh<_i767.AiReportRepository>()));
    gh.factory<_i960.SettingsCubit>(
        () => _i960.SettingsCubit(gh<_i878.SettingsRepository>()));
    gh.factory<_i698.AuthCubit>(
        () => _i698.AuthCubit(gh<_i573.AuthRepository>()));
    gh.factory<_i819.DicCubit>(() => _i819.DicCubit(
          gh<_i90.DicRepository>(),
          gh<_i878.SettingsRepository>(),
        ));
    gh.factory<_i616.ProjectsCubit>(
        () => _i616.ProjectsCubit(gh<_i234.ProjectsRepository>()));
    return this;
  }
}

class _$DioModule extends _i444.DioModule {}
