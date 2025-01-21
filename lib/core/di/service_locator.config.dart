// dart format width=80
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
import '../../features/manage/data/repos/manage_repo.dart' as _i87;
import '../../features/manage/data/repos/manage_repo_impl.dart' as _i176;
import '../../features/manage/subfeatures/manage_owners/cubit/manage_owners_cubit.dart'
    as _i694;
import '../../features/manage/subfeatures/manage_owners/data/repos/manage_owners_repo.dart'
    as _i133;
import '../../features/manage/subfeatures/manage_owners/data/repos/manage_owners_repo_impl.dart'
    as _i1045;
import '../../features/manage/subfeatures/manage_projects/cubit/manage_projects_cubit.dart'
    as _i446;
import '../../features/manage/subfeatures/manage_projects/data/repos/manage_projects_repo.dart'
    as _i423;
import '../../features/manage/subfeatures/manage_projects/data/repos/manage_projects_repo_impl.dart'
    as _i320;
import '../../features/manage/subfeatures/manage_sensors/cubit/manage_sensors_cubit.dart'
    as _i988;
import '../../features/manage/subfeatures/manage_sensors/data/repos/manage_sensors_repo.dart'
    as _i1047;
import '../../features/manage/subfeatures/manage_sensors/data/repos/manage_sensors_repo_impl.dart'
    as _i62;
import '../../features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart'
    as _i3;
import '../../features/manage/subfeatures/manage_users/data/repos/manage_users_repo.dart'
    as _i818;
import '../../features/manage/subfeatures/manage_users/data/repos/manage_users_repo_impl.dart'
    as _i883;
import '../../features/project_dashboard/cubit/project_dashboard_cubit.dart'
    as _i495;
import '../../features/project_dashboard/cubit/ticket_messages_cubit.dart'
    as _i696;
import '../../features/project_dashboard/data/repos/dash_repo.dart' as _i346;
import '../../features/project_dashboard/data/repos/dash_repo_impl.dart'
    as _i503;
import '../../features/projects/cubit/projects_cubit.dart' as _i438;
import '../../features/projects/data/repos/projects_repo.dart' as _i234;
import '../../features/projects/data/repos/projects_repo_impl.dart' as _i296;
import '../../features/settings/cubit/settings_cubit.dart' as _i960;
import '../../features/settings/data/repos/settings_repo.dart' as _i878;
import '../../features/settings/data/repos/settings_repo_impl.dart' as _i181;
import '../env/env_config.dart' as _i0;
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
    gh.singleton<_i0.EnvConfig>(() => _i0.EnvConfig());
    gh.lazySingleton<_i361.Dio>(() => dioModule.provideDio());
    gh.lazySingleton<_i87.ManageRepository>(() => const _i176.ManageRepoImpl());
    gh.lazySingleton<_i713.MyApi>(() => _i713.MyApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i346.DashRepository>(
        () => _i503.DashRepoImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i90.DicRepository>(
        () => _i1046.DicRepoImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i234.ProjectsRepository>(
        () => _i296.ProjectsRepoImpl(gh<_i713.MyApi>()));
    gh.factory<_i495.ProjectDashboardCubit>(
        () => _i495.ProjectDashboardCubit(gh<_i346.DashRepository>()));
    gh.factory<_i696.TicketMessagesCubit>(
        () => _i696.TicketMessagesCubit(gh<_i346.DashRepository>()));
    gh.factory<_i133.ManageOwnersRepository>(
        () => _i1045.ManageOwnersRepositoryImpl(gh<_i713.MyApi>()));
    gh.factory<_i423.ManageProjectsRepository>(
        () => _i320.ManageProjectsRepositoryImpl(gh<_i713.MyApi>()));
    gh.factory<_i1047.ManageSensorsRepository>(
        () => _i62.ManageSensorsRepositoryImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i573.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i713.MyApi>()));
    gh.factory<_i818.ManageUsersRepository>(
        () => _i883.ManageUsersRepositoryImpl(gh<_i713.MyApi>()));
    gh.factory<_i694.ManageOwnersCubit>(
        () => _i694.ManageOwnersCubit(gh<_i133.ManageOwnersRepository>()));
    gh.factory<_i438.ProjectsCubit>(
        () => _i438.ProjectsCubit(gh<_i234.ProjectsRepository>()));
    gh.lazySingleton<_i767.AiReportRepository>(
        () => _i1064.AiReportRepositoryImpl(gh<_i713.MyApi>()));
    gh.lazySingleton<_i878.SettingsRepository>(
        () => _i181.SettingsRepoImpl(gh<_i713.MyApi>()));
    gh.factory<_i988.ManageSensorsCubit>(
        () => _i988.ManageSensorsCubit(gh<_i1047.ManageSensorsRepository>()));
    gh.factory<_i782.AiReportCubit>(
        () => _i782.AiReportCubit(gh<_i767.AiReportRepository>()));
    gh.factory<_i960.SettingsCubit>(
        () => _i960.SettingsCubit(gh<_i878.SettingsRepository>()));
    gh.factory<_i3.ManageUsersCubit>(
        () => _i3.ManageUsersCubit(gh<_i818.ManageUsersRepository>()));
    gh.factory<_i446.ManageProjectsCubit>(
        () => _i446.ManageProjectsCubit(gh<_i423.ManageProjectsRepository>()));
    gh.factory<_i698.AuthCubit>(
        () => _i698.AuthCubit(gh<_i573.AuthRepository>()));
    gh.factory<_i819.DicCubit>(() => _i819.DicCubit(
          gh<_i90.DicRepository>(),
          gh<_i878.SettingsRepository>(),
        ));
    return this;
  }
}

class _$DioModule extends _i444.DioModule {}
