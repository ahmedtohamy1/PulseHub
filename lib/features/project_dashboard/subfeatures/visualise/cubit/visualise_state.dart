part of 'visualise_cubit.dart';

sealed class VisualiseState extends Equatable {
  const VisualiseState();

  @override
  List<Object> get props => [];
}

final class VisualiseInitial extends VisualiseState {}

final class VisualiseLoading extends VisualiseState {}

final class VisualiseSuccess extends VisualiseState {}

final class VisualiseFailure extends VisualiseState {
  final String message;

  const VisualiseFailure(this.message);
}
