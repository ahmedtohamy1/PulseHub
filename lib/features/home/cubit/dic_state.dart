part of 'dic_cubit.dart';

sealed class DicState extends Equatable {
  const DicState();

  @override
  List<Object> get props => [];
}

final class DicInitial extends DicState {}

final class DicLoading extends DicState {}

final class DicSuccess extends DicState {
  final DicServicesResponse dic;
  const DicSuccess(this.dic);

  @override
  List<Object> get props => [dic];
}

final class DicError extends DicState {
  final String message;
  const DicError(this.message);

  @override
  List<Object> get props => [message];
}
