part of 'ai_report_cubit.dart';

sealed class AiReportState extends Equatable {
  const AiReportState();

  @override
  List<Object> get props => [];
}

final class AiReportInitial extends AiReportState {}

class AiReportLoading extends AiReportState {}

class AiReportFailure extends AiReportState {
  final String message;

  const AiReportFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AiReportSuccess extends AiReportState {
  final ResponseModel response;

  const AiReportSuccess(this.response);

  @override
  List<Object> get props => [response];
}
