import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/projects/data/models/get_projects_response.dart';
import 'package:pulsehub/features/projects/data/repos/projects_repo.dart';
import 'package:pulsehub/features/projects/data/models/project_response.dart' as pr;

part 'projects_state.dart';
@injectable
class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository _repository;

  ProjectsCubit(this._repository) : super(ProjectsInitial());
void getProjects() async {
  emit(ProjectsLoading());
  try {
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getProjects(token);

    res.fold(
      (failure) => emit(ProjectsError('Error: $failure')),
      (response) {
        // Check for missing or empty projects
        if (response.projects.isEmpty) {
          emit(ProjectsError('No projects found.'));
        } else {
          emit(ProjectsLoaded(response));
        }
      },
    );
  } catch (e) {
    emit(ProjectsError('Unexpected error occurred: $e'));
  }
}
void flagOrUnflagProject({
  required int userId,
  required int projectId,
  required bool isFlag,
}) async {
  try {
    // Emit a loading state while the API call is being processed
    emit(ProjectsLoading());

    // Get the user's token from shared preferences
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);

    // Call the repository to flag/unflag the project
    final response = await _repository.flagOrUnflagProject(
      token: token,
      userId: userId,
      projectId: projectId,
      isFlag: isFlag,
    );

    // Handle success or error
    response.fold(
      (failure) => emit(ProjectsError('Error: $failure')),
      (_) async {
        // After flagging/unflagging, reload projects to reflect the change
         getProjects();
      },
    );
  } catch (e) {
    emit(ProjectsError('Unexpected error occurred: $e'));
  }
}
void getProject(int projectId) async {
  emit(ProjectsLoading());
  try {
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final response = await _repository.getProject(
      token: token,
      projectId: projectId,
    );

    response.fold(
      (failure) => emit(ProjectsError('Error: $failure')),
      (pr) => emit(ProjectDetailsLoaded(pr)), // New state for project details
    );
  } catch (e) {
    emit(ProjectsError('Unexpected error occurred: $e'));
  }
}

}
