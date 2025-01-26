part of 'manage_monitorings_cubit.dart';

sealed class ManageMonitoringsState extends Equatable {
  final MonitoringResponse? monitoringResponse;
  final GetProjectsResponse? projectsResponse;

  const ManageMonitoringsState({
    this.monitoringResponse,
    this.projectsResponse,
  });

  @override
  List<Object?> get props => [monitoringResponse, projectsResponse];
}

final class ManageMonitoringsInitial extends ManageMonitoringsState {
  const ManageMonitoringsInitial() : super();
}

final class ManageMonitoringsLoading extends ManageMonitoringsState {
  const ManageMonitoringsLoading({
    super.monitoringResponse,
    super.projectsResponse,
  });
}

final class ManageMonitoringsSuccess extends ManageMonitoringsState {
  const ManageMonitoringsSuccess(
    MonitoringResponse monitoringResponse, {
    super.projectsResponse,
  }) : super(
          monitoringResponse: monitoringResponse,
        );
}

final class ManageMonitoringsFailure extends ManageMonitoringsState {
  final String error;
  const ManageMonitoringsFailure(
    this.error, {
    super.monitoringResponse,
    super.projectsResponse,
  });

  @override
  List<Object?> get props => [...super.props, error];
}

final class ManageMonitoringsEditLoading extends ManageMonitoringsState {
  const ManageMonitoringsEditLoading({
    super.monitoringResponse,
    super.projectsResponse,
  });
}

final class ManageMonitoringsEditSuccess extends ManageMonitoringsState {
  final bool success;
  const ManageMonitoringsEditSuccess(
    this.success, {
    super.monitoringResponse,
    super.projectsResponse,
  });

  @override
  List<Object?> get props => [...super.props, success];
}

final class ManageMonitoringsEditFailure extends ManageMonitoringsState {
  final String error;
  const ManageMonitoringsEditFailure(
    this.error, {
    super.monitoringResponse,
    super.projectsResponse,
  });

  @override
  List<Object?> get props => [...super.props, error];
}

final class ManageMonitoringsGetProjectsLoading extends ManageMonitoringsState {
  const ManageMonitoringsGetProjectsLoading({
    super.monitoringResponse,
    super.projectsResponse,
  });
}

final class ManageMonitoringsGetProjectsSuccess extends ManageMonitoringsState {
  const ManageMonitoringsGetProjectsSuccess(
    GetProjectsResponse projectsResponse, {
    super.monitoringResponse,
  }) : super(projectsResponse: projectsResponse);
}

final class ManageMonitoringsGetProjectsFailure extends ManageMonitoringsState {
  final String error;
  const ManageMonitoringsGetProjectsFailure(
    this.error, {
    super.monitoringResponse,
    super.projectsResponse,
  });

  @override
  List<Object?> get props => [...super.props, error];
}


  final class ManageMonitoringsDeleteLoading extends ManageMonitoringsState {
  const ManageMonitoringsDeleteLoading({
    super.monitoringResponse,
    super.projectsResponse,
  });
}

final class ManageMonitoringsDeleteSuccess extends ManageMonitoringsState {
  final bool success;
  const ManageMonitoringsDeleteSuccess(
    this.success, {
    super.monitoringResponse,
    super.projectsResponse,
  }); 

  @override
  List<Object?> get props => [...super.props, success];
}

final class ManageMonitoringsDeleteFailure extends ManageMonitoringsState {
  final String error;
  const ManageMonitoringsDeleteFailure(
    this.error, {
    super.monitoringResponse,
    super.projectsResponse,
  });

  @override
  List<Object?> get props => [...super.props, error];
}

final class ManageMonitoringsCreateLoading extends ManageMonitoringsState {
  const ManageMonitoringsCreateLoading({
    super.monitoringResponse,
    super.projectsResponse,
  });
}

final class ManageMonitoringsCreateSuccess extends ManageMonitoringsState {
  const ManageMonitoringsCreateSuccess(
    bool success, {
    super.monitoringResponse,
    super.projectsResponse,
  });

  @override
    List<Object?> get props => [...super.props, ];
}

final class ManageMonitoringsCreateFailure extends ManageMonitoringsState {
  final String error;
  const ManageMonitoringsCreateFailure(
    this.error, {
    super.monitoringResponse,
    super.projectsResponse,
  });

  @override
  List<Object?> get props => [...super.props, error];
}
