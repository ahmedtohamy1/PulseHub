part of 'manage_owners_cubit.dart';

abstract class ManageOwnersState extends Equatable {
  const ManageOwnersState();

  @override
  List<Object?> get props => [];
}

class ManageOwnersInitial extends ManageOwnersState {}

class GetAllOwnersLoading extends ManageOwnersState {}

class GetAllOwnersSuccess extends ManageOwnersState {
  final List<OwnerModel> owners;

  const GetAllOwnersSuccess(this.owners);

  @override
  List<Object?> get props => [owners];
}

class GetAllOwnersFailure extends ManageOwnersState {
  final String error;

  const GetAllOwnersFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class DeleteOwnerLoading extends ManageOwnersState {
  final int ownerId;

  const DeleteOwnerLoading(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class DeleteOwnerSuccess extends ManageOwnersState {}

class DeleteOwnerFailure extends ManageOwnersState {
  final String error;

  const DeleteOwnerFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CreateOwnerLoading extends ManageOwnersState {}

class CreateOwnerSuccess extends ManageOwnersState {}

class CreateOwnerFailure extends ManageOwnersState {
  final String error;

  const CreateOwnerFailure(this.error);

  @override
  List<Object?> get props => [error];
}
