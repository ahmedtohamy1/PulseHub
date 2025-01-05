import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/project_dashboard/data/models/tickets_messages_model.dart';
import 'package:pulsehub/features/project_dashboard/data/repos/dash_repo.dart';

sealed class TicketMessagesState {}

class TicketMessagesInitial extends TicketMessagesState {}

class TicketMessagesLoading extends TicketMessagesState {}

class TicketMessagesSuccess extends TicketMessagesState {
  final TicketMessagesModel ticketMessagesModel;

  TicketMessagesSuccess(this.ticketMessagesModel);
}

class TicketMessagesFailure extends TicketMessagesState {
  final String message;

  TicketMessagesFailure(this.message);
}

class CreateTicketMessageLoading extends TicketMessagesState {}

class CreateTicketMessageSuccess extends TicketMessagesState {
  final bool success;

  CreateTicketMessageSuccess(this.success);
}

class CreateTicketMessageFailure extends TicketMessagesState {
  final String message;

  CreateTicketMessageFailure(this.message);
}

@injectable
class TicketMessagesCubit extends Cubit<TicketMessagesState> {
  final DashRepository _repository;

  TicketMessagesCubit(this._repository) : super(TicketMessagesInitial());

  Future<void> getTicketMessages(int ticketId) async {
    emit(TicketMessagesLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.getTicketMessages(token, ticketId);
    res.fold(
      (failure) => emit(TicketMessagesFailure(failure)),
      (response) => emit(TicketMessagesSuccess(response)),
    );
  }

  Future<void> createTicketMessage(int ticketId, String message) async {
    emit(CreateTicketMessageLoading());
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.token);
    final res = await _repository.createTicketMessage(token, ticketId, message);
    res.fold(
      (failure) => emit(CreateTicketMessageFailure(failure)),
      (response) => emit(CreateTicketMessageSuccess(response)),
    );
  }
}
